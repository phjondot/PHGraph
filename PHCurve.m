//
//  PHCurve.m
//  Graph
//
//  Created by Pierre-Henri Jondot on 02/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHCurve.h"
#import "PHColor.h"

@implementation PHCurve
-(id)initWithXData:(double*)xd yData:(double*)yd numberOfPoints:(int)np
		xAxis:(PHxAxis*)xaxis yAxis:(PHyAxis*)yaxis
{
	[super initWithXAxis:xaxis yAxis:yaxis];
	xData = xd;
	yData = yd;
	numberOfPoints = np;
	width = 1;
	cocoaColor = [[NSColor blackColor] retain];
	style = PHStraight;
	return self;
}

-(void)dealloc
{
	[cocoaColor release];
	[super dealloc];
}

-(void)setColor:(NSColor*)newColor
{
	[newColor retain];
	[cocoaColor release];
	cocoaColor = newColor;
}

-(void)setWidth:(float)newWidth
{
	width = newWidth;
}

-(void)setStyle:(int)newStyle
{
	style = newStyle;
}

-(void)setNumberOfPoints:(int)newNumberOfPoints
{	
	numberOfPoints = newNumberOfPoints;
}

-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	CGColorRef color = [cocoaColor toCGColorRef];
	CGContextSetStrokeColorWithColor(context, color);
	CGContextSetLineWidth(context, width);
	CGContextBeginPath(context);
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	
	int linesInPath = 0;
		
	switch (style) {
		case PHDashed33:
		{
			CGFloat dash[2] = {3,3};
			CGContextSetLineDash(context,0,dash,2); 
		}
		break;
	
		case PHDashed8212:
		{
			CGFloat dash[4] = {8,2,1,2};
			CGContextSetLineDash(context,0,dash,4); 
		}
		break;
	}

	BOOL formerInFrame;
	double xc = xData[0], yc = yData[0];
	double xp,yp;
	int isXlog = [xAxis style] & PHIsLog;
	int isYlog = [yAxis style] & PHIsLog;
	if (isXlog) xc = log10(xc);
	if (isYlog) yc = log10(yc);
	if ((xc>xmin) && (xc<xmax) && (yc>ymin) && (yc<ymax))
	{
		float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
		float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
		formerInFrame = YES;
		CGContextMoveToPoint(context,x,y);
	} else formerInFrame = NO;
	int i;
	for (i=1; i<numberOfPoints; i++)
	{
		xp = xc; yp = yc;
		xc = xData[i]; yc = yData[i];
		if (isXlog) xc = log10(xc);
		if (isYlog) yc = log10(yc);
	
		if ((xc>xmin) && (xc<xmax) && (yc>ymin) && (yc<ymax))
		{
			if (formerInFrame==NO)
			{
				float x = rect.origin.x+rect.size.width*(xp-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yp-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context,x,y);
			}
			float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
			float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
			CGContextAddLineToPoint(context,x,y); 
			formerInFrame = YES;
			if (++linesInPath==5000)
			{
				CGContextStrokePath(context);
				CGContextMoveToPoint(context, x, y);
				linesInPath=0;
			}
		}
		else
		{
			if (formerInFrame==YES)
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextAddLineToPoint(context,x,y); 
				if (++linesInPath==5000)
				{
					CGContextStrokePath(context);
					CGContextMoveToPoint(context, x, y);
					linesInPath=0;
				}
			}
			formerInFrame = NO;
		}
	}
	if (linesInPath)
		CGContextStrokePath(context);
	CGColorRelease(color);
}
@end
