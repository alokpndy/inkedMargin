//
//  KindleView.m
//  InkedMargin
//
//  Created by alok pandey on 27/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "KindleView.h"
#import "MyStyleKitName.h"

@implementation KindleView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    [MyStyleKitName drawDropViewOnKindleConnectedWithFrame:self.bounds];
}

@end
