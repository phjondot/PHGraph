//
//  PHPoints.m
//  Graph
//
//  Created by Pierre-Henri Jondot on 01/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHPoints.h"
#import "PHColor.h"


@implementation PHPoints
-(id)initWithXData:(double*)xd yData:(double*)yd numberOfPoints:(int)np
		xAxis:(PHxAxis*)xaxis yAxis:(PHyAxis*)yaxis
{
	[super initWithXAxis:xaxis yAxis:yaxis];
	xData = xd;
	yData = yd;
	numberOfPoints = np;
	size = 0.5;
	width = 0.5;
	style = PHCrossplus;
	cocoaColor = [[NSColor blackColor] retain];
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

-(void)setSize:(float)newSize
{
	size = newSize;
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
	CGContextSetFillColorWithColor(context, color);
	CGContextSetLineWidth(context, width);
	CGContextBeginPath(context);
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	int i;
	int pointsInPath = 0;
	int isXlog = [xAxis style] & PHIsLog;
	int isYlog = [yAxis style] & PHIsLog;
	double xc,yc;
	
	if (style & PHCrossx)
	{
		for (i=0; i<numberOfPoints;i++)
		{
			xc = xData[i]; yc = yData[i];
			if (isXlog) xc = log10(xc);
			if (isYlog) yc = log10(yc);
			if ((xc>=xmin) && (xc<=xmax) && (yc>=ymin) && (yc<=ymax))
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context, x-size, y-size);
				CGContextAddLineToPoint(context, x+size,y+size);
				CGContextMoveToPoint(context, x-size,y+size);
				CGContextAddLineToPoint(context,x+size,y-size);
			}
			if (++pointsInPath==5000) {
				CGContextStrokePath(context);
				pointsInPath = 0;
			}
		}
		if (pointsInPath)
			CGContextStrokePath(context);
	}
	
	if (style & PHCrossplus)
	{
		for (i=0; i<numberOfPoints;i++)
		{
			xc = xData[i]; yc = yData[i];
			if (isXlog) xc = log10(xc);
			if (isYlog) yc = log10(yc);
			if ((xc>=xmin) && (xc<=xmax) && (yc>=ymin) && (yc<=ymax))
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context, x-size, y);
				CGContextAddLineToPoint(context, x+size,y);
				CGContextMoveToPoint(context, x,y-size);
				CGContextAddLineToPoint(context,x,y+size);
			}
			if (++pointsInPath==5000) {
				CGContextStrokePath(context);
				pointsInPath = 0;
			}
		}
		if (pointsInPath)
			CGContextStrokePath(context);
	}
	
	if (style & PHCircle)
	{
		for (i=0; i<numberOfPoints;i++)
		{
			xc = xData[i]; yc = yData[i];
			if (isXlog) xc = log10(xc);
			if (isYlog) yc = log10(yc);
			if ((xc>=xmin) && (xc<=xmax) && (yc>=ymin) && (yc<=ymax))
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context, x-size, y);
				CGContextAddEllipseInRect(context, CGRectMake(x-size,y-size,2*size,2*size));			
			}
			if (++pointsInPath==1000) {
					CGContextStrokePath(context);
					pointsInPath = 0;
				}
		}
		if (pointsInPath)
			CGContextStrokePath(context);
	}
	
	if (style & PHDiamond)
	{
		for (i=0; i<numberOfPoints;i++)
		{	
			xc = xData[i]; yc = yData[i];
			if (isXlog) xc = log10(xc);
			if (isYlog) yc = log10(yc);
			if ((xc>=xmin) && (xc<=xmax) && (yc>=ymin) && (yc<=ymax))
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context, x-size, y);
				CGContextAddLineToPoint(context, x, y+size);
				CGContextAddLineToPoint(context, x+size, y);
				CGContextAddLineToPoint(context, x, y-size);
				CGContextAddLineToPoint(context, x-size, y);
			}
			if (++pointsInPath==2500) {
					CGContextStrokePath(context);
					pointsInPath = 0;
			}
		}
		if (pointsInPath)
			CGContextStrokePath(context);
	}
	
	if (style & PHImpulse)
	{
		float y0;
		if (ymin>0) 
			y0 = rect.origin.y;
		else if (ymax<0)
			y0 = rect.origin.y+rect.size.height;
		else y0 = rect.origin.y-rect.size.height*ymin/(ymax-ymin);
	
		
		for (i=0; i<numberOfPoints; i++)
		{
			xc = xData[i]; yc = yData[i];
			if (isXlog) xc = log10(xc);
			if (isYlog) yc = log10(yc);
			if ((xc>=xmin) && (xc<=xmax))
			{
				float x = rect.origin.x+rect.size.width*(xc-xmin)/(xmax-xmin);
				float y = rect.origin.y+rect.size.height*(yc-ymin)/(ymax-ymin);
				CGContextMoveToPoint(context, x, y0);
				CGContextAddLineToPoint(context, x, y);
			}
			if (++pointsInPath==5000) {
				CGContextStrokePath(context);
				pointsInPath = 0;
			}
		}
		if (pointsInPath)
			CGContextStrokePath(context);
	}
	CGColorRelease(color);
}
@end
