//
//  Author+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Author.h"

NS_ASSUME_NONNULL_BEGIN

@interface Author (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSSet<Book *> *booksByAuthor;
@property (nullable, nonatomic, retain) Group *fromGroup;

@end

@interface Author (CoreDataGeneratedAccessors)

- (void)addBooksByAuthorObject:(Book *)value;
- (void)removeBooksByAuthorObject:(Book *)value;
- (void)addBooksByAuthor:(NSSet<Book *> *)values;
- (void)removeBooksByAuthor:(NSSet<Book *> *)values;

@end

NS_ASSUME_NONNULL_END
