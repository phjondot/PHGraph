//
//  PHParametricCurve.m
//  PHGraph
//
//  Created by Pierre-Henri Jondot on 15/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHParametricCurve.h"
#import "PHColor.h"

BOOL intersectBorder(double xc,double yc, double xp, double yp, double xmin, double ymin, double
	xmax, double ymax)
{
	if (((yp-ymin)*(yc-ymin)<0) &&
			(((yp-yc)*(xmin-xc)+(xc-xp)*(ymin-yc))*((yp-yc)*(xmax-xc)+(xc-xp)*(ymin-yc))<0))
				{ return YES; }
	else
		if (((xmax-xc)*(xmax-xp)<0) &&
			(((yp-yc)*(xmax-xc)+(xc-xp)*(ymin-yc))*((yp-yc)*(xmax-xc)+(xc-xp)*(ymax-yc))<0))
				{return YES; }
		else
			if (((ymax-yc)*(ymax-yp)<0) &&
				(((yp-yc)*(xmax-xc)+(xc-xp)*(ymax-yc))*((yp-yc)*(xmin-xc)+(xc-xp)*(ymax-yc))<0))
				{ return YES; }
			else
				if (((xp-xmin)*(xc-xmin)<0) &&
					(((yp-yc)*(xmin-xc)+(xc-xp)*(ymax-yc))*((yp-yc)*(xmin-xc)+(xc-xp)*(ymin-yc))<0))
					{ return YES; }
	
	return NO;
}


