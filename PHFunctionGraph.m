//
//  PHFunctionGraph.m
//  PHGraph
//
//  Created by Pierre-Henri Jondot on 12/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHFunctionGraph.h"
#import "PHColor.h"

@implementation PHFunctionGraph
-(id)initWithXAxis:(PHxAxis *)xaxis yAxis:(PHyAxis *)yaxis 
	function:(double (*)(double,int*))newFunction
{
	[super initWithXAxis:xaxis yAxis:yaxis];
	width = 1;
	externalFunction = newFunction;
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

-(void)setFunction:(double (*)(double,int*))newFunction
{
	externalFunction = newFunction;
}

-(void)setWidth:(float)newWidth
{
	width = newWidth;
}

-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	CGColorRef color = [cocoaColor toCGColorRef];
	CGContextSetStrokeColorWithColor(context, color);
	
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	
	CGContextBeginPath(context);
	CGContextSetLineWidth(context, width);
	BOOL isPreviousInView = NO;
	BOOL doConnect = NO;
	int isLogXAxis = [xAxis style] & PHIsLog;
	int isLogYAxis = [yAxis style] & PHIsLog;
	int flag;
	double xc,yc,xp,yp,yi,xi;
	float xInViewCoords = rect.origin.x;
	float xInViewCoordsPrec;
	float maxInViewCoords = rect.origin.x+rect.size.width;
	float step = 1;
	
	xp = xmin+(double)xInViewCoords/rect.size.width*(xmax-xmin);
	flag=0;
	if (isLogXAxis) 
		yp = externalFunction(pow(10,xp),&flag);
	else
		yp = externalFunction(xp,&flag);
	if (isLogYAxis)
		yp = log10(yp);
		
	if (!(flag) && (yp>ymin) && (yp<ymax))
	{
		doConnect = YES;
		isPreviousInView = YES;
		CGContextMoveToPoint(context, xInViewCoords, 
			rect.origin.y+(yp-ymin)/(ymax-ymin)*rect.size.height);
	}
	
	xInViewCoordsPrec = xInViewCoords;
	xInViewCoords += step;
		
	while (xInViewCoords < maxInViewCoords)
	{
		xc = xmin+(double)xInViewCoords/rect.size.width*(xmax-xmin);
		flag=0;
		if (isLogXAxis) 
			yc = externalFunction(pow(10,xc),&flag);
		else
			yc = externalFunction(xc,&flag);
		if (isLogYAxis)
			yc = log10(yc);
			
		if (flag) {
			isPreviousInView = NO;
			doConnect = NO;
			xInViewCoords += step;
		} else
		{
			xi=(xp+xc)/2;
			flag=0;
			if (isLogXAxis) 
				yi = externalFunction(pow(10,xi),&flag);
			else
				yi = externalFunction(xi,&flag);
			if (isLogYAxis)
				yi = log10(yi);
			
			if (flag) {
				doConnect=NO;
				isPreviousInView=NO;
			} else
			{
				while (((fabs((yp-2*yi+yc)/((xc-xp)))>1) || (fabs((yp-yc)/(ymax-ymin))>0.1)) && 
					(step>0.005) && (doConnect)) 
				{
					step /= 2;
					xc=xi;
					yc=yi;
					xi=(xp+xc)/2;
					xInViewCoords -= step;
				
					flag = 0;
					if (isLogXAxis) 
						yi = externalFunction(pow(10,xi),&flag);
					else
						yi = externalFunction(xi,&flag);
					if (isLogYAxis)
						yi = log10(yi);

					if (flag) {
						doConnect=NO;
						isPreviousInView=NO;
					}
				}
				if (fabs((yp-yc)/(ymax-ymin))>0.1) doConnect=NO;
				
				if ((yc>ymin) && (yc<ymax) && !(flag))
				{
					if ((isPreviousInView) && (doConnect))
					{
						CGContextAddLineToPoint(context, (float)xInViewCoords,
							rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height);
					} else
					{	
						if (doConnect)
						{
							CGContextMoveToPoint(context, xInViewCoordsPrec,
								rect.origin.y+(yp-ymin)/(ymax-ymin)*rect.size.height);
							CGContextAddLineToPoint(context, xInViewCoords,
								rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height);
						}
						else 
						{
							CGContextMoveToPoint(context, xInViewCoords,
								rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height);
						}
						isPreviousInView = YES;
					}
				} else
				{
					if ((isPreviousInView) && (doConnect))
					{
						CGContextAddLineToPoint(context, (float)xInViewCoords,
							rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height);
					}
					isPreviousInView = NO;
				}
			}
			
			step=1;
			yp=yc;xp=xc;
			xInViewCoordsPrec = xInViewCoords;
			xInViewCoords += step;
			if (!flag) doConnect=YES;
		}
	}
	CGContextStrokePath(context);
	CGColorRelease(color);
}
@end
