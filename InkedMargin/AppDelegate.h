//
//  AppDelegate.h
//  InkedMargin
//
//  Created by alok pandey on 24/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>
#import "EECoreStack.h"
#import "PersistClass.h"
#import "APTextViewSubClass.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (strong, nonatomic) EECoreStack *eeCoreStack;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *mainContext;
@property (strong, nonatomic) NSManagedObjectContext *masterContext;

@property (strong, nonatomic) NSManagedObjectContext *workerContext;

@property (weak) IBOutlet NSButton *addButton;
- (void) persistInitialDataFromTextFileFromURL: (NSURL *)urlOfFile;

-(IBAction)undo:(id)sender;
-(IBAction)redo:(id)sender;

#pragma mark - array sorting
-(NSArray*)authorSortDescriptor;
-(NSArray*)highlightSortDescriptor;
-(NSArray*)bookSortDescriptor;


@end

