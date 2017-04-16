//
//  PersistClass.h
//  WordsWorthFinal
//
//  Created by alok pandey on 18/01/16.
//  Copyright © 2016 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EECoreStack.h"
#import <Cocoa/Cocoa.h>


@interface PersistClass : NSObject
+(void)persistBooksToDisk:(NSManagedObjectContext *)mainContext
                 subClass:(EECoreStack*)eeCoreStack
                  fromURL:(NSURL*)fileURL;

@end
