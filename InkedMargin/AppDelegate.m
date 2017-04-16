//
//  AppDelegate.m
//  InkedMargin
//
//  Created by alok pandey on 24/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "AppDelegate.h"

#import "MyStyleKitName.h"
#import "FirstTimeSyncController.h"
#import "TimeStamp.h"
#import "AP_SplitViewSubClass.h"
#import "APTableView.h"







@interface AppDelegate ()
{
    
    FirstTimeSyncController *firstTimeSyncControllerInstance;
    BOOL saveContextAppelegate;
}
@property (weak) IBOutlet NSButton *trashButton;
@property (weak) IBOutlet NSButton *favButton;

@property (assign) IBOutlet NSPopover *popOver;
@property (weak) IBOutlet NSArrayController *authorArrayController;

@property (weak) IBOutlet NSButton *allButton;
@property (weak) IBOutlet NSButton *clockButton;

@property (weak) IBOutlet NSSplitView *noteSplitView;
@property (weak) IBOutlet NSSplitView *hilightTextViewScrollView;

@property (nonatomic,strong) NSTimer* timer;
@property (unsafe_unretained) IBOutlet APTextViewSubClass *noteView;
@property (weak) IBOutlet AP_SplitViewSubClass *authorSplitView;
@property (weak) IBOutlet NSSplitView *hilightSplitView;

@property (weak) IBOutlet NSSplitView *masterSplitView;
@property (weak) IBOutlet NSTableView *authorTable;
@property (weak) IBOutlet NSSearchField *searchFiled;
@property (weak) IBOutlet APTableView *bookTable;


@end

@implementation AppDelegate
@synthesize popOver;

-(IBAction)showPopOver:(id)sender {
    [[self popOver]showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
}

#pragma mark - awakeFromNib
-(void)awakeFromNib{
    [super awakeFromNib];
    [self setUpStack];
    [self windowApperance];
    saveContextAppelegate = YES;
}


#pragma mark - check if this app is opened for first time
// if app is opened for first time/ i.e database is empty than show sheet to ask user to connect Kindle
-(void)firstLaunchOfApp{
    
    NSExpression *keyPathExpression = [NSExpression
                                       expressionForKeyPath:@"name"];
    NSExpression *countExpression = [NSExpression
                                     expressionForFunction:@"count:"
                                     arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    [countExpressionDescription setName:@"countOfAttribute"];
    [countExpressionDescription setExpression:countExpression];
    [countExpressionDescription setExpressionResultType:NSInteger16AttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Author" inManagedObjectContext:_mainContext];
    [request setEntity:entity];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:
                                   countExpressionDescription]];
    [request setResultType: NSDictionaryResultType];
    NSError *error = nil;
    NSArray *fetchResults = [_mainContext executeFetchRequest:request error:&error];
    
    NSNumber *countOfAttributes = [[fetchResults lastObject]
                                   valueForKey:@"countOfAttribute"];
    
    
    if ([countOfAttributes integerValue] == 0) {
                firstTimeSyncControllerInstance = [[FirstTimeSyncController alloc]init];
                [firstTimeSyncControllerInstance launchSheetForFisrtTime];
    }
    
}


#pragma mark - applicationDidFinishLaunching
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveNow:) name:NSManagedObjectContextObjectsDidChangeNotification object:_mainContext];
    
    
    [_window makeFirstResponder:_authorTable];
    
}

#pragma mark - Window Apperance
-(void)windowApperance{
    self.window.backgroundColor = [NSColor colorWithCalibratedWhite:0.936 alpha:1.000];
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    NSImage *imageOne = [[NSImage alloc]init];
    imageOne = [MyStyleKitName imageOfAuthorIcon];
    [imageOne setTemplate:YES];
    [_allButton setImage:imageOne];
    
    NSImage *imageTwo = [[NSImage alloc]init];
    imageTwo = [MyStyleKitName imageOfRecentelyAddedIcon];
    [imageTwo setTemplate:YES];
    [_clockButton setImage:imageTwo];
    
    NSImage *imageThree = [[NSImage alloc]init];
    imageThree = [MyStyleKitName imageOfStarSideBarIcon];
    [imageThree setTemplate:YES];
    [_trashButton setImage:imageThree];
    
    NSImage *imageFour = [[NSImage alloc]init];
    imageFour = [MyStyleKitName imageOfTrashSideBarIcon];
    [imageFour setTemplate:YES];
    [_favButton setImage:imageFour];
    
    
    [[_noteSplitView layer]setBackgroundColor:[NSColor colorWithCalibratedWhite:1.000 alpha:1.000].CGColor];
    
    [[_authorSplitView layer]setBackgroundColor:[NSColor colorWithCalibratedWhite:0.936 alpha:1.000].CGColor];
    [[_hilightSplitView layer]setBackgroundColor:[NSColor colorWithCalibratedWhite:1.00 alpha:1.000].CGColor];
    [[_hilightTextViewScrollView layer]setBackgroundColor:[NSColor colorWithCalibratedWhite:1 alpha:1.000].CGColor];
    
    [_authorTable setBackgroundColor:[NSColor colorWithCalibratedWhite:0.936 alpha:1.000]];
    [_bookTable setBackgroundColor:[NSColor colorWithCalibratedWhite:0.936 alpha:1.000]];
    
    
    
}