@implementation PHParametricCurve
-(id)initWithXAxis:(PHxAxis*)xaxis yAxis:(PHyAxis*)yaxis
	function:(int (*)(double,double*,double*))aFunction
	tmin:(double)valueTmin tmax:(double)valueTmax
{
	[super initWithXAxis:xaxis yAxis:yaxis];
	width = 1;
	minimumNumberOfPoints = 200;
	externalFunction = aFunction;
	tmin = valueTmin;
	tmax = valueTmax;
	adaptive = 5;
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

-(void)setFunction:(int (*)(double,double*,double*))newFunction
{
	externalFunction = newFunction;
}

-(void)setTmin:(double)newTmin
{
	if (newTmin < tmax)
		tmin = newTmin;
}

-(void)setTmax:(double)newTmax
{
	if (newTmax > tmin)
		tmax = newTmax;
}

-(void)setTmin:(double)newTmin tmax:(double)newTmax
{
	if (newTmin<newTmax)
	{
		tmin = newTmin;
		tmax = newTmax;
	}
}

-(void)setWidth:(float)newWidth
{
	width = newWidth;
}

-(void)setMinimumNumberOfPoints:(int)npoints
{
	minimumNumberOfPoints = npoints;
}

-(void)setAdaptive:(int)maxSubdivision
{
	adaptive = maxSubdivision;
}

-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	CGColorRef color = [cocoaColor toCGColorRef];
	CGContextSetStrokeColorWithColor(context, color);
	
	double xmin = [xAxis minimum];
	double xmax = [xAxis maximum];
	double ymin = [yAxis minimum];
	double ymax = [yAxis maximum];
	double maxStep = (tmax-tmin)/minimumNumberOfPoints;
	
	CGContextBeginPath(context);
	CGContextSetLineWidth(context, width);
	BOOL isPreviousInView = NO;
	BOOL isCurrentInView = NO;
	BOOL doConnect = NO;
	int isLogXAxis = [xAxis style] & PHIsLog;
	int isLogYAxis = [yAxis style] & PHIsLog;
	int flag;
	double tp = tmin, ti, tc, xc, yc, xp, yp, xi, yi;
	flag = externalFunction(tp, &xp, &yp);
	if (isLogXAxis) xp = log10(xp);
	if (isLogYAxis) yp = log10(yp);
	if ((!flag) && ((xp-xmin)/(xmax-xmin) > -1) && ((xp-xmin)/(xmax-xmin) < 2) &&
				((yp-ymin)/(ymax-ymin) > -1 ) && ((yp-ymin)/(ymax-ymin) < 2))
	{
		doConnect = YES;
		if ((xp > xmin) && (xp < xmax) && (yp > ymin) && (yp < ymax))
		{
			isPreviousInView = YES;
			CGContextMoveToPoint(context, rect.origin.x+(xp-xmin)/(xmax-xmin)*rect.size.width, 
				rect.origin.y+(yp-ymin)/(ymax-ymin)*rect.size.height);
		} 
	}
	tc = tp+maxStep;
	
	do
	{
		if (tc>tmax) tc=tmax;
		flag = externalFunction(tc,&xc,&yc);
		if (isLogXAxis) xc = log10(xc);
		if (isLogYAxis) yc = log10(yc);
		
		if (flag) {
			isPreviousInView = NO;
			doConnect = NO;
		} else
		{
			int numberOfSteps = 0;
			BOOL reduceStep=YES;
			if ((xc<xmin) || (xc>xmax) || (yc<ymin) || (yc>ymax)) isCurrentInView = NO;
				else isCurrentInView = YES;
				
			if ((isPreviousInView==NO) && (isCurrentInView==NO))
			{
				reduceStep=intersectBorder(xp,yp,xc,yc,xmin,ymin,xmax,ymax);
			}
					
					
			while ((reduceStep) && (numberOfSteps<adaptive))
			{
				reduceStep = NO;
				
				ti=(tc+tp)/2;
			
				flag = externalFunction(ti, &xi, &yi);
				if (flag) {
					doConnect = NO;
					isCurrentInView = NO;
					break;
				}
				if (isLogXAxis) xi = log10(xi);
				if (isLogYAxis) yi = log10(yi);
					
				BOOL isIntermediateInView;
				if ((xi<xmin) || (xi>xmax) || (yi<ymin) || (yi>ymax))
					isIntermediateInView = NO;
					else isIntermediateInView = YES;
				
				if (((fabs((xp-xc)/(xmax-xmin))>0.05) || (fabs(yp-yc)/(ymax-ymin))>0.05))
					reduceStep = YES;
				else if (fabs((xi-xp)*(yc-yi)-(xc-xi)*(yi-yp))>0.01*((xc-xp)*(xc-xp)+(yc-yp)*(yc-yp)))
					reduceStep = YES;

				if (reduceStep)
				{
					if ((isPreviousInView == NO) && 
						(intersectBorder(xp,yp,xi,yi,xmin,ymin,xmax,ymax) == NO))
					{
						tp = ti;
						numberOfSteps++;
						xp = xi; yp = yi,
						isPreviousInView = isIntermediateInView;
					} else
					{
						tc = ti;
						numberOfSteps++;
						xc = xi; yc = yi;
						isCurrentInView = isIntermediateInView;
					}
				}
			
				if ((!(isCurrentInView)) || (flag))
				{
					if ((isPreviousInView) && (doConnect))
					{
						float xInViewc = rect.origin.x+(xc-xmin)/(xmax-xmin)*rect.size.width;
						float yInViewc = rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height;
						CGContextAddLineToPoint(context, xInViewc, yInViewc);
					}
				}
				else
				{
					float xInViewc = rect.origin.x+(xc-xmin)/(xmax-xmin)*rect.size.width;
					float yInViewc = rect.origin.y+(yc-ymin)/(ymax-ymin)*rect.size.height;
				
					if ((isPreviousInView) && (doConnect))
					{
						CGContextAddLineToPoint(context, xInViewc, yInViewc);
					}
					else
					{
						if (doConnect)
						{
							float xInViewp = rect.origin.x+(xp-xmin)/(xmax-xmin)*rect.size.width;
							float yInViewp = rect.origin.y+(yp-ymin)/(ymax-ymin)*rect.size.height;
							CGContextMoveToPoint(context, xInViewp, yInViewp);
							CGContextAddLineToPoint(context, xInViewc, yInViewc);
						}
						else
						{
							CGContextMoveToPoint(context, xInViewc, yInViewc);
						}
					}
				}
				doConnect = YES;
			}
		}
		isPreviousInView = isCurrentInView;
		tp = tc;
		xp = xc;
		yp = yc;
		tc += maxStep;
	}
	while (tc<tmax+maxStep);
	CGContextStrokePath(context);
	CGColorRelease(color);
}

@end
