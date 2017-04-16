//
//  HighlightTableController.h
//  InkedMargin
//
//  Created by alok pandey on 24/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "APTextViewSubClass.h"



@interface HighlightTableController : NSObject <NSTableViewDataSource, NSTableViewDelegate, NSMenuDelegate>
@property (weak) IBOutlet NSTableView *highlightTableView;


@property (weak) IBOutlet NSArrayController *authorArrayController;
@property (weak) IBOutlet NSArrayController *bookArrayController;
@property (weak) IBOutlet NSArrayController *highlightArrayController;

@property (weak) IBOutlet NSTextField *authorCount;
@property (weak) IBOutlet NSTextField *bookCount;
@property (weak) IBOutlet NSTextField *highlightCount;
@property (weak) IBOutlet NSTableView *authorTable;

@property (weak) IBOutlet NSPopover *popOver;

@property (unsafe_unretained) IBOutlet APTextViewSubClass *noteView;

@property (weak) IBOutlet NSMenu *menu;
@property (weak) IBOutlet NSMenuItem *menuItem;
@property (weak) IBOutlet NSMenuItem *deleteFromMainMenu;


@property (weak) IBOutlet NSTableView *bookTable;


@property (weak) IBOutlet NSSplitView *noteSplitView;


@property (weak) IBOutlet NSButton *favoriteButtonDummy;
@property (weak) IBOutlet NSButton *favoriteButtonBound;
@property (weak) IBOutlet NSArrayController *noteArrayController;



@property (weak) IBOutlet NSButton *allButton;
@property (weak) IBOutlet NSButton *clockButton;
@property (weak) IBOutlet NSButton *favButon;
@property (weak) IBOutlet NSButton *trashButton;

@property (weak) IBOutlet NSSearchField *searchField;



-(void) allBooksPredicate;

@end
