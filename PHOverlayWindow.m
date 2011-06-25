//
//  PHOverlayWindow.m
//  Graph
//
//  Created by Pierre-Henri Jondot on 05/04/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "PHOverlayWindow.h"


@implementation PHOverlayWindow
- (id)initWithContentRect:(NSRect)contentRect {
	NSWindow* borderlessWindow = [super initWithContentRect:contentRect 
		styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	[borderlessWindow setBackgroundColor: [NSColor blackColor]];
	[borderlessWindow setLevel: NSStatusWindowLevel];
	[borderlessWindow setAlphaValue:0.2];
	[borderlessWindow setOpaque:NO];
	return borderlessWindow;
}


@end
