//
//  PersistClass.m
//  WordsWorthFinal
//
//  Created by alok pandey on 18/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "PersistClass.h"
#import "AP_TextExtract.h"
#import "Author.h"
#import "Book.h"
#import "Highlight.h"
#import "Group.h"
#import "Note.h"
#import "TimeStamp.h"




@implementation PersistClass

+(NSArray *)returnDateAndValueOfNoteFromURL:(NSURL*)fileURL{
    
    NSMutableArray *noteArray = [[NSMutableArray alloc]init];
    NSArray * array = [AP_TextExtract componentSeperatedByBooksFromTXTFile:fileURL];
    for (NSString *body in array) {
        if ([[AP_TextExtract whetherNoteOrHighlightFromString:body] isEqualToString:@"Notes"]) {
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            
            [dictionary setObject:[AP_TextExtract clippingsBodyFromString:body] forKey:@"note"];
            [dictionary setObject:[AP_TextExtract dateAndTimeFromString:body] forKey:@"noteDate"];
            [dictionary setObject:[AP_TextExtract bookNameFromString:body] forKey:@"noteFromBook"];
            
            if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Location"] count] > 0) {
                [dictionary setObject:[[AP_TextExtract pageLocation:body]valueForKey:@"Location"][0] forKey:@"noteLocationStart"];
            }
            
            if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Location"] count] > 1) {
                [dictionary setObject:[[AP_TextExtract pageLocation:body]valueForKey:@"Location"][1] forKey:@"noteLocationEnd"];
            }
            
            if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Page"] count] > 0) {
                [dictionary setObject:[[AP_TextExtract pageLocation:body]valueForKey:@"Page"][0] forKey:@"notePageStart"];
            }
            if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Page"] count] > 1) {
                [dictionary setObject:[[AP_TextExtract pageLocation:body]valueForKey:@"Page"][1] forKey:@"notePageEnd"];            }
            
            [noteArray addObject:dictionary];
        }
    }
    return noteArray;
    
}




#pragma mark - Methhod to get count of entities directly from the store

+(NSNumber *) countOfEntitiesUsingExpressionForEntity:(NSString *)entityName
                                         forAttribute:(NSString *)attributeName
                                            inContext:(NSManagedObjectContext*)context
{
    NSExpression *keyPathExpression = [NSExpression
                                       expressionForKeyPath:attributeName];
    NSExpression *countExpression = [NSExpression
                                     expressionForFunction:@"count:"
                                     arguments:[NSArray arrayWithObject:keyPathExpression]];
    
    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
    [countExpressionDescription setName:@"countOfAttribute"];
    [countExpressionDescription setExpression:countExpression];
    [countExpressionDescription setExpressionResultType:NSInteger16AttributeType];
    
    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entity];
    
    [request setPropertiesToFetch:[NSArray arrayWithObject:
                                   countExpressionDescription]];
    [request setResultType: NSDictionaryResultType];
    NSError *error = nil;
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];
    
    NSNumber *countOfAttributes = [[fetchResults lastObject]
                                   valueForKey:@"countOfAttribute"];
    
    return countOfAttributes;
    
    
}






#pragma mark - PersistDataToDisk
+(void)persistBooksToDisk:(NSManagedObjectContext *)mainContext
                 subClass:(EECoreStack*)eeCoreStack
                  fromURL:(NSURL*)fileURL
{
    
#pragma mark - fetching number of entities already in the store on the last sync START
    
//    NSNumber *authorCount = [self countOfEntitiesUsingExpressionForEntity:@"Author" forAttribute:@"name" inContext:mainContext];
//    NSNumber *bookCount = [self countOfEntitiesUsingExpressionForEntity:@"Book" forAttribute:@"title" inContext:mainContext];
//    NSNumber *highlightCount = [self countOfEntitiesUsingExpressionForEntity:@"Highlight" forAttribute:@"body" inContext:mainContext];
    
//    NSLog(@"COUNT OF AUTHOR: %li\n BOOK: %li\n HIGHLIGHT: %li\n", [authorCount integerValue], [bookCount integerValue], [highlightCount integerValue]);
    
#pragma mark - fetching number of entities already in the store on the last sync END
    
    
    
    NSArray *noteValueArray = [self returnDateAndValueOfNoteFromURL:fileURL];
    
    [mainContext performBlockAndWait:^{
        
        // Since TimeStamp will only be added once ini a fetch // hence kept outside of Loop
        // Timestamp is used to filter Highlights added up to 7 days before
        TimeStamp *timeStamp = (TimeStamp*) [NSEntityDescription insertNewObjectForEntityForName:@"TimeStamp" inManagedObjectContext:mainContext];
        timeStamp.lastAddedDate = [NSDate date];
        
        [self saveFromTextFileWIthNoteEntity:YES persistBooksToDisk:mainContext subClass:eeCoreStack fromURL:fileURL noteArray:noteValueArray ];
        
        
    }];
    
    //     saving context out of loop // to wait for all data be set and hide waiting sheet only then
    [mainContext performBlock:^{[eeCoreStack saveWorkerContext];}];
    
    
    
    
}







