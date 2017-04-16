//
//  FirstTimeSyncController.m
//  InkedMargin
//
//  Created by alok pandey on 16/02/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "FirstTimeSyncController.h"
#import "SyncController.h"

@interface FirstTimeSyncController()
{
    SyncController *syncControllerInstance;
}

@end


@implementation FirstTimeSyncController
@synthesize emptyDatabaseWindow = _emptyDatabaseWindow;


-(void)awakeFromNib{
    [super awakeFromNib];
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector: @selector(volumesChanged:)
                                                               name:NSWorkspaceDidMountNotification
                                                             object: nil];
    
    
}




#pragma mark - Volume Changed method
-(void) volumesChanged: (NSNotification*) notification
{   NSLog(@"Volume changed in FisrtTimeSync");
    if (!syncControllerInstance) {
        syncControllerInstance = [[SyncController alloc]init];
    }
    if ([self checkIfFIleExistInKindle]) {
        [[NSApp mainWindow] endSheet:_emptyDatabaseWindow];
    }
    
//    [[[NSWorkspace sharedWorkspace]notificationCenter] removeObserver:self name:NSWorkspaceDidMountNotification object:nil];
}


-(void) launchSheetForFisrtTime{
    [[NSBundle mainBundle] loadNibNamed:@"EmptyDatabaseView" owner:self topLevelObjects:nil];
    [[[NSApp windows]firstObject] beginSheet:self.emptyDatabaseWindow completionHandler:nil];
}


#pragma mark - getFileURLFromKindle
-(NSURL *) getFileURLFromKindle
{
    
    NSArray *keys = [NSArray arrayWithObjects:NSURLVolumeNameKey, NSURLVolumeIsRemovableKey, nil];
    NSArray *urls = [[NSFileManager defaultManager] mountedVolumeURLsIncludingResourceValuesForKeys:keys options:0];
    NSURL *kindleURL;
    for (NSURL *url in urls) {
        NSError *error;
        NSNumber *isRemovable;
        NSString *volumeName;
        [url getResourceValue:&isRemovable forKey:NSURLVolumeIsRemovableKey error:&error];
        if ([isRemovable boolValue]) {
            [url getResourceValue:&volumeName forKey:NSURLVolumeNameKey error:&error];
            if ([[url absoluteString] containsString:@"Kindle"]) {
                kindleURL = url;
            }
        }
    }
    NSURL *fullURL = [kindleURL URLByAppendingPathComponent:@"documents/My Clippings.txt"];
    
    return fullURL;
}


#pragma mark - checkIfURLExist
-(BOOL) checkIfFIleExistInKindle
{
    if ([[NSFileManager defaultManager]fileExistsAtPath:[[self getFileURLFromKindle] path]]) {
        return YES;
    }
    return NO;
}



@end
