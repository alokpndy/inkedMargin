//
//  DragController.m
//  InkedMargin
//
//  Created by alok pandey on 26/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "SyncController.h"
#import "PersistClass.h"
#import "AppDelegate.h"


@interface SyncController()
{
    NSAlert *warningAlert;
    NSAlert *alert;
}

@end

@implementation SyncController
@synthesize sheetWindow = _sheetWindow;
#pragma mark - save Operation

-(void) saveFromURL: (NSURL *)url{
    AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appDelegate persistInitialDataFromTextFileFromURL:url];
    if (alert) {
        [[NSApp mainWindow] endSheet:alert.window];
    }
}

-(void)awakeFromNib{
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissSheet:)
                                                 name:@"doneSavingMainContext"
                                               object:nil];
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self
                                                           selector: @selector(volumesChanged:)
                                                               name:NSWorkspaceDidMountNotification
                                                             object: nil];
}


#pragma mark - Volume Changed method
-(void) volumesChanged: (NSNotification*) notification
{   NSLog(@"Volume changed in SYNC Controller");
    if ([self checkIfFIleExistInKindle]) {
        [self showAlert];
    }
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



//////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - sheet logic

-(void) dismissSheet:(id)sender{
    [[NSApp mainWindow] endSheet:_sheetWindow];
}


#pragma mark - Sheet Action
-(void)showSheet{
    [[NSBundle mainBundle] loadNibNamed:@"SyncingProgress" owner:self topLevelObjects:nil];
    [[[NSApp windows]firstObject] beginSheet:self.sheetWindow completionHandler:nil];
}


#pragma mark - showAlertWhenKindleDetected
-(void)showAlert
{
    if (alert == nil) {
        alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Kindle detected. Do you want to add new highlights."];
        [alert setInformativeText:@"Open MY Clipping.txt file when Finder opens"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Ok"];
    }
    
    [alert beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == 1001) {
            //Ok
            [[NSApp mainWindow] endSheet:self->alert.window];
            [self syncButtonAction:self];
        }else if (returnCode == 1000) {
            [[NSApp mainWindow] endSheet:self->alert.window];
        }
    }];
}

#pragma mark - show alert when Kindle is not connected
-(void)showCriticalAlertWhenKindleNotDected
{
    warningAlert = [[NSAlert alloc] init];
    [warningAlert setMessageText:@"Please connect your Kindle"];
    [warningAlert setInformativeText:@"Try reconnecting your Kindle"];
    [warningAlert addButtonWithTitle:@"Ok"];
    [warningAlert setAlertStyle:NSWarningAlertStyle];
    
    AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [warningAlert beginSheetModalForWindow:appDelegate.window completionHandler:^(NSModalResponse returnCode) {
        // will add logic if needed later
    }];
}


- (IBAction)syncButtonAction:(id)sender {
    
    if ([self checkIfFIleExistInKindle]) {
        [self openSavePanel];
        
    }else{
        [self showCriticalAlertWhenKindleNotDected];
    }
    
}




#pragma mark - show alert when Kindle is not connected
-(void)showCriticalAlertWhenUserSelectedFileIsWrong
{
     NSAlert *wrongFileAlert = [[NSAlert alloc] init];
    [wrongFileAlert setMessageText:@"Oops! You have selected wrong file."];
    [wrongFileAlert setInformativeText:@"Try selecting MY Clipping.txt"];
    [wrongFileAlert addButtonWithTitle:@"Try Again"];
    [wrongFileAlert setAlertStyle:NSCriticalAlertStyle];
    
    AppDelegate *appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [wrongFileAlert beginSheetModalForWindow:appDelegate.window completionHandler:^(NSModalResponse returnCode) {
         if (returnCode == 1000) {
             [self openSavePanel];
        }
    }];
}



#pragma mark - open NSOpenPanel
-(void) openSavePanel{
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"txt", nil];
    
    [openPanel setAllowsMultipleSelection: NO];
    [openPanel setCanChooseDirectories:NO];
    [openPanel setCanCreateDirectories:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setAllowedFileTypes:fileTypes];
    [openPanel setMessage:@"Please open My Clipping.txt file"];
    [openPanel setDirectoryURL:[self getFileURLFromKindle]];
    
    // Show the open panel and process the results.
    [openPanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result){
        if (result == NSFileHandlingPanelOKButton) {
            NSURL*  selectedFileUrl = [[openPanel URLs] objectAtIndex:0];
            
            // case when file selected by user is not MY Clipping.txt
            if (![[self getFileURLFromKindle] isEqual:selectedFileUrl]){
             
                [self showCriticalAlertWhenUserSelectedFileIsWrong];
            }
            
            
            
            // now match url to Kindle saved url// Incase user selected another text file
            if ([[self getFileURLFromKindle] isEqual:selectedFileUrl]){
                [self saveFromURL:[self getFileURLFromKindle]];
                if (!self.sheetWindow) {
//                    [self showSheet];
                }

            }
            
        }
    }];
    
}

@end
