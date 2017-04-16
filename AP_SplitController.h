//
//  AP_SplitController.h
//  InkedMargin
//
//  Created by alok pandey on 30/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface AP_SplitController : NSObject <NSSplitViewDelegate, NSWindowDelegate>
@property (weak) IBOutlet NSSplitView *masterSplitView;
@property (weak) IBOutlet NSSplitView *authorSplitView;

@end
