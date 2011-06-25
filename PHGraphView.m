//
//  PHGraphView.m
//  Graph
//
//  Created by Pierre-Henri Jondot on 30/03/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHGraphView.h"
#import "PHOverlayWindow.h"

@implementation PHGraphView

+(NSMenu *)defaultMenu {
	NSMenu *theMenu = [[[NSMenu alloc] initWithTitle:@"Copy"] autorelease];
	[theMenu insertItemWithTitle:@"Copy to pasteboard as TIFF" action:@selector(copyToPasteboardAsTIFF) 
		keyEquivalent:@"" atIndex:0];
	[theMenu insertItemWithTitle:@"Copy to pasteboard as PDF" action:@selector(copyToPasteboardAsPDF) 
		keyEquivalent:@"" atIndex:1];
	[theMenu insertItemWithTitle:@"Copy to pasteboard as EPS" action:@selector(copyToPasteboardAsEPS) 
		keyEquivalent:@"" atIndex:2];
	return theMenu;
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		xAxis = [[NSMutableArray alloc] init];
		yAxis = [[NSMutableArray alloc] init];
		graphObjects = [[NSMutableArray alloc] init];
		hasBorder = NO;
		isDragging = NO;
		leftBorder = 50;
		rightBorder = 10;
		bottomBorder = 25;
		topBorder = 10;
	}
    return self;
}

-(void)dealloc
{
	[xAxis release];
	[yAxis release];
	[graphObjects release];
	[super dealloc];
}

-(void)addPHxAxis:(PHxAxis*)axis
{
	[xAxis addObject:axis];
}

-(void)addPHyAxis:(PHyAxis*)axis
{
	[yAxis addObject:axis];
}

-(void)addPHGraphObject:(PHGraphObject*)object 
{
	[graphObjects addObject:object];
}

-(void)removePHxAxis:(PHxAxis*)axis
{
	[xAxis removeObject:axis];
}

-(void)removePHyAxis:(PHyAxis*)axis
{
	[yAxis removeObject:axis];
}

-(void)removePHGraphObject:(PHGraphObject*)object
{
	[graphObjects removeObject:object];
}

-(BOOL)isDragging
{
	return isDragging;
}
//direct accessors to the arrays of axis and objects
-(NSMutableArray*)xAxisMutableArray
{
	return xAxis;
}

-(NSMutableArray*)yAxisMutableArray
{
	return yAxis;
}

-(NSMutableArray*)graphObjectsMutableArray
{
	return graphObjects;
}

-(void)setXAxisMutableArray:(NSMutableArray*)anArray
{
	[anArray retain];
	[xAxis release];
	xAxis = anArray;
}

-(void)setYAxisMutableArray:(NSMutableArray*)anArray
{
	[anArray retain];
	[yAxis release];
	yAxis = anArray;
}

-(void)setGraphObjectsMutableArray:(NSMutableArray*)anArray
{
	[anArray retain];
	[graphObjects release];
	graphObjects = anArray;
}

-(BOOL)acceptsFirstResponder
{
	return YES;
}

-(void)viewDidMoveToWindow
{
	if ((![delegate respondsToSelector:@selector(mouseEntered:)]) || 
		(![delegate respondsToSelector:@selector(mouseExited:)])) return;
	if (hasBorder)
	{
		NSRect rect = [self bounds];
		rect.origin.x += leftBorder;
		rect.origin.y += bottomBorder;
		rect.size.width -= leftBorder+rightBorder;
		rect.size.height -= bottomBorder+topBorder;
		trackingRect = [self addTrackingRect:rect owner:delegate userData:NULL assumeInside:NO];
	} else
		trackingRect = [self addTrackingRect:[self bounds] owner:delegate userData:NULL assumeInside:NO];
}

-(void)setFrame:(NSRect)frame
{
	[super setFrame:frame];
	if ((![delegate respondsToSelector:@selector(mouseEntered:)]) || 
		(![delegate respondsToSelector:@selector(mouseExited:)])) return;
	if (trackingRect)	
		[self removeTrackingRect:trackingRect];
	
	if (hasBorder)
	{
		NSRect rect = [self bounds];
		rect.origin.x += leftBorder;
		rect.origin.y += bottomBorder;
		rect.size.width -= leftBorder+rightBorder;
		rect.size.height -= bottomBorder+topBorder;
		trackingRect = [self addTrackingRect:rect owner:delegate userData:NULL assumeInside:NO];
	} else
		trackingRect = [self addTrackingRect:[self bounds] owner:delegate userData:NULL assumeInside:NO];
}

