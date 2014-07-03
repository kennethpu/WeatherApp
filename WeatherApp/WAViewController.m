//
//  WAViewController.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/7/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WAViewController.h"
#import "WAHorizontalScroller.h"
#import "WALibraryAPI.h"
#import "WACity.h"
#import "WACityView.h"
#import "WAWeather.h"
#import "WACoreDataManager.h"
#import "WACoreDataCurrentWeather.h"
#import "WACoreDataHourlyWeather.h"
#import "WACoreDataDailyWeather.h"

// Constants to make it easy to modify layout
#define VIEW_PADDING 3
#define VIEWS_OFFSET 30
#define TOOLBAR_HEIGHT 33
#define INSET 20

@interface WAViewController () <HorizontalScrollerDelegate> {
    NSOrderedSet *allCities;
    int currentCityIndex;
    WAHorizontalScroller *scroller;
    UIToolbar *toolbar;
}
    
@end

@implementation WAViewController

- (void)loadView
{
    [super loadView];
    
    // Register as observer for relevant notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:@"WADownloadImageNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCityView:) name:@"WARefreshWeatherNotification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Reset index
    currentCityIndex = 0;
    
    // Create a toolbar for add/delete operations
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCity)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCity)];
    [toolbar setItems:@[add,space,delete]];
    [self.view addSubview:toolbar];
    
    // Retrieve list of cities
    allCities = [[WALibraryAPI sharedInstance] getCities];
    
    // Load previous state
    [self loadPreviousState];
    
    // Initialize horizontal scroller
    scroller = [[WAHorizontalScroller alloc] initWithFrame:CGRectMake(0, INSET, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT - INSET)];
    scroller.backgroundColor = [UIColor blackColor];
    scroller.delegate = self;
    [self.view addSubview:scroller];
    [self reloadScroller];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/// Removes current city from list
- (void)deleteCity
{
    // Delete album using LibraryAPI
    [[WALibraryAPI sharedInstance] deleteCityAtIndex:currentCityIndex];
    [self reloadScroller];
    [self saveCurrentState];
}

/// Downloads the specified images from the given urls
- (void)updateCityView:(NSNotification*)notification
{
    // Retreive UIIMageView and image URL from notification
    WACityView *cityView = notification.userInfo[@"cityView"];
    WACoreDataCity *city = [[WALibraryAPI sharedInstance] getCityAtIndex:currentCityIndex];
    
    [self updateCityView:cityView andCity:city];
}

- (void)updateCityView:(WACityView*)cityView
               andCity:(WACoreDataCity*)city
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Get updated weather information
        WAWeather *currentWeather = [[WALibraryAPI sharedInstance] getCurrentWeatherForCity:city.name state:city.state];
        NSArray *hourlyForecast = [[WALibraryAPI sharedInstance] getHourlyForecastForCity:city.name state:city.state];
        NSArray *dailyForecast = [[WALibraryAPI sharedInstance] getDailyForecastForCity:city.name state:city.state];
        
        // Update Core Data Model as well as UI
        dispatch_sync(dispatch_get_main_queue(), ^{
            // Get managed object context
            NSManagedObjectContext *context = [[WACoreDataManager sharedInstance] managedObjectContext];
            
            // Save current weather data
            WACoreDataCurrentWeather *coreDataCurrentWeather = city.currentWeather;
            if (!coreDataCurrentWeather) {
                coreDataCurrentWeather = [NSEntityDescription insertNewObjectForEntityForName:@"CurrentWeather" inManagedObjectContext:context];
            }
            coreDataCurrentWeather.time = currentWeather.time;
            coreDataCurrentWeather.icon = currentWeather.icon;
            coreDataCurrentWeather.condition = currentWeather.condition;
            coreDataCurrentWeather.temperature = [NSNumber numberWithFloat:[currentWeather.temperature floatValue]];
            coreDataCurrentWeather.city = city;
            city.currentWeather = coreDataCurrentWeather;
            
            // Save hourly forecast data
            for (int i=0; i<[hourlyForecast count]; i++) {
                WACoreDataHourlyWeather *coreDataHourlyWeather;
                if ([city.hourlyForecast count] <= i) {
                    coreDataHourlyWeather = [NSEntityDescription insertNewObjectForEntityForName:@"HourlyWeather" inManagedObjectContext:context];
                } else {
                    coreDataHourlyWeather = [city.hourlyForecast objectAtIndex:i];
                }
                WAWeather *hourWeather = [hourlyForecast objectAtIndex:i];
                coreDataHourlyWeather.time = hourWeather.time;
                coreDataHourlyWeather.icon = hourWeather.icon;
                coreDataHourlyWeather.temperature = [NSNumber numberWithFloat:[hourWeather.temperature floatValue]];
                coreDataHourlyWeather.city = city;
                [city addHourlyForecastObject:coreDataHourlyWeather];
            }
            
            // Save daily forecast data
            for (int i=0; i<[dailyForecast count]; i++) {
                WACoreDataDailyWeather *coreDataDailyWeather;
                if ([city.dailyForecast count] <= i) {
                    coreDataDailyWeather = [NSEntityDescription insertNewObjectForEntityForName:@"DailyWeather" inManagedObjectContext:context];
                } else {
                    coreDataDailyWeather = [city.dailyForecast objectAtIndex:i];
                }
                WAWeather *dayWeather = [dailyForecast objectAtIndex:i];
                coreDataDailyWeather.time = dayWeather.time;
                coreDataDailyWeather.icon = dayWeather.icon;
                coreDataDailyWeather.hiTemp = [NSNumber numberWithFloat:[dayWeather.hiTemp floatValue]];
                coreDataDailyWeather.loTemp = [NSNumber numberWithFloat:[dayWeather.loTemp floatValue]];
                coreDataDailyWeather.city = city;
                [city addDailyForecastObject:coreDataDailyWeather];
            }
            
            // Save context
            [self saveCurrentState];
            
            // Update weather information for city view
            [cityView updateDataWithTime:currentWeather.time
                                 iconImg:[UIImage imageNamed:currentWeather.icon]
                              conditions:currentWeather.condition
                             temperature:[NSString stringWithFormat:@"%@°", currentWeather.temperature]
                          hourlyForecast:city.hourlyForecast
                           dailyForecast:city.dailyForecast];
            if (cityView.refreshControl.refreshing) {
                [cityView.refreshControl endRefreshing];
            }
        });
    });
}

