//
//  HighlightTableController.m
//  InkedMargin
//
//  Created by alok pandey on 24/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "HighlightTableController.h"
#import "APTableCellView.h"
#import "Highlight.h"

#import "AppDelegate.h"


#import "Book.h"
#import "Author.h"
#import "Highlight.h"


@interface HighlightTableController()
{
    BOOL showAnimationWhenUnfavorites;
}

@end


@implementation HighlightTableController


-(void)awakeFromNib{
    [super awakeFromNib];
    
    // setting note text view font
    _authorArrayController.avoidsEmptySelection = YES;
    [_authorArrayController addObserver:self forKeyPath:@"selectedObjects" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
    
    
    // setting font size of NSTextView for user Note
    [_noteView setFont:[NSFont systemFontOfSize:13]];
    [_favoriteButtonDummy setImage: [NSImage imageNamed:@"heart"]];
    [_favoriteButtonBound setImage: [NSImage imageNamed:@"emptyHeart"]];
    showAnimationWhenUnfavorites = NO;
    
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)
object change:(NSDictionary *)change context:(void *)context
{
    // observe for change in authorArrayController selectionObject, than find if NSSearchField is active// if than set selection of Tbale to 0th row
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    if ([firstResponder isKindOfClass:[NSText class]] && [(id)firstResponder delegate] == _searchField) {
        // this is to check if first responder is _searchField // if yes than only set row to 0th position
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
        [_authorTable selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    
    
}



#pragma mark - Main Menu Action
-(IBAction)resetNoteFontToDefault:(id)sender
{
    [_noteView setFont:[NSFont systemFontOfSize:13]];
}
- (IBAction)moveToTrashFromMenuBar:(id)sender {
    NSArray *selectedHilights = [_highlightArrayController selectedObjects];
    
    [_highlightArrayController willChangeValueForKey:@"markHighlightToDelete"];
    
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
        context.allowsImplicitAnimation = YES;
        [_highlightTableView removeRowsAtIndexes:_highlightTableView.selectedRowIndexes withAnimation:NSTableViewAnimationEffectFade];
    } completionHandler:^{
        
        for (Highlight *highlight in selectedHilights) {
            [highlight setHighlightToDeleteOrPutBack];
        }
        [self->_authorArrayController rearrangeObjects];
        [self->_bookArrayController rearrangeObjects];
        [self->_highlightArrayController rearrangeObjects];
    }];
    [_highlightArrayController didChangeValueForKey:@"markHighlightToDelete"];
    
}

#pragma mark - add to trash  // NSMenu item action
- (IBAction)markHighlightToDelete:(id)sender {
    
    [self moveToTrashFromMenuBar:self];
}


#pragma mark = favorite // change value to @1
- (IBAction)favByttonDummyAction:(id)sender {
    Highlight *hilight = [_highlightArrayController arrangedObjects][[_highlightTableView selectedRow]];
    [_highlightArrayController willChangeValueForKey:@"isHighlightFavourite"];
    
    if ( showAnimationWhenUnfavorites == YES) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context){
            context.allowsImplicitAnimation = YES;
            [_highlightTableView removeRowsAtIndexes:_highlightTableView.selectedRowIndexes withAnimation:NSTableViewAnimationEffectFade];
        } completionHandler:^{ [hilight setHighlightAsNotFavorite];
            [self->_highlightArrayController rearrangeObjects];
            [self->_bookArrayController rearrangeObjects];
            [self->_authorArrayController rearrangeObjects];}];
        
    }else{
        [hilight setHighlightAsNotFavorite];
        [_highlightArrayController rearrangeObjects];
        [_bookArrayController rearrangeObjects];
        [_authorArrayController rearrangeObjects];
        
    }
    
    
    [_highlightArrayController didChangeValueForKey:@"isHighlightFavourite"];
}

#pragma mark - change fave to @0 // cheating // clicking on back buttom
- (IBAction)favButtonBoundAction:(id)sender {
    Highlight *hilight = [_highlightArrayController arrangedObjects][[_highlightTableView selectedRow]];
    [_highlightArrayController willChangeValueForKey:@"isHighlightFavourite"];
    [hilight setHighlightAsFavorite];
    [_highlightArrayController rearrangeObjects];
    [_bookArrayController rearrangeObjects];
    [_authorArrayController rearrangeObjects];;
    [_highlightArrayController didChangeValueForKey:@"isHighlightFavourite"];
}



#pragma mark - table view delegate-----------------------------------------

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    _authorCount.stringValue = [NSString stringWithFormat:@"AUTHORS %lu", [[[_authorArrayController arrangedObjects]valueForKey:@"name"]count]];
    _bookCount.stringValue = [NSString stringWithFormat:@"BOOKS %lu", [[[_bookArrayController arrangedObjects]valueForKey:@"title"]count]];
    _highlightCount.stringValue = [NSString stringWithFormat:@"Highlights %lu", [[[_highlightArrayController arrangedObjects]valueForKey:@"body"]count]];
    
    if (tableView == _highlightTableView ) {
        Highlight *highlight = [_highlightArrayController arrangedObjects][row];
        
        if ([highlight.markHighlightToDelete  isEqual: @0]) {
            _menuItem.title = @"Move to Trash";
            [_deleteFromMainMenu setEnabled:YES];
            [_deleteFromMainMenu setHidden:NO];
            _deleteFromMainMenu.title = @"Move to Trash";
        }else{
            [_deleteFromMainMenu setHidden:YES];
            _menuItem.title = @"Put back";
        }
        
        
        APTableCellView *cellView = [_highlightTableView makeViewWithIdentifier:@"highlightGroup" owner:self];
        NSImage *image = [[NSImage alloc]init];
        image = [NSImage imageNamed:@"heart"];
        [image setTemplate:YES];
        [cellView.favImageView setImage:image];
        
        return cellView;
    }
    
    
    
    
    
    return nil;
}





