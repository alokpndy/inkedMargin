//
//  APTextViewSubClass.m
//  InkedMargin
//
//  Created by alok pandey on 08/02/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import "APTextViewSubClass.h"



@implementation APTextViewSubClass

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}


//// to disable formatted string copy and paste of NSTextView

- (NSString *)preferredPasteboardTypeFromArray:(NSArray *)availableTypes restrictedToTypesFromArray:(NSArray *)allowedTypes {
    if ([availableTypes containsObject:NSPasteboardTypeString]) {
        return NSPasteboardTypeString;
    }
    
    return [super preferredPasteboardTypeFromArray:availableTypes restrictedToTypesFromArray:allowedTypes];
}

@end