-(void)setMouseEventsMode:(int)mode
{
	mouseEventsMode = mode;
}

-(void)setDelegate:(id)newDelegate
{
	delegate=newDelegate;
	if ((![delegate respondsToSelector:@selector(mouseEntered:)]) || 
		(![delegate respondsToSelector:@selector(mouseExited:)])) return;
		
	if (hasBorder)
	{
		NSRect rect = [self bounds];
		rect.origin.x += leftBorder;
		rect.origin.y += bottomBorder;
		rect.size.width -= leftBorder+rightBorder;
		rect.size.height -= bottomBorder+topBorder;
		trackingRect = [self addTrackingRect:rect owner:delegate userData:NULL assumeInside:NO];
	} else
		trackingRect = [self addTrackingRect:[self bounds] owner:delegate userData:NULL assumeInside:NO];
}

-(id)delegate
{
	return delegate;
}

-(void)setHasBorder:(BOOL)value
{
	hasBorder = value;
}

-(void)setLeftBorder:(float)newLeftBorder rightBorder:(float)newRightBorder
		bottomBorder:(float)newBottomBorder topBorder:(float)newTopBorder
{
	leftBorder = newLeftBorder;
	rightBorder = newRightBorder;
	bottomBorder = newBottomBorder;
	topBorder = newTopBorder;
}

-(void)mouseDown:(NSEvent *)theEvent
{
	locationMouseDownInView = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	if (hasBorder) 
	{
		locationMouseDownInView.x -= leftBorder;
		locationMouseDownInView.y -= bottomBorder;
	}
	if (((mouseEventsMode==PHZoomOnSelection) || (mouseEventsMode==PHCompositeZoomAndDrag))
		&& ([theEvent modifierFlags] & NSAlternateKeyMask))
	{
		int n=[xAxis count],i;
		for (i=0; i<n; i++)
		{
			[(PHAxis*)[xAxis objectAtIndex:i] zoomout];
		}
		n=[yAxis count];
		for (i=0; i<n; i++)
		{
			[(PHAxis*)[yAxis objectAtIndex:i] zoomout];
		}
		[self display];
		return;
	}
	
	switch (mouseEventsMode) {
		case PHOnlyDelegate:
			if ([delegate respondsToSelector:@selector(mouseDownAtPoint:)])
			{
				NSRect bounds=[self bounds];
				if (hasBorder)
				{
					bounds.size.width -= leftBorder+rightBorder;
					bounds.size.height -= bottomBorder+topBorder;
				}
				[delegate mouseDownAtPoint:NSMakePoint(locationMouseDownInView.x/bounds.size.width,
					locationMouseDownInView.y/bounds.size.height)]; }
			break;
		case PHCompositeZoomAndDrag:
		{
			isDragging=NO;
			int n = [xAxis count], i;
			for (i=0; i<n; i++) [[xAxis objectAtIndex:i] saveValues];
			n = [yAxis count];
			for (i=0; i<n; i++) [[yAxis objectAtIndex:i] saveValues];
		}
		break;
		
		case PHDragAndMove:
		{
			int n=[xAxis count],i;
			for (i=0; i<n; i++) [(PHAxis*) [xAxis objectAtIndex:i] saveValues];
			n=[yAxis count];
			for (i=0; i<n; i++) [(PHAxis*) [yAxis objectAtIndex:i] saveValues];
			isDragging = YES;
		}
		break;
		
		case PHZoomOnSelection:
		{
			locationMouseDown = [[self window] convertBaseToScreen:[theEvent locationInWindow]];
			overlayWindow = [[PHOverlayWindow alloc] initWithContentRect:
				NSMakeRect(locationMouseDown.x, locationMouseDown.y, 0, 0)];
			[overlayWindow display];
			[overlayWindow orderFront:self];
		}
		break;
	}
}

