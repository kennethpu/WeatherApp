//
//  WACoreDataManager.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/23/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WACoreDataManager.h"
#import "WACoreDataApp.h"
#import "WACoreDataCity.h"
#import "NSManagedObjectModel+KCOrderedAccessorFix.h"

@implementation WACoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

/// Returns a shared instance of the LibraryAPI object
+ (WACoreDataManager*) sharedInstance
{
    // Declare a static variable to hold the shared instance of LibraryAPI
    static WACoreDataManager *_sharedInstance = nil;
    
    // Declare the static variable which ensures that initialization code executes only once
    static dispatch_once_t oncePredicate;
    
    // Use Grand Central Dispatch (GCD) to execute a block which initializes an instance of LibraryAPI.
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[WACoreDataManager alloc] init];
    });
    
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        NSManagedObjectContext *context = [self managedObjectContext];
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"App" inManagedObjectContext:context];
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        
        NSError *error;
        NSArray *apps = [context executeFetchRequest:request error:&error];
        if ([apps count] == 0) {
            WACoreDataApp *app = [NSEntityDescription insertNewObjectForEntityForName:@"App" inManagedObjectContext:context];
            WACoreDataCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
            newCity.name = @"San Francisco";
            newCity.state = @"California";
            newCity.imgUrl = @"http://upload.wikimedia.org/wikipedia/en/7/75/DowntownSF.jpg";
            newCity.app = app;
            [app addCitiesObject:newCity];
            [context save:&error];
        }
    }
    return self;
}

/// Returns an array of currently saved cities
- (NSArray*)getCities
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"City" inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *cities = [context executeFetchRequest:request error:&error];
    
    return cities;
}

/// Add a city to the currently saved cities at the provided position
- (void)addCity:(WACity*)city
        atIndex:(int)index
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    WACoreDataCity *newCity = [NSEntityDescription insertNewObjectForEntityForName:@"City" inManagedObjectContext:context];
    newCity.name = city.name;
    newCity.state = city.state;
    newCity.imgUrl = city.imgUrl;
    
    NSError *error;
    [context save:&error];
}

/// Delete a city from the currently saved cities at the provided position
- (void)deleteCityAtIndex:(int)index
{
    //    [cities removeObjectAtIndex:index];
}

/// Saves the downloaded images in the Documents directory
- (void)saveImage:(UIImage*)image
         filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

/// Gets the specified image from the Documents directory
- (UIImage*)getImage:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    return [UIImage imageWithData:data];
}

/// Archives current list of cities
- (void)saveCities
{
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"WAModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    [_managedObjectModel kc_generateOrderedSetAccessors];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"WeatherApp.sqlite"];
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
