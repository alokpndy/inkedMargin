//
//  DragController.h
//  InkedMargin
//
//  Created by alok pandey on 26/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "KindleView.h"


@interface SyncController : NSObject
@property (weak) IBOutlet NSWindow *sheetWindow;
@property (weak) IBOutlet KindleView *kindleView;

-(void)showAlert;
@end
