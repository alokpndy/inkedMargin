//
//  EmptyViewDrawing.m
//  InkedMargin
//
//  Created by alok pandey on 15/02/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "EmptyViewDrawing.h"
#import "MyStyleKitName.h"

@implementation EmptyViewDrawing

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [MyStyleKitName drawEmptyDatabaseView];
}

@end
