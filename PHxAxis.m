//
//  PHxAxis.m
//  Graph
//
//  Created by Pierre-Henri Jondot on 01/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHxAxis.h"
#import "PHColor.h"

@implementation PHxAxis
-(void)drawWithContext:(CGContextRef)context rect:(NSRect)rect
{
	if (style==0) { return;}
	NSMutableArray *ticks;
	CGColorRef color = [cocoaColor toCGColorRef];
	CGContextSetStrokeColorWithColor(context, color);
	CGContextSetFillColorWithColor(context, color);
	CGContextBeginPath(context);
	int j; 
	float wmajor=0.4, wminor=0.1;
	ticks = [[self majorTickMarks] retain];
	if (style & PHShowGrid)
	{
		CGContextSetLineWidth(context, wmajor);
		for (j=0; j < [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y);
			CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height);
		}
		CGContextStrokePath(context);
	}
	if (style & PHShowGraduationAtBottom)
	{
		CGContextSetLineWidth(context, width);
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
		CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y);
		for (j=0; j < [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y);
			if (drawOutside) {
				CGContextAddLineToPoint(context, x, rect.origin.y-5);
			} else {
				CGContextAddLineToPoint(context, x, rect.origin.y+5);
			}
			NSString *value;
			if (!(PHIsLog & style))
			{
				if (fabs(xf/majorTickWidth)<0.5)
				{ value=@"0"; } else
				{ value = [NSString stringWithFormat:@"%1.4lg",xf]; } 
			} else
				value = [NSString stringWithFormat:@"%1.4lg",pow(10,xf)]; 
			NSRect bound=[value boundingRectWithSize:rect.size options:0 attributes:attributes];
			if (drawOutside) {
				[value drawAtPoint:NSMakePoint(x-bound.size.width/2,rect.origin.y-bound.size.height-5)
					withAttributes:attributes];
			} else {
				[value drawAtPoint:NSMakePoint(x-bound.size.width/2,rect.origin.y+5)
					withAttributes:attributes];
			}
		}
		CGContextStrokePath(context);
	}
	if (style & PHShowGraduationAtTop)
	{
		CGContextSetLineWidth(context, width);
		CGContextMoveToPoint(context, rect.origin.x, rect.origin.y+rect.size.height);
		CGContextAddLineToPoint(context, rect.origin.x+rect.size.width, rect.origin.y+rect.size.height);
		for (j=0; j < [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y+rect.size.height);
			if (drawOutside) {
				CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height+5);
			} else {
				CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height-5);
			}
			NSString *value;
			if (!(PHIsLog & style))
			{
				if (fabs(xf/majorTickWidth)<0.5)
				{ value=@"0"; }
				 else
				{ value = [NSString stringWithFormat:@"%1.4lg",xf]; } 
			} else
				value = [NSString stringWithFormat:@"%1.4lg",pow(10,xf)]; 
			NSRect bound=[value boundingRectWithSize:rect.size options:0 attributes:attributes];
			if (drawOutside) {
				[value drawAtPoint:NSMakePoint(x-bound.size.width/2,rect.origin.y+rect.size.height+5)
					withAttributes:attributes];
			} else {
				[value drawAtPoint:NSMakePoint(x-bound.size.width/2,rect.origin.y+rect.size.height-bound.size.height-5)
					withAttributes:attributes];
			}
		}
		CGContextStrokePath(context);
	}
	[ticks release];
	ticks = [[self minorTickMarks] retain];
	if (style & PHShowGrid)
	{
		CGContextSetLineWidth(context, wminor);
		for (j=0; j< [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y);
			CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height);
		}
		CGContextStrokePath(context);
	}
	if (style & PHShowGraduationAtBottom)
	{
		CGContextSetLineWidth(context, width*0.5);
		for (j=0; j< [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y);
			if (drawOutside) {
				CGContextAddLineToPoint(context, x, rect.origin.y-3);
			} else {
				CGContextAddLineToPoint(context, x, rect.origin.y+3);
			}
		}
		CGContextStrokePath(context);
	}
	if (style & PHShowGraduationAtTop)
	{
		CGContextSetLineWidth(context, width*0.5);
		for (j=0; j< [ticks count]; j++)
		{
			double xf = [[ticks objectAtIndex:j] doubleValue];
			CGFloat x = rect.origin.x+(xf-minimum)/(maximum-minimum)*rect.size.width;
			CGContextMoveToPoint(context, x,rect.origin.y+rect.size.height);
			if (drawOutside) {
				CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height+3);
			} else {
				CGContextAddLineToPoint(context, x, rect.origin.y+rect.size.height-3);
			}
		}
		CGContextStrokePath(context);
	}
	[ticks release];
	CGColorRelease(color);
}	
@end