#pragma mark - save logic from Kindle Device

+(void)saveFromTextFileWIthNoteEntity:(BOOL)saveNoteEntity persistBooksToDisk:(NSManagedObjectContext *)mainContext
                             subClass:(EECoreStack*)eeCoreStack
                              fromURL:(NSURL*)fileURL noteArray:(NSArray*)noteValueArray
{
    
    
    NSArray * array = [AP_TextExtract componentSeperatedByBooksFromTXTFile:fileURL];
    for (NSString *body in array) {
        
        @autoreleasepool {
            
            [mainContext performBlock:^{
                
                if ([[AP_TextExtract whetherNoteOrHighlightFromString:body] isEqualToString:@"Highlight"]){
                    
                    NSMutableSet *highlightsSet = [NSMutableSet set];
                    Group *all = (Group*) [NSEntityDescription insertNewObjectForEntityForName:@"Group" inManagedObjectContext:mainContext];
                    Highlight *highlight = (Highlight *)[NSEntityDescription insertNewObjectForEntityForName:@"Highlight" inManagedObjectContext:mainContext];
                    Note *note = (Note *)[NSEntityDescription insertNewObjectForEntityForName:@"Note" inManagedObjectContext:mainContext];
                    
                    
#pragma mark - NSExpression to qury directly to SQL Store Start
                    
                    NSExpression *keyPathExpression = [NSExpression
                                                       expressionForKeyPath:@"dateOfHighlight"];
                    NSExpression *countExpression = [NSExpression
                                                     expressionForFunction:@"count:"
                                                     arguments:[NSArray arrayWithObject:keyPathExpression]];
                    
                    NSExpressionDescription *countExpressionDescription = [[NSExpressionDescription alloc] init];
                    [countExpressionDescription setName:@"countOfAttribute"];
                    [countExpressionDescription setExpression:countExpression];
                    [countExpressionDescription setExpressionResultType:NSInteger16AttributeType];
                    
                    NSFetchRequest *request = [[NSFetchRequest alloc]init];
                    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Highlight" inManagedObjectContext:mainContext];
                    [request setEntity:entity];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"dateOfHighlight == %@",[AP_TextExtract dateAndTimeFromString:body]]];
                    [request setPropertiesToFetch:[NSArray arrayWithObject:
                                                   countExpressionDescription]];
                    [request setResultType: NSDictionaryResultType];
                    NSError *error = nil;
                    NSArray *fetchResults = [mainContext executeFetchRequest:request error:&error];
                    
                    NSNumber *countOfAttributes = [[fetchResults lastObject]
                                                   valueForKey:@"countOfAttribute"];
                    
                    
                    //                NSLog(@"COUNT OF MATCHES FOR DATE OF HIGHLIGHT EQUAL TO DATE FROM TEXT FILE %li", matches.count);
                    if ([countOfAttributes integerValue]== 0) {
                        // this is done so that NOTE BY USER not get overwritten in every sync and remain edidtable
                        highlight.notesOnHighlight = note;
                    }
                    
#pragma mark - NSExpression to qury directly to SQL Store End
                    
                    highlight.body = [AP_TextExtract clippingsBodyFromString:body];
                    highlight.dateOfHighlight = [AP_TextExtract dateAndTimeFromString:body];
                    
                    if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Location"] count] > 0) {
                        highlight.highlightLocationStart = [[AP_TextExtract pageLocation:body]valueForKey:@"Location"][0];
                    }
                    if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Location"] count] > 1) {
                        highlight.highlightLocationEnd = [[AP_TextExtract pageLocation:body]valueForKey:@"Location"][1];
                    }
                    if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Page"] count] > 0) {
                        highlight.highlightPageStart = [[AP_TextExtract pageLocation:body]valueForKey:@"Page"][0];
                    }
                    if ([[[AP_TextExtract pageLocation:body]valueForKey:@"Page"] count] > 1) {
                        highlight.highlightPageEnd = [[AP_TextExtract pageLocation:body]valueForKey:@"Page"][1];
                    }
                    
                    
#pragma mark - Saving NOTE from Kindle
                    NSArray *filtered = [noteValueArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(noteDate == %@)", highlight.dateOfHighlight]];
                    
                    if (filtered.count>0) {
                        highlight.kindleNote = [filtered[0]valueForKey:@"note"];
                    }if (filtered.count == 0) {
                        // for filling up blank
                        highlight.kindleNote = @"No note found";
                    }
                    
                    
                    [highlightsSet addObject:highlight];
                    
                    Book *book = (Book *) [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:mainContext];
                    book.title = [AP_TextExtract bookNameFromString:body];
                    [book addHighlightsInBook:highlightsSet];
                    
                    NSArray *filtredArrayByLocation = [noteValueArray filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"(noteFromBook == %@)", highlight.fromBook.title]];
                    
                    
                    for (NSDictionary *dictionary in filtredArrayByLocation) {
                        
                        NSInteger noteStart = [[dictionary valueForKey:@"noteLocationStart"]intValue];
                        NSInteger noteEnd = [[dictionary valueForKey:@"noteLocationEnd"]intValue];
                        NSInteger notePageStart = [[dictionary valueForKey:@"notePageStart"]intValue];
                        NSInteger notePageEnd = [[dictionary valueForKey:@"notePageEnd"]intValue];
                        
                        
                        if ([highlight.highlightLocationStart intValue] == noteStart || [highlight.highlightLocationEnd intValue] == noteStart ||
                            [highlight.highlightLocationStart intValue] == noteEnd || [highlight.highlightLocationEnd intValue] == noteEnd)
                        {
                            highlight.kindleNote = [dictionary valueForKey:@"note"];
                            
                        }
                        
                        else if (highlight.highlightLocationStart == NULL && highlight.highlightLocationEnd == NULL) {
                            if ([highlight.highlightPageStart intValue] == notePageStart || [highlight.highlightPageEnd intValue] == notePageStart
                                || [highlight.highlightPageStart intValue] == notePageEnd || [highlight.highlightPageStart intValue] == notePageEnd )
                            {
                                highlight.kindleNote = [dictionary valueForKey:@"note"];
                                
                            }
                        }//////////adding new logic// if location is in middle and page of highlight and note matches
                        else if (noteStart > [highlight.highlightLocationStart intValue] &&  noteStart < [highlight.highlightLocationEnd intValue])
                            
                        {
                            
                            if ([highlight.highlightPageStart intValue] == notePageStart || [highlight.highlightPageEnd intValue] == notePageStart
                                || [highlight.highlightPageStart intValue] == notePageEnd || [highlight.highlightPageStart intValue] == notePageEnd )
                            {
                                highlight.kindleNote = [dictionary valueForKey:@"note"];
                                
                            }
                        }
                        
                    }
                    
                    [highlightsSet addObject:highlight];
                    
                    Author *author = (Author*)[NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:mainContext];
                    author.name = [AP_TextExtract authorNameFromString:body];
                    //create attribute string to save as separte body concatenate
#pragma mark - Concatenating Attribute
                    if ([book.title length] > 0 && [highlight.body length]>0) {
                        
                        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
                        formatter.dateFormat = @"EEEE, MMMM d, y hh:mm a";
                        
                        
                        NSString *fullDescription = [NSString stringWithFormat:@"%@\nBy %@\n%@\n\n\n%@", book.title, author.name,[formatter stringFromDate:highlight.dateOfHighlight], highlight.body];
                        
                        NSMutableAttributedString *bodyString = [[NSMutableAttributedString alloc] initWithString:fullDescription];
                        // heading attributed text
                        [bodyString addAttribute:NSFontAttributeName
                                           value:[NSFont systemFontOfSize:18 weight:NSFontWeightRegular]
                                           range:NSMakeRange(0, [book.title length])];
                        [bodyString setAlignment:NSLeftTextAlignment range:NSMakeRange(0, [book.title length])];
                        [bodyString addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(0, [book.title length])];
                        // author attributed text
                        [bodyString addAttribute:NSFontAttributeName
                                           value:[NSFont systemFontOfSize:11.0]
                                           range:NSMakeRange(book.title.length, [author.name length]+4)];
                        [bodyString setAlignment:NSLeftTextAlignment range:NSMakeRange(book.title.length, [author.name length]+4)];
                        [bodyString addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(book.title.length, [author.name length]+4)];
                        
                        // date attributed text
                        NSInteger locationNiddleLast = [fullDescription length]-[highlight.body length];
                        NSInteger locationOfStartOfdate = [author.name length]+[book.title length]+5;
                        NSInteger dateLenght = [[formatter stringFromDate:highlight.dateOfHighlight] length]+2;
                        [bodyString addAttribute:NSFontAttributeName
                                           value:[NSFont systemFontOfSize:11.0]
                                           range:NSMakeRange(locationOfStartOfdate, dateLenght)];
                        [bodyString setAlignment:NSLeftTextAlignment range:NSMakeRange(locationOfStartOfdate, dateLenght)];
                        [bodyString addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(locationOfStartOfdate, dateLenght)];
                        
                        
                        // body attributed text
                        [bodyString addAttribute:NSFontAttributeName
                                           value:[NSFont systemFontOfSize:14 weight:NSFontWeightRegular]
                                           range:NSMakeRange(locationNiddleLast, [highlight.body length])];
                        [bodyString setAlignment:NSLeftTextAlignment range:NSMakeRange(locationNiddleLast, [highlight.body length])];
                        [bodyString addAttribute:NSForegroundColorAttributeName value:[NSColor textColor] range:NSMakeRange(locationNiddleLast, [highlight.body length])];
                        
                        
                        // settng paragraph style for body
                        NSMutableParagraphStyle *parahraphStyle = [[NSMutableParagraphStyle alloc]init];
                        [parahraphStyle setLineSpacing: 5];
                        [bodyString addAttribute:NSParagraphStyleAttributeName value:parahraphStyle range:NSMakeRange(locationNiddleLast, [highlight.body length])];
                        
                        // settng paragraph style for title
                        NSMutableParagraphStyle *parahraphStyleTitle = [[NSMutableParagraphStyle alloc]init];
                        [parahraphStyleTitle setLineSpacing: 6];
                        [bodyString addAttribute:NSParagraphStyleAttributeName value:parahraphStyleTitle range:NSMakeRange(0, [book.title length])];
                        
                        // settng paragraph style for author name and date
                        NSMutableParagraphStyle *parahraphStyleAuthorNameAndDate = [[NSMutableParagraphStyle alloc]init];
                        [parahraphStyleAuthorNameAndDate setLineSpacing: 4];
                        [bodyString addAttribute:NSParagraphStyleAttributeName value:parahraphStyleAuthorNameAndDate range:NSMakeRange(book.title.length,dateLenght)];
                        
                        
                        
                        highlight.attributedBody = bodyString;
                        
                        
                        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                        [dateFormatter setDateFormat:@"dd/MM/yy"];
                        NSString *dateString = [dateFormatter stringFromDate:highlight.dateOfHighlight];
                        
                        
                        NSString *setLabel;
                        if ([highlight.highlightPageStart  isEqual: @0]) {
                            setLabel = [NSString stringWithFormat:@"Loc %@-%@, %@", highlight.highlightLocationStart, highlight.highlightLocationEnd, dateString];
                        }else{
                            setLabel = [NSString stringWithFormat:@"Page %@, Loc %@-%@, %@",highlight.highlightPageStart, highlight.highlightLocationStart, highlight.highlightLocationEnd, dateString];
                        }
                        
                        highlight.locationLabel = setLabel;
                        
                    }
                    
                    
                    [author addBooksByAuthorObject:book];
                    NSMutableSet *authorSet = [NSMutableSet set];
                    [authorSet addObject:author];
                    [all addAllAuthors:authorSet];
                    
                }
            }];
            
        }
        
    }
}

@end
