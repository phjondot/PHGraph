//
//  PHVectorField.m
//  GraphTest
//
//  Created by Pierre-Henri Jondot on 16/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHVectorField.h"

@implementation PHVectorField

-(id)initWithXAxis:(PHxAxis*)xaxis yAxis:(PHyAxis*)yaxis
		  function:(int (*)(double,double,double*,double*))aFunction
{
	[super initWithXAxis:xaxis yAxis:yaxis];
	width = 1;
	externalFunction = aFunction;
	xGrid = 20;
	yGrid = 20;
	cocoaColor = [[NSColor blackColor] retain];
	multiColor = NO;
	return self;
}

-(void)dealloc
{
	[cocoaColor release];
	[super dealloc];
}

-(void)setFunction:(int (*)(double,double,double*,double*))newFunction
{
	externalFunction = newFunction;
}

-(void)setColorFunction:(void (*)(double,double,float*,float*,float*,float*))newFunction
{
	colorFunction = newFunction;	
	multiColor = YES;
}

	
-(void)setColor:(NSColor *)newColor
{
	[newColor retain];
	[cocoaColor release];
	cocoaColor = newColor;
	multiColor = NO;
}

-(void)setWidth:(float)newWidth
{
	width = newWidth;
}

-(void)setXGrid:(int)newXgrid yGrid:(int)newYgrid
{
	if ((newXgrid>0) && (newXgrid<500))
		xGrid = newXgrid;
	if ((newYgrid>0) && (newYgrid<500))
		yGrid = newYgrid;
}
	
-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	//do nothing if one of the axis has a logarithmic scale
	if (([xAxis style] & PHIsLog) || ([yAxis style] & PHIsLog)) return;
	
	if (multiColor == NO)
	{
		[cocoaColor set];
	}
	NSBezierPath* aPath = [NSBezierPath bezierPath];
	[aPath setLineWidth:width];
	
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	
	double maxXsize = rect.size.width/xGrid;
	double maxYsize = rect.size.height/yGrid;
	//something must be done when axis are not orthonormal
	double yOverXRatio = (double)rect.size.height/rect.size.width;
	
	double maxLength = sqrt(maxXsize*maxXsize+maxYsize*maxYsize)*0.68;
	double xvalues[xGrid][yGrid];
	double yvalues[xGrid][yGrid];
	int flag[xGrid][yGrid];
	int i,j;
	double maxDataLength = 0;
	for (i=0; i<xGrid; i++)
	{
		double x = xmin + ((double)i+0.5)*(xmax-xmin)/(double)xGrid;
		for (j=0; j<yGrid; j++)
		{
			double y = ymin + ((double)j+0.5)*(ymax-ymin)/(double)yGrid;
			flag[i][j] = externalFunction(x,y,&xvalues[i][j],&yvalues[i][j]);
			if (flag[i][j]==0)
			{
				xvalues[i][j] /= xmax-xmin;
				yvalues[i][j] *= yOverXRatio/(ymax-ymin);
				double currentLength = xvalues[i][j]*xvalues[i][j]+yvalues[i][j]*yvalues[i][j];
				if (currentLength>maxDataLength)
					maxDataLength=currentLength;
			}
		}
	}
	if (maxDataLength==0) return;
		else maxDataLength=sqrt(maxDataLength);
	for (i=0; i<xGrid; i++)
	{
		for (j=0; j<yGrid; j++)
		{
			float xLength = xvalues[i][j]/maxDataLength;
			float yLength = yvalues[i][j]/maxDataLength;
			float currentLength = sqrt(xLength*xLength+yLength*yLength);
			xLength *= maxLength*(1+3*pow(1-currentLength,3));
			yLength *= maxLength*(1+3*pow(1-currentLength,3));
			
			float xCenter = rect.origin.x+((double)i+0.5)/(double)xGrid*rect.size.width;
			float yCenter = rect.origin.y+((double)j+0.5)/(double)yGrid*rect.size.height;
			
			if ((multiColor == YES) && (flag[i][j] == 0))
			{
				float red, green, blue, alpha;
				colorFunction(xmin + ((double)i+0.5)*(xmax-xmin)/(double)xGrid,
					 ymin + ((double)j+0.5)*(ymax-ymin)/(double)yGrid,&red, &green, &blue, &alpha);
				
				NSColor *color = [NSColor colorWithCalibratedRed:red green:green blue:blue
					alpha:alpha] ;
				[color set];
			}
			
			if (flag[i][j] == 0)
			{
				[aPath moveToPoint:NSMakePoint(xCenter-xLength/2, yCenter-yLength/2)];
				[aPath lineToPoint:NSMakePoint(xCenter+xLength/2,yCenter+yLength/2)];
				[aPath stroke];
				[aPath removeAllPoints];
				
				[aPath moveToPoint:NSMakePoint(xCenter+xLength/2,yCenter+yLength/2)];
				[aPath lineToPoint:NSMakePoint(xCenter+xLength*(0.5-0.28)-0.14*yLength,
					yCenter+yLength*(0.5-0.28)+0.14*xLength)];
				[aPath lineToPoint:NSMakePoint(xCenter+xLength*(0.5-0.14),
					yCenter+yLength*(0.5-0.14))];
				[aPath lineToPoint:NSMakePoint(xCenter+xLength*(0.5-0.28)+0.14*yLength,
					yCenter+yLength*(0.5-0.28)-0.14*xLength)];
				[aPath closePath];
				[aPath fill];
				[aPath removeAllPoints];
			}
		}
	}
}

@end
