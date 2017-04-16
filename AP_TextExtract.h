//
//  AP_TextExtract.h
//  WordsWorth
//
//  Created by alok pandey on 23/12/15.
//  Copyright © 2015 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AP_TextExtract : NSObject

+(NSArray *) componentSeperatedByBooksFromTXTFile: (NSURL *)urlOfFIle;
+(NSString*) bookNameFromString :(NSString*) string;
+(NSString *) authorNameFromString:(NSString*) string;

+(NSString *) whetherNoteOrHighlightFromString:(NSString *)string;
+(NSDate *) dateAndTimeFromString:(NSString *)string;
+(NSDictionary *) pageLocation:(NSString *)string;

+(NSString *) clippingsBodyFromString:(NSString*) string;
@end