-(void)mouseDragged:(NSEvent *)theEvent
{
	switch (mouseEventsMode) {
		case PHOnlyDelegate:
			if ([delegate respondsToSelector:@selector(mouseDraggedAtPoint:)])
			{
				NSRect bounds=[self bounds];
				currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				if (hasBorder)
				{
					currentLocation.x -= leftBorder;
					currentLocation.y -= bottomBorder;
					bounds.size.width -= leftBorder+rightBorder;
					bounds.size.height -= bottomBorder+topBorder;
				}
				[delegate mouseDraggedAtPoint:NSMakePoint(currentLocation.x/bounds.size.width,
					currentLocation.y/bounds.size.height)]; }
			break;
		case PHCompositeZoomAndDrag:
		{
			currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			if (hasBorder)
			{
				currentLocation.x -= leftBorder;
				currentLocation.y -= bottomBorder;
			}
			if (!isDragging)
				if (fabs(currentLocation.x-locationMouseDownInView.x)+fabs(currentLocation.y-locationMouseDown.y)>8)
					isDragging=YES;
			if (isDragging)
			{
				double xFactor = (double)(currentLocation.x-locationMouseDownInView.x)/[self bounds].size.width;
				double yFactor = (double)(currentLocation.y-locationMouseDownInView.y)/[self bounds].size.height;
				int n = [xAxis count]; int i;
				for (i=0; i<n; i++) [[xAxis objectAtIndex:i] moveByFactor: xFactor];
				n = [yAxis count];
				for (i=0; i<n; i++) [[yAxis objectAtIndex:i] moveByFactor:yFactor];
				[self display];
			}
		}
		break;
		
		case PHDragAndMove:
		{
			currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			float width = [self bounds].size.width;
			float height = [self bounds].size.height;
			if (hasBorder)
			{
				currentLocation.x -= leftBorder;
				currentLocation.y -= bottomBorder;
				width -= leftBorder+rightBorder;
				height -= bottomBorder+topBorder;
			}
			double xFactor = (double)(currentLocation.x-locationMouseDownInView.x)/width;
			double yFactor = (double)(currentLocation.y-locationMouseDownInView.y)/height;
			int n = [xAxis count]; int i;
			for (i=0; i<n; i++) [(PHAxis*)[xAxis objectAtIndex:i] moveByFactor: xFactor];
			n = [yAxis count];
			for (i=0; i<n; i++) [(PHAxis*)[yAxis objectAtIndex:i] moveByFactor:yFactor];
			[self display];
		}
		break;
		
		case PHZoomOnSelection:
		{
			currentLocation = [[self window] convertBaseToScreen:[theEvent locationInWindow]];
			float xmin = locationMouseDown.x;
			float ymin = locationMouseDown.y;
			if (currentLocation.x < locationMouseDown.x)
				xmin = currentLocation.x;
			if (currentLocation.y < locationMouseDown.y)
				ymin = currentLocation.y;
			[overlayWindow setFrame:NSMakeRect(xmin,ymin,
				fabs(currentLocation.x-locationMouseDown.x),fabs(currentLocation.y-locationMouseDown.y))
				display:YES];
			[overlayWindow display];
		}
		break;
	}
}	

-(void)mouseUp:(NSEvent *)theEvent
{
	switch (mouseEventsMode) {
		case PHOnlyDelegate:
			if ([delegate respondsToSelector:@selector(mouseUpAtPoint:)])
			{
				NSRect bounds = [self bounds];
				currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				if (hasBorder)
				{
					currentLocation.x -= leftBorder;
					currentLocation.y -= bottomBorder;
					bounds.size.width -= leftBorder+rightBorder;
					bounds.size.height -= bottomBorder+topBorder;
				}
				[delegate mouseUpAtPoint:NSMakePoint(currentLocation.x/bounds.size.width,
				currentLocation.y/bounds.size.height)]; }
			break;
		case PHCompositeZoomAndDrag:
		{
			if (!(isDragging || ([theEvent modifierFlags] & NSAlternateKeyMask)))
			{
				int n=[xAxis count],i;
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[xAxis objectAtIndex:i] zoomin];
				}
				n=[yAxis count];
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[yAxis objectAtIndex:i] zoomin];
				}
				[self display];
			}
			break;
		}	
		case PHDragAndMove:
			isDragging = NO;
			break;
		case PHZoomOnSelection:
		{
			[overlayWindow release];
			overlayWindow = nil;
			if ([theEvent modifierFlags] & NSAlternateKeyMask) break;
			currentLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			NSRect bounds = [self bounds];
			if (hasBorder)
			{
				currentLocation.x -= leftBorder;
				currentLocation.y -= bottomBorder;
				bounds.size.width -= leftBorder+rightBorder;
				bounds.size.height -= bottomBorder+topBorder;
			}
			if ((fabs(currentLocation.x-locationMouseDownInView.x)<20) ||
				(fabs(currentLocation.y-locationMouseDownInView.y))<20) return;
			if (currentLocation.x < locationMouseDownInView.x)
			{
				int n = [xAxis count],i;
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[xAxis objectAtIndex:i] 
						zoomWithMinimum:(currentLocation.x-bounds.origin.x)/bounds.size.width 
						maximum:(locationMouseDownInView.x-bounds.origin.x)/bounds.size.width];
				}
			}
			else
			{
				int n=[xAxis count],i;
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[xAxis objectAtIndex:i] 
						zoomWithMinimum:(locationMouseDownInView.x-bounds.origin.x)/bounds.size.width 
						maximum:(currentLocation.x-bounds.origin.x)/bounds.size.width];
				}
			}
			if (currentLocation.y < locationMouseDownInView.y)
			{
				int n=[yAxis count],i;
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[yAxis objectAtIndex:i] 
						zoomWithMinimum:(currentLocation.y-bounds.origin.y)/bounds.size.height 
						maximum:(locationMouseDownInView.y-bounds.origin.y)/bounds.size.height];
				}
			}
			else
			{
				int n=[yAxis count],i;
				for (i=0; i<n; i++)
				{
					[(PHAxis*)[yAxis objectAtIndex:i] 
					zoomWithMinimum:(locationMouseDownInView.y-bounds.origin.y)/bounds.size.height 
					maximum:(currentLocation.y-bounds.origin.y)/bounds.size.height];
				}
			}
			[self display];
		}
		break;
	}
}

