//
//  APTableView.m
//  InkedMargin
//
//  Created by alok pandey on 01/02/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "APTableView.h"

@implementation APTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


// to dsiabletable separator for empty row at end of filled rows
- (void)drawGridInClipRect:(NSRect)clipRect
{
    
    NSRect lastRowRect = [self rectOfRow:[self numberOfRows]];
    NSRect myClipRect = NSMakeRect(100, 0, lastRowRect.size.width, NSMaxY(lastRowRect));
    
    [super drawGridInClipRect:myClipRect];
}




@end