#pragma mark - SetupStack
-(void)setUpStack{
    __unsafe_unretained typeof(self) weakSelf = self;
    _eeCoreStack = [[EECoreStack alloc]init];
    [_eeCoreStack setUpCoreDataStackWithCallbackBlock:^{
        NSLog(@"Done adding store");
        [weakSelf addManagedObjectContext];
        
    }];
}

#pragma mark - undo manager
-(IBAction)undo:(id)sender{
    [[self mainContext] undo];
}

-(IBAction)redo:(id)sender{
    [[self mainContext] redo];
}

#pragma mark - Add managed Object Context
-(void) addManagedObjectContext{
    self.mainContext = [_eeCoreStack mainContext];
    self.masterContext = [_eeCoreStack masterContext];
    
    [self firstLaunchOfApp];
}

#pragma mark - persistInitialDataFromTextFileFromURL
- (void) persistInitialDataFromTextFileFromURL: (NSURL *)urlOfFile{
    
    saveContextAppelegate = NO;
    
    _workerContext = [_eeCoreStack createWorkerContext];
    [PersistClass persistBooksToDisk:_workerContext subClass:_eeCoreStack fromURL:urlOfFile];
    
    
}

#pragma saveNow // set timer and save main context only
-(void)saveNow: (NSNotification*)notification{
    NSLog(@"NSManagedObjectContextObjectsDidChangeNotification");
    if (saveContextAppelegate == YES) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(saveMasterTimely:) userInfo:nil repeats:NO];
        [self saveMainContext:self];
    }
}

#pragma save main context only
-(void)saveMainContext:(id)userInfo
{
    NSRange range;
    // End editing to commit the last changes
    if ( [[[self window] firstResponder] isKindOfClass:[NSTextView class]])
    {
        range = [_noteView selectedRange];
        [[NSApp keyWindow] endEditingFor: nil];
        
        // saving main context
        NSError *error = nil;
        [self.mainContext save:&error];
        if(error){
            NSLog(@"ERROR SAVING MAIN CONTEXT %@; : %@", [error localizedDescription], [error userInfo]);
        }
        // Now restore the field editor, if any.
        if (_noteView) {
            
            [[NSApp keyWindow] makeFirstResponder: _noteView];
            [_noteView setSelectedRange: range];
        }
        
    }
    
    
    // saving main context if NSTextView is not first reponder
    // two different saving is to aid Table view or NSTextVuew not loosing focus
    NSError *error = nil;
    [self.mainContext save:&error];
    if(error){
        NSLog(@"ERROR SAVING MAIN CONTEXT %@; : %@", [error localizedDescription], [error userInfo]);
    }
    
}

// to reopen app on click on dock once app has been closed
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    
    [_window makeKeyAndOrderFront:self];
    
    return YES;
}

#pragma save Master at time interval
-(void)saveMasterTimely:(id)userInfo{
    NSLog(@"timer saveMasterContext");
    [_eeCoreStack saveMasterContext];
    [_timer invalidate];
    _timer = nil;
}



-(void)startSavingFromAppDelegate:(NSNotification*)notifocation{
    saveContextAppelegate = YES;
}




#pragma mark - Array Controller Sorting

-(NSArray*)authorSortDescriptor{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}

-(NSArray*)highlightSortDescriptor{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateOfHighlight" ascending:NO]];
}

-(NSArray*)bookSortDescriptor{
    return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)]];
}



#pragma mark - makin First Respponder when cmd+option+F is pressed// action from Main Menu

-(IBAction)makeSearchFieldFirstResponder:(id)sender
{
    [_window makeFirstResponder:_searchFiled];
}


@end
