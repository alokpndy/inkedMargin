//
//  FirstTimeSyncController.h
//  InkedMargin
//
//  Created by alok pandey on 16/02/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface FirstTimeSyncController : NSObject
@property (strong) IBOutlet NSWindow *emptyDatabaseWindow;

-(void) launchSheetForFisrtTime;
@end