/// Downloads the specified images from the given urls
- (void)downloadImage:(NSNotification*)notification
{
    // Retreive UIIMageView and image URL from notification
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *bgUrl = notification.userInfo[@"bgUrl"];
    
    [[WALibraryAPI sharedInstance] downloadImageURL:bgUrl
                                          imageView:imageView];
}

/// Adds a new city with provided parameters to target index
- (void)addCity
{
    UIAlertView *titleAlert = [[UIAlertView alloc] initWithTitle:@"Adding New City" message:@"Enter city name, country/state separated by commas" delegate:self cancelButtonTitle:@"Continue" otherButtonTitles:nil];
    titleAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField *alertTextField = [titleAlert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeAlphabet;
    alertTextField.placeholder = @"City,State/Country";
    [titleAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSArray *cityInfo = [[[alertView textFieldAtIndex:0] text] componentsSeparatedByString:@","];
    NSString *cityName = cityInfo[0];
    NSString *state = cityInfo[1];
    
    NSString* query = [NSString stringWithFormat:@"%@ %@", cityName, state];
    NSString* imgUrl = [[WALibraryAPI sharedInstance] getImageUrl:query];
    WACity *newCity = [[WACity alloc] initWithName:cityName state:state imgUrl:imgUrl];

    [[WALibraryAPI sharedInstance] addCity:newCity atIndex:currentCityIndex];
    [self reloadScroller];
    [self saveCurrentState];
}

/// Save the index of the last album that user was on
- (void)saveCurrentState
{
    [[NSUserDefaults standardUserDefaults] setInteger:currentCityIndex forKey:@"currentCityIndex"];
    [[WALibraryAPI sharedInstance] saveCities];
}

/// Load the index of the album the user was last on
- (void)loadPreviousState
{
    currentCityIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentCityIndex"];
}

#pragma mark - HorizontalScrollerDelegate methods
/// Sets variable that stores current album and displays data for new albumfrel
- (void)horizontalScroller:(WAHorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    currentCityIndex = index;
}

/// Returns the number of views for the scroll view
- (NSInteger)numberOfViewsForHorizontalScroller:(WAHorizontalScroller *)scroller
{
    return allCities.count;
}

/// Returns a CityView for the view at the current index
- (UIView*)horizontalScroller:(WAHorizontalScroller *)scroller viewAtIndex:(int)index
{
//    WACity *city = allCities[index];
    WACoreDataCity *city = [[WALibraryAPI sharedInstance] getCityAtIndex:index];
    WACityView *cityView = [[WACityView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-VIEWS_OFFSET*2, self.view.frame.size.height-TOOLBAR_HEIGHT-20) name:city.name state:city.state bgUrl:city.imgUrl];
    
    // Get
    WACoreDataCurrentWeather *currentWeather = city.currentWeather;
    NSOrderedSet *hourlyForecast = city.hourlyForecast;
    NSOrderedSet *dailyForecast = city.dailyForecast;
    
    if (currentWeather == nil) {
        [self updateCityView:cityView andCity:city];
    } else {
        // Update weather information for city view
        [cityView updateDataWithTime:currentWeather.time
                             iconImg:[UIImage imageNamed:currentWeather.icon]
                          conditions:currentWeather.condition
                         temperature:[NSString stringWithFormat:@"%@°", currentWeather.temperature]
                      hourlyForecast:hourlyForecast
                       dailyForecast:dailyForecast];
    }
    
    return cityView;
}

/// Loads album data and sets the current displayed view based on the current value of the current view index
- (void)reloadScroller
{
    allCities = [[WALibraryAPI sharedInstance] getCities];
//    if (currentCityIndex < 0) currentCityIndex = 0;
//    else if (currentCityIndex >= allCities.count) currentCityIndex = allCities.count-1;
    currentCityIndex = allCities.count-1;
    [scroller reload];
}

- (NSInteger)initialViewIndexForHorizontalScroller:(WAHorizontalScroller *)scroller
{
    return currentCityIndex;
}


@end
