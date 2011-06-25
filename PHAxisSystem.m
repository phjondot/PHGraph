//
//  PHAxisSystem.m
//  PHGraph
//
//  Created by Pierre-Henri Jondot on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHAxisSystem.h"
#import "PHColor.h"

@implementation PHAxisSystem
-(id)initWithXAxis:(PHxAxis *)aPHxAxis yAxis:(PHyAxis *)aPHyAxis
{
	[super initWithXAxis:aPHxAxis yAxis:aPHyAxis];
	width = 1;
	return self;
}

-(void)setWidth:(float)newWidth
{
	width = newWidth;
}

-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	CGColorRef colorForXaxis = [[xAxis color] toCGColorRef];
	CGColorRef colorForYaxis = [[yAxis color] toCGColorRef];
	
	CGContextSetStrokeColorWithColor(context, colorForXaxis);
	CGContextSetFillColorWithColor(context, colorForXaxis);
	
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	
	CGContextBeginPath(context);
	CGContextSetLineWidth(context, width);
	//Draw xAxis with arrow
	float y;
	if (ymin > 0) y = rect.origin.y+4;
		else if (ymax < 0) y = rect.origin.y+rect.size.height-4;
			else y = rect.origin.y+ymin/(ymin-ymax)*rect.size.height;
	if (y<rect.origin.y+4) y = rect.origin.y+4;
	if (y>rect.origin.y+rect.size.height-4) y = rect.origin.y+rect.size.height-4;
	
	BOOL legendOverTheAxis = YES;
	if ((y-rect.origin.y)/rect.size.height > 0.7)
		legendOverTheAxis = NO;
		
	CGContextMoveToPoint(context, rect.origin.x, y);
	CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, y);
	CGContextStrokePath(context);
	
	CGContextMoveToPoint(context, rect.origin.x+rect.size.width, y);
	CGContextAddLineToPoint(context, rect.origin.x+rect.size.width-8, y+4);
	CGContextAddLineToPoint(context, rect.origin.x+rect.size.width-5, y);
	CGContextAddLineToPoint(context, rect.origin.x+rect.size.width-8, y-4);
	CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, y);
	CGContextFillPath(context);
	
	//Tickmarks
	NSMutableArray *ticks = [[xAxis majorTickMarks] retain];
	int j;
	
	CGContextSetLineWidth(context, width);
	
	for (j=0; j < [ticks count]; j++)
	{
		double xf = [[ticks objectAtIndex:j] doubleValue];
		float x = rect.origin.x+(xf-xmin)/(xmax-xmin)*rect.size.width;
		CGContextMoveToPoint(context, x,y-3);
		CGContextAddLineToPoint(context, x, y+3);
		
		NSString *value;
		if (fabs(xf/[xAxis majorTickWidth])<0.5)
			{ value=@""; } else
			{ value = [NSString stringWithFormat:@"%1.4lg",xf]; } 
		
		NSRect bound=[value boundingRectWithSize:rect.size options:0 attributes:[xAxis attributes]];
		if (legendOverTheAxis) {
			[value drawAtPoint:NSMakePoint(x-bound.size.width/2,y+4)
				withAttributes:[xAxis attributes]];
		} else {
			[value drawAtPoint:NSMakePoint(x-bound.size.width/2,y-bound.size.height-4)
				withAttributes:[xAxis attributes]];
		}
	}
	CGContextStrokePath(context);
	[ticks release];
	ticks = [[xAxis minorTickMarks] retain];
	CGContextSetLineWidth(context, width*0.5);
	for (j=0; j < [ticks count]; j++)
	{
		double xf = [[ticks objectAtIndex:j] doubleValue];
		CGFloat x = rect.origin.x+(xf-xmin)/(xmax-xmin)*rect.size.width;
		CGContextMoveToPoint(context, x, y-2);
		CGContextAddLineToPoint(context, x, y+2);
	}
	CGContextStrokePath(context);
	[ticks release];
	
	CGContextSetStrokeColorWithColor(context, colorForYaxis);
	CGContextSetFillColorWithColor(context, colorForYaxis);
	
	//Draw yAxis
	float x;
	if (xmin > 0) x = rect.origin.x+4;
		else if (xmax < 0) x = rect.origin.x+rect.size.width-4;
			else x = rect.origin.x+xmin/(xmin-xmax)*rect.size.width;
	BOOL legendAtLeftOfTheAxis = YES;
	if ((x-rect.origin.x)/rect.size.width < 0.5)
		legendAtLeftOfTheAxis = NO;
		
	CGContextMoveToPoint(context, x, rect.origin.y);
	CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height);
	CGContextStrokePath(context);
	
	CGContextMoveToPoint(context, x, rect.origin.y+rect.size.height);
	CGContextAddLineToPoint(context, x+4, rect.origin.y+rect.size.height-8);
	CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height-5);
	CGContextAddLineToPoint(context, x-4, rect.origin.y+rect.size.height-8);
	CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height);
	CGContextFillPath(context);

	//Tickmarks
	ticks = [[yAxis majorTickMarks] retain];
	
	CGContextSetLineWidth(context, width);
	
	for (j=0; j < [ticks count]; j++)
	{
		double yf = [[ticks objectAtIndex:j] doubleValue];
		float y = rect.origin.y+(yf-ymin)/(ymax-ymin)*rect.size.height;
		CGContextMoveToPoint(context, x-3,y);
		CGContextAddLineToPoint(context, x+3, y);
		
		NSString *value;
		if (fabs(yf/[yAxis majorTickWidth])<0.5)
			{ value=@""; } else
			{ value = [NSString stringWithFormat:@"%1.4lg",yf]; } 
		
		NSRect bound=[value boundingRectWithSize:rect.size options:0 attributes:[yAxis attributes]];
		if (legendAtLeftOfTheAxis) {
			[value drawAtPoint:NSMakePoint(x-bound.size.width-4,y-bound.size.height/2+1)
				withAttributes:[xAxis attributes]];
		} else {
			[value drawAtPoint:NSMakePoint(x+4,y-bound.size.height/2+1)
				withAttributes:[yAxis attributes]];
		}
	}
	CGContextStrokePath(context);
	[ticks release];
	ticks = [[yAxis minorTickMarks] retain];
	CGContextSetLineWidth(context, width*0.5);
	for (j=0; j < [ticks count]; j++)
	{
		double yf = [[ticks objectAtIndex:j] doubleValue];
		CGFloat y = rect.origin.y+(yf-ymin)/(ymax-ymin)*rect.size.height;
		CGContextMoveToPoint(context, x-2, y);
		CGContextAddLineToPoint(context, x+2, y);
	}
	[ticks release];
	CGContextStrokePath(context);
	CGColorRelease(colorForXaxis);
	CGColorRelease(colorForYaxis);
}
@end