-(BOOL)mouseDownCanMoveWindow
{
	return NO;
}

- (void)drawRect:(NSRect)rect {
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	NSRect arect = [self bounds];
	CGRect clippingArea = CGRectMake(arect.origin.x, arect.origin.y, arect.size.width, arect.size.height);
	if (hasBorder) {
		clippingArea.origin.x += leftBorder;
		clippingArea.origin.y += bottomBorder;
		clippingArea.size.width -= leftBorder+rightBorder;
		clippingArea.size.height -= bottomBorder+topBorder;
	}
	NSRect drawingArea = NSMakeRect(clippingArea.origin.x, clippingArea.origin.y, 
			clippingArea.size.width, clippingArea.size.height);
	int n = [graphObjects count], i;
	for (i=0; i<n; i++)
	{
		PHGraphObject *object=(PHGraphObject*)[graphObjects objectAtIndex:i];
		if (([object shouldDraw]) && (!(isDragging && [object isLongToDraw])))
		{
			CGContextSaveGState(context);
			if (hasBorder) CGContextClipToRect(context,clippingArea);
			[[graphObjects objectAtIndex:i] drawWithContext:context rect:drawingArea];
			CGContextRestoreGState(context);
		}
	}
	n=[xAxis count];
	for (i=0; i<n; i++)
	{
		PHxAxis* axis = [xAxis objectAtIndex:i];
		[axis setDrawOutside:hasBorder];
		[axis drawWithContext:context rect:drawingArea];
	}
	n=[yAxis count];
	for (i=0; i<n; i++)
	{
		PHyAxis* axis = [yAxis objectAtIndex:i];
		[axis setDrawOutside:hasBorder];
		[axis drawWithContext:context rect:drawingArea];
	}
}

-(void)copyToPasteboardAsTIFF
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects: NSTIFFPboardType,nil];
	[pb declareTypes:types  owner:self];
	NSRect bounds = [self bounds];
	int width = (int)bounds.size.width;
	int height = (int)bounds.size.height;
	
	NSBitmapImageRep *bitmapImageRep = [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:NULL
		pixelsWide:width pixelsHigh:height bitsPerSample:8 samplesPerPixel:4 hasAlpha:YES 
		isPlanar:NO colorSpaceName:NSCalibratedRGBColorSpace bytesPerRow:0 bitsPerPixel:32];
	NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:bitmapImageRep];
	[NSGraphicsContext setCurrentContext:context];
	NSEraseRect(bounds);
	[self drawRect:bounds];
	NSData *tiffData = [bitmapImageRep TIFFRepresentation];
	[pb setData:tiffData forType:NSTIFFPboardType];
	[bitmapImageRep release];
}

-(void)copyToPasteboardAsPDF
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects: NSPDFPboardType ,nil];
	[pb declareTypes:types  owner:self];
	NSData *PDFRepresentation = [self dataWithPDFInsideRect:[self bounds]];
	[pb setData:PDFRepresentation forType:NSPDFPboardType];
}

-(void)copyToPasteboardAsEPS
{
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObject:NSPostScriptPboardType];
	[pb declareTypes:types owner:self];
	NSData *EPSRepresentation = [self dataWithEPSInsideRect:[self bounds]];
	[pb setData:EPSRepresentation forType:NSPostScriptPboardType];
}

@end
