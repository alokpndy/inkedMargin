//
//  Highlight+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Highlight.h"

NS_ASSUME_NONNULL_BEGIN

@interface Highlight (CoreDataProperties)

@property (nullable, nonatomic, retain) NSAttributedString* attributedBody;
@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) NSDate *dateOfHighlight;
@property (nullable, nonatomic, retain) NSNumber *favIconInverter;
@property (nullable, nonatomic, retain) NSNumber *highlightLocationEnd;
@property (nullable, nonatomic, retain) NSNumber *highlightLocationStart;
@property (nullable, nonatomic, retain) NSNumber *highlightPageEnd;
@property (nullable, nonatomic, retain) NSNumber *highlightPageStart;
@property (nullable, nonatomic, retain) NSNumber *isHighlightFavourite;
@property (nullable, nonatomic, retain) NSString *kindleNote;
@property (nullable, nonatomic, retain) NSString *locationLabel;
@property (nullable, nonatomic, retain) NSNumber *markHighlightToDelete;
@property (nullable, nonatomic, retain) Book *fromBook;
@property (nullable, nonatomic, retain) Note *notesOnHighlight;

@end

NS_ASSUME_NONNULL_END
