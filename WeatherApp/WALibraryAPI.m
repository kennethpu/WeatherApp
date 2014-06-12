//
//  WALibraryAPI.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WALibraryAPI.h"
#import "WAHTTPClient.h"
#import "WAPersistencyManager.h"

@interface WALibraryAPI () {
    WAPersistencyManager *persistencyManager;
    WAHTTPClient *httpClient;
}
@end

@implementation WALibraryAPI

/// Returns a shared instance of the LibraryAPI object
+ (WALibraryAPI*) sharedInstance
{
    // Declare a static variable to hold the shared instance of LibraryAPI
    static WALibraryAPI *_sharedInstance = nil;
    
    // Declare the static variable which ensures that initialization code executes only once
    static dispatch_once_t oncePredicate;
    
    // Use Grand Central Dispatch (GCD) to execute a block which initializes an instance of LibraryAPI.
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[WALibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

/// Initializes an instance of LibraryAPI
- (id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[WAPersistencyManager alloc] init];
        httpClient = [[WAHTTPClient alloc] init];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getImageUrl2:) name:@"WAGetImageURLNotification" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentWeather:) name:@"WAGetCurrentWeatherNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"WADownloadImageNotification" object:nil];
    }
    return self;
}

/// Returns an array of currently saved cities
- (NSArray*)getCities
{
    return [persistencyManager getCities];
}

/// Add a city to the currently saved cities at the provided position
- (void)addCity:(WACity *)city
        atIndex:(int)index
{
    [persistencyManager addCity:city atIndex:index];
}

/// Delete a city from the currently saved cities at the provided position
- (void)deleteCityAtIndex:(int)index
{
    [persistencyManager deleteCityAtIndex:index];
}


/// Get the url of the first image resulting from a google image search of the provided query
- (NSString*)getImageUrl:(NSString*)query
{
    return [httpClient getImageUrl:query];
}

///// Get the url of the first image resulting from a google image search of the provided query
//- (void)getImageUrl2:(NSNotification*)notification
//{
//    WACity *city = notification.userInfo[@"city"];
//    NSString *query = notification.userInfo[@"query"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Display image in image view and use PersistencyManager to save image locally
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            city.imgUrl = [self getImageUrl:query]
//            ;
//        });
//    });
//}

/// Downloads the specified images from the given urls
- (void)downloadImage:(NSNotification*)notification
{
    // Retreive UIIMageView and image URL from notification
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *bgUrl = notification.userInfo[@"bgUrl"];
    
    // Retrieve image from PersistencyManager if downloaded previously
    imageView.image = [persistencyManager getImage:[bgUrl lastPathComponent]];
    
    if (imageView.image == nil) {
        // Download image using HTTPClient if not downloaded previously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:bgUrl];
            
            // Display image in image view and use PersistencyManager to save image locally
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[bgUrl lastPathComponent]];
            });
        });
    }
}

/// Archives current list of cities
- (void)saveCities
{
    [persistencyManager saveCities];
}

///// Fetches current weather conditions for the provided location
//- (void)getCurrentWeather:(NSNotification*)notification
//{
//    WACity *city = notification.userInfo[@"city"];
//    NSString *name = notification.userInfo[@"name"];
//    NSString *state = notification.userInfo[@"state"];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//        // Display image in image view and use PersistencyManager to save image locally
//        dispatch_sync(dispatch_get_main_queue(), ^{
//            city.currentWeather = [self getCurrentWeatherForCity:name state:state];
//        });
//    });
//}

/// Fetches current weather conditions for the provided location
- (WAWeather*)getCurrentWeatherForCity:(NSString*)city
                                 state:(NSString*)state
{
    return [httpClient getCurrentWeatherForCity:city state:state];
}

/// Fetches predicted hourly weather conditions for the provided location
- (NSArray*)getHourlyForecastForCity:(NSString*)city
                               state:(NSString*)state
{
    return [httpClient getHourlyForecastForCity:city state:state];
}

/// Fetches predicted daily weather conditions for the provided location
- (NSArray*)getDailyForecastForCity:(NSString*)city
                                state:(NSString*)state
{
    return [httpClient getDailyForecastForCity:city state:state];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
