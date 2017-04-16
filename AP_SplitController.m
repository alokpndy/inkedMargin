//
//  AP_SplitController.m
//  InkedMargin
//
//  Created by alok pandey on 30/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "AP_SplitController.h"

@implementation AP_SplitController



-(BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex{
    return  YES;
}


-(void)splitViewWillResizeSubviews:(NSNotification *)notification{
    NSWindow *window = [NSApp windows][0];
    NSLog(@"Windows frame is %f", window.frame.size.width);
    NSView *authorSubView = [[_masterSplitView subviews]objectAtIndex:0];
    NSView *bookAndHighlightSubView = [[_masterSplitView subviews]objectAtIndex:1];
    NSView *noteSubView = [[_masterSplitView subviews]objectAtIndex:3];
    
    CGFloat windowsWidth = window.frame.size.width;
    
    if (windowsWidth < 1033) {
        [authorSubView setHidden:YES];
    }
    if (windowsWidth > 1033) {
        [authorSubView setHidden:NO];
        

    }
    
    
    if (windowsWidth < 850) {
        [bookAndHighlightSubView setHidden:YES];
    }
    if (windowsWidth > 850) {
        [bookAndHighlightSubView setHidden:NO];

    }
    
    if (windowsWidth < 570) {
        [noteSubView setHidden:YES];
       
    }
    if (windowsWidth > 570) {
        [noteSubView setHidden:NO];
  
    }
}




@end
