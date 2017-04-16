//
//  Highlight.m
//  InkedMargin
//
//  Created by alok pandey on 03/03/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "Highlight.h"
#import "Book.h"
#import "Note.h"

@implementation Highlight

// Insert code here to add functionality to your managed object subclass
-(void)setHighlightAsFavorite{
    if ([self.isHighlightFavourite  isEqual: @0]) {
        self.isHighlightFavourite = @1;
        self.favIconInverter = @0;
    }
}

-(void)setHighlightAsNotFavorite{
    if ([self.isHighlightFavourite  isEqual: @1]) {
        self.isHighlightFavourite = @0;
        self.favIconInverter = @1;
    }
}

-(void)setHighlightToDeleteOrPutBack{
    if ([self.markHighlightToDelete  isEqual: @0]) {
        self.markHighlightToDelete = @1;
    }else if ([self.markHighlightToDelete  isEqual: @1]){
        self.markHighlightToDelete = @0;
    }
}
@end
