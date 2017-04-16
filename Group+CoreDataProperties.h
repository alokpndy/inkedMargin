//
//  Group+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Group.h"

NS_ASSUME_NONNULL_BEGIN

@interface Group (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *all;
@property (nullable, nonatomic, retain) NSSet<Author *> *allAuthors;

@end

@interface Group (CoreDataGeneratedAccessors)

- (void)addAllAuthorsObject:(Author *)value;
- (void)removeAllAuthorsObject:(Author *)value;
- (void)addAllAuthors:(NSSet<Author *> *)values;
- (void)removeAllAuthors:(NSSet<Author *> *)values;

@end

NS_ASSUME_NONNULL_END
