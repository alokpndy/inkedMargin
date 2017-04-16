//
//  Book+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Book.h"

NS_ASSUME_NONNULL_BEGIN

@interface Book (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) Author *byAuthor;
@property (nullable, nonatomic, retain) NSSet<Highlight *> *highlightsInBook;

@end

@interface Book (CoreDataGeneratedAccessors)

- (void)addHighlightsInBookObject:(Highlight *)value;
- (void)removeHighlightsInBookObject:(Highlight *)value;
- (void)addHighlightsInBook:(NSSet<Highlight *> *)values;
- (void)removeHighlightsInBook:(NSSet<Highlight *> *)values;

@end

NS_ASSUME_NONNULL_END
