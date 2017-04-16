//
//  Note+CoreDataProperties.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Note.h"

NS_ASSUME_NONNULL_BEGIN

@interface Note (CoreDataProperties)

@property (nullable, nonatomic, retain) NSAttributedString* noteByUser;
@property (nullable, nonatomic, retain) Highlight *fromHighlight;

@end

NS_ASSUME_NONNULL_END
