//
//  EECoreStack.m
//  StackCore
//
//  Created by alok pandey on 05/12/15.
//  Copyright © 2015 alok pandey. All rights reserved.
//

#import "EECoreStack.h"




@interface EECoreStack ()

- (NSURL *)applicationDocumentsDirectory;

@end

@implementation EECoreStack

@synthesize masterContext = _masterContext;
@synthesize mainContext = _mainContext;
@synthesize workerContext = _workerContext;


#pragma app document directory
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.alok.WordNote" in the user's Application Support directory.
    
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.alokkumar.InkedMargin2"];
}



-(void)setUpCoreDataStackWithCallbackBlock:(void (^)(void)) callbackBlock{
    //model url
    
    
    NSURL *modelUrl = [[NSBundle mainBundle]URLForResource:@"InkedMargin" withExtension:@"momd"];
    if (!modelUrl) {
        NSLog(@"Failed to find model url" );
    }
    
    //create model
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc]initWithContentsOfURL:modelUrl];
    if (!mom) {
        NSLog(@"Failed to initialize model");
    }
    
    //create Persistent Store Coordinator
    NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc]initWithManagedObjectModel:mom];
    if (!psc) {
        NSLog(@"Failed to initialize Persistent Store Coordinator");
    }
    
    //create master context for saving to persistence store coordinator
    _masterContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [_masterContext setPersistentStoreCoordinator:psc];
    [_masterContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    //create main context wich deals with UI
    _mainContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSMainQueueConcurrencyType];
    _mainContext.parentContext = _masterContext;
    [_mainContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    
    
    
    
    
    
    //    add store to psc in background theread time to add store is uncertain dur to iCLoud and migration process
    dispatch_queue_t storeQ = NULL;
    storeQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(storeQ, ^{
        
        NSURL *storeUrl = [self applicationDocumentsDirectory];
        
        
        NSError *error = nil;
        NSPersistentStore *store = nil;
        
        // for migration
        NSMutableDictionary *options = [[NSMutableDictionary alloc]init];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSMigratePersistentStoresAutomaticallyOption];
        [options setValue:[NSNumber numberWithBool:YES] forKey:NSInferMappingModelAutomaticallyOption];
        
        
        // new Api to remove persistent store
//                [psc destroyPersistentStoreAtURL:[self applicationDocumentsDirectory] withType:NSSQLiteStoreType options:options error:&error];
        
        
        
        
        store = [psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error];
        
        if (!store) {
            NSLog(@"Error adding store to psc");
        }
        
        ///
        
        //when store is added let main q know about it
        dispatch_sync(dispatch_get_main_queue(), ^{
            callbackBlock();
            
        });
        
        
    });
    
    
    
}

#pragma mark - creat worker context for fetching data from TEXT File// New context each time
// this is important as If I don't alloc new context each time // the cache build on the context on the first fecth will cause conflict on next save of the context

-(NSManagedObjectContext *)createWorkerContext{
    _workerContext = [[NSManagedObjectContext alloc]initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    _workerContext.parentContext = _mainContext;
    [_workerContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return _workerContext;
}



#pragma mark - saving of Context

- (void)saveWorkerContext {
    NSLog(@"saveWorker");
    [self.workerContext performBlock:^{
        NSError *error = nil;
        [self.workerContext save:&error];
        if(error){
            NSLog(@"ERROR SAVING MAIN MOC %@: %@:", [error localizedDescription], [error userInfo]);
        }else {
            [self saveMainContext];
        }
    }];
}


- (void)saveMainContext {
    NSLog(@"saveMain");
    [self.mainContext performBlock:^{
        NSError *error = nil;
        [self.mainContext save:&error];
        if(error){
            NSLog(@"ERROR SAVING MAIN MOC %@: %@:", [error localizedDescription], [error userInfo]);
        }else{
            [self saveMasterContext];
            
        }
    }];
}

- (void)saveMasterContext {
    
    [self.masterContext performBlock:^{
        NSError *error = nil;
        [self.masterContext save:&error];
        if(error){
            NSLog(@"ERROR SAVING MASTER CONTEXT %@; : %@", [error localizedDescription], [error userInfo]);
        }
    }];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"doneSavingMainContext" object:nil];
    
}




@end
