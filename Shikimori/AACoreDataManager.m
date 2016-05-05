//
//  AACoreDataManager.m
//  Shikimori
//
//  Created by Admin on 18.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.


#import "AACoreDataManager.h"
#import "AAServerManager.h"
#import "Anime+CoreDataProperties.h"

@interface AACoreDataManager ()

@property (assign, nonatomic) NSInteger pageInRequest;
@property (strong, nonatomic) NSMutableArray *animeArray;
@property (strong, nonatomic) AAAnimeCatalog *animeList;

@end


//static NSInteger friendsInRequest = 100;

@implementation AACoreDataManager

+ (AACoreDataManager*) sharedManager {
    
    static AACoreDataManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^{
        manager = [[AACoreDataManager alloc] init];
    });
    
    
    return manager;
}

// Uncomment this, if you need load some data in database. And don't forget uncomment property too.
//
//- (id)init
//{
//    self = [super init];
//    if (self) {
//    //some properties
//        self.animeArray = [NSMutableArray array];
//       [self getAnimeListFromServer];
//        
//        
////            NSFetchRequest *request = [[NSFetchRequest alloc] init];
////       
////            NSEntityDescription *description = [NSEntityDescription entityForName:@"Anime" inManagedObjectContext:self.managedObjectContext];
////        
////            [request setEntity:description];
////            [request setResultType:NSDictionaryResultType];
////        
////            NSError *requestError = nil;
////            NSArray *resultArray = [self.managedObjectContext executeFetchRequest:request error:&requestError];
////            if (requestError) {
////                NSLog(@"%@", [requestError localizedDescription]);
////            }
////            
////            NSLog(@"%@", resultArray);
//    }
//    
//    return self;
//}
//
//- (void) getAnimeListFromServer {
//
//    self.pageInRequest = 0;
//
//    for (int i = 0; i < 50; i++) {
//
//        [[AAServerManager shareManager] getAnimeList:self.pageInRequest = self.pageInRequest + 1
//                                               count:friendsInRequest
//                                               order:nil
//                                              status:nil
//                                           onSuccess:^(NSArray *animeArray) {
//
//                                               [self.animeArray addObjectsFromArray:animeArray];
//                                               for (AAAnimeCatalog *animeList in self.animeArray) {
//                                                   
//                                                   Anime *anime = [NSEntityDescription insertNewObjectForEntityForName:@"Anime" inManagedObjectContext:self.managedObjectContext];
//                                                   
//                                                   anime.animeID = animeList.animeID;
//                                                   anime.anons = animeList.anons;
//                                                   anime.englishName = animeList.name;
//                                                   anime.episodes = animeList.episodes;
//                                                   anime.episodes_aired = animeList.episodesAired;
//                                                   anime.imageURL = animeList.imageURL;
//                                                   anime.kind = animeList.kind;
//                                                   anime.ongoing = animeList.ongoing;
//                                                   anime.status = animeList.status;
//                                                   anime.russianName = animeList.russian;
//                                                   
//                                                   if (anime.russianName.length) {
//                                                       anime.firstLetterForSection = [anime.russianName substringToIndex:1];
//                                                   } else {
//                                                       anime.firstLetterForSection = [anime.englishName substringToIndex:1];
//                                                   }
//                                                   
//                                                   if ([anime.firstLetterForSection isEqualToString:@"Ё"]) {
//                                                       anime.firstLetterForSection = @"Е";
//                                                   }
//                                               }
//
//                                               [self.managedObjectContext save:nil];
//
//                                               [self.animeArray removeAllObjects];
//
//                                           }
//                                           onFailure:^(NSError *error, NSInteger statusCode) {
//                                               NSLog(@"error = %@, code = %ld", [error localizedDescription], (long)statusCode);
//                                           }];
//    }
//}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.ArsenAvanesyan.TestCoreData" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"CoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"CoreData.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
