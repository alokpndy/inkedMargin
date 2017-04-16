//
//  EECoreStack.h
//  StackCore
//
//  Created by alok pandey on 05/12/15.
//  Copyright © 2015 alok pandey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>



@interface EECoreStack : NSObject

@property(nonatomic, strong) NSManagedObjectContext *masterContext;
@property(nonatomic, strong) NSManagedObjectContext *mainContext;


@property(nonatomic, strong) NSManagedObjectContext *workerContext;



-(void)setUpCoreDataStackWithCallbackBlock:(void (^)(void)) callbackBlock;


- (void)saveMainContext;
- (void)saveMasterContext;
- (void)saveWorkerContext;


-(NSManagedObjectContext *)createWorkerContext;

@end
