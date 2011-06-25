//
//  PHColor.m
//  PHGraph
//
//  Created by Pierre-Henri Jondot on 19/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHColor.h"

static CGColorSpaceRef _myGetGenericRGBSpace(void)
{
    static CGColorSpaceRef colorSpace = NULL;
    if ( colorSpace == NULL ) {
		colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    }
    return colorSpace;
}

@implementation NSColor (PHColor)
-(CGColorRef)toCGColorRef
{
	CGFloat components[4];
	[[self colorUsingColorSpaceName:@"NSCalibratedRGBColorSpace"]
		getRed:components green:components+1 blue:components+2 alpha:components+3];
	return CGColorCreate(_myGetGenericRGBSpace(),components);
}
@end