#pragma mark - heightOfRow
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    if (tableView == _highlightTableView) {
        return 82;
    }
    return [tableView rowHeight];
}


#pragma mark - soertButtons

-(IBAction)sortButton:(id)sender
{
    if (sender == _allButton) {
        [self allBooksPredicate];
        //         _menuItem.hidden = NO;
        [_clockButton setState:NSOffState];
        [_favButon setState:NSOffState];
        [_trashButton setState:NSOffState];
        showAnimationWhenUnfavorites = NO;
        [self selectTablelIfNoRowIsSelectedOnChanignFilter];
        
        
        
        
        
    }else if (sender == _clockButton){
        [self recentlyAddedPredicate];
        //         _menuItem.hidden = NO;
        [_allButton setState:NSOffState];
        [_favButon setState:NSOffState];
        [_trashButton setState:NSOffState];
        showAnimationWhenUnfavorites = NO;
        
        [self selectTablelIfNoRowIsSelectedOnChanignFilter];
        
        
        
    }else if (sender == _favButon){
        [self favoritePredicate];
        //         _menuItem.hidden = YES;
        [_allButton setState:NSOffState];
        [_clockButton setState:NSOffState];
        [_trashButton setState:NSOffState];
        showAnimationWhenUnfavorites = NO;
        [self selectTablelIfNoRowIsSelectedOnChanignFilter];
        
        
        
    }else if (sender == _trashButton){
        [self trashPredicate];
        //         _menuItem.hidden = NO;
        [_allButton setState:NSOffState];
        [_clockButton setState:NSOffState];
        [_favButon setState:NSOffState];
        showAnimationWhenUnfavorites = YES;
        [self selectTablelIfNoRowIsSelectedOnChanignFilter];
        
        
    }
}



-(void)selectTablelIfNoRowIsSelectedOnChanignFilter
{
    if (_highlightTableView.selectedRow < 0) {
        if ([[_highlightArrayController arrangedObjects]count] >= 1) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [_highlightTableView selectRowIndexes:indexSet byExtendingSelection:NO];
            
        }
    }
    
    
    if (_bookTable.selectedRow < 0) {
        if ([[_bookArrayController arrangedObjects]count] >= 1) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [_bookTable selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }
    
    if (_authorTable.selectedRow < 0) {
        if ([[_authorArrayController arrangedObjects]count] >= 1) {
            NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:0];
            [_authorTable selectRowIndexes:indexSet byExtendingSelection:NO];
        }
    }
    
    // scrolling tableview to slected object// when switching b/w filter buttons/ the selected object at which is at top in othe filter may become invisible when switching to othet filtered button// so if selectionis not visible make it visible.
    [_authorTable scrollRowToVisible:_authorArrayController.selectionIndex];
    [_bookTable scrollRowToVisible:_bookArrayController.selectionIndex];
    [_highlightTableView scrollRowToVisible:_highlightArrayController.selectionIndex];
    
}

#pragma mark - Predicate

-(void) allBooksPredicate{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(booksByAuthor, $x, ANY $x.highlightsInBook.markHighlightToDelete = NO).@count != 0"];
    [_authorArrayController setFilterPredicate:predicate];
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"SUBQUERY(highlightsInBook, $highlight, $highlight.markHighlightToDelete = NO) .@count > 0"];
    [_bookArrayController setFilterPredicate:predicateTwo];
    [_highlightArrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"markHighlightToDelete = NO "]];
}

-(void) trashPredicate
{
    [_highlightArrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"markHighlightToDelete = YES"]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(booksByAuthor, $x, ANY $x.highlightsInBook.markHighlightToDelete = YES).@count != 0"];
    [_authorArrayController setFilterPredicate:predicate];
    
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"SUBQUERY(highlightsInBook, $highlight, $highlight.markHighlightToDelete = YES) .@count > 0"];
    [_bookArrayController setFilterPredicate:predicateTwo];
}

-(void) favoritePredicate
{
    
    [_highlightArrayController setFilterPredicate:[NSPredicate predicateWithFormat:@"isHighlightFavourite == YES && markHighlightToDelete == NO"]];
    
    ///......... Problem filtering deleted object in fav tab
    
    NSPredicate *predicateTwo = [NSPredicate predicateWithFormat:@"SUBQUERY(highlightsInBook, $highlight, $highlight.isHighlightFavourite == YES && $highlight.markHighlightToDelete == NO) .@count > 0"];
    [_bookArrayController setFilterPredicate:predicateTwo];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(booksByAuthor, $x, ANY $x.highlightsInBook.isHighlightFavourite == YES ).@count != 0"];
    [_authorArrayController setFilterPredicate:predicate];
    
}

-(void) recentlyAddedPredicate{
    
    // last 7 days
    NSDate *dateOnLastWeek = [[NSDate date] dateByAddingTimeInterval:-7*24*60*60];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SUBQUERY(booksByAuthor, $x, ANY $x.highlightsInBook.dateOfHighlight >= %@).@count > 0", dateOnLastWeek];
    [_authorArrayController setFilterPredicate:predicate];
    
    NSPredicate *predicateOnBook = [NSPredicate predicateWithFormat:@"SUBQUERY(highlightsInBook, $highlight, $highlight.dateOfHighlight >= %@).@count > 0", dateOnLastWeek];
    [_bookArrayController setFilterPredicate:predicateOnBook];
    
    NSPredicate *predicateOnHilight = [NSPredicate predicateWithFormat:@"dateOfHighlight >= %@", dateOnLastWeek];
    [_highlightArrayController setFilterPredicate:predicateOnHilight];
    
}






















@end
