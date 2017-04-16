//
//  TimeStamp+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "TimeStamp.h"

NS_ASSUME_NONNULL_BEGIN

@interface TimeStamp (CoreDataProperties)

@property (nullable, nonatomic, retain) NSDate *lastAddedDate;
@property (nullable, nonatomic, retain) NSNumber *noteCount;
@property (nullable, nonatomic, retain) NSNumber *highlightCount;

@end

NS_ASSUME_NONNULL_END
