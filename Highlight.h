//
//  Highlight.h
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book, Note;

NS_ASSUME_NONNULL_BEGIN

@interface Highlight : NSManagedObject

// Insert code here to declare functionality of your managed object subclass
-(void)setHighlightAsFavorite;
-(void)setHighlightAsNotFavorite;
-(void)setHighlightToDeleteOrPutBack;
@end

NS_ASSUME_NONNULL_END

#import "Highlight+CoreDataProperties.h"
