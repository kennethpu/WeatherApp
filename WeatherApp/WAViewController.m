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

// Constants to make it easy to modify layout
#define VIEW_PADDING 3
#define VIEWS_OFFSET 30
#define TOOLBAR_HEIGHT 33

@interface WAViewController () <HorizontalScrollerDelegate> {
    NSArray *allCities;
    int currentCityIndex;
    WAHorizontalScroller *scroller;
    UIToolbar *toolbar;
}
    
@end

@implementation WAViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    currentCityIndex = 0;
    
    // Create a toolbar for add/delete operations and initializes an undo stack
    toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - TOOLBAR_HEIGHT, self.view.frame.size.width, TOOLBAR_HEIGHT)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAction)];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteCity)];
    [toolbar setItems:@[add,space,delete]];
    [self.view addSubview:toolbar];
    
    allCities = [[WALibraryAPI sharedInstance] getCities];
    
    [self loadPreviousState];
    scroller = [[WAHorizontalScroller alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.height - TOOLBAR_HEIGHT - 20)];
    scroller.backgroundColor = [UIColor blackColor];
    scroller.delegate = self;
    [self.view addSubview:scroller];
    [self reloadScroller];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCityView:) name:@"WARefreshWeatherNotification" object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/// Removes current city from list
- (void)deleteCity
{
    // Delete album using LibraryAPI
    [[WALibraryAPI sharedInstance] deleteCityAtIndex:currentCityIndex];
    [self reloadScroller];
}

/// Adds a new city to list at specified index
- (void)addCity:(WACity*)city atIndex:(int)index
{
    [[WALibraryAPI sharedInstance] addCity:city atIndex:index];
    currentCityIndex = index;
    [self reloadScroller];
}

/// Downloads the specified images from the given urls
- (void)updateCityView:(NSNotification*)notification
{
    // Retreive UIIMageView and image URL from notification
    WACityView *cityView = notification.userInfo[@"cityView"];
    WACity *city = allCities[currentCityIndex];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Update weather information for city view
        WAWeather *currentWeather = [[WALibraryAPI sharedInstance] getCurrentWeatherForCity:cityView.city state:cityView.state];
        NSArray *hourlyForecast = [[WALibraryAPI sharedInstance] getHourlyForecastForCity:cityView.city state:cityView.state];
        NSArray *dailyForecast = [[WALibraryAPI sharedInstance] getDailyForecastForCity:cityView.city state:cityView.state];
        city.currentConditions = currentWeather;
        city.hourlyForecast = hourlyForecast;
        city.dailyForecast = dailyForecast;
        [self saveCurrentState];
        dispatch_sync(dispatch_get_main_queue(), ^{
            cityView.timeLabel.text = currentWeather.time;
            cityView.iconView.image = [UIImage imageNamed:currentWeather.icon];
            cityView.conditionsLabel.text = currentWeather.condition;
            cityView.temperatureLabel.text = [NSString stringWithFormat:@"%@°", currentWeather.temperature];
            cityView.hourlyForecast = hourlyForecast;
            cityView.dailyForecast = dailyForecast;
            [cityView.refreshControl endRefreshing];
        });
    });
}

/// Adds a new city with provided parameters to target index
- (void)addAction
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
    WACity *city = allCities[index];
    WACityView *cityView = [[WACityView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width-VIEWS_OFFSET*2, self.view.frame.size.height-TOOLBAR_HEIGHT-20) name:city.name state:city.state bgUrl:city.imgUrl];
    
    // Update weather information for city view
    WAWeather *currentWeather = city.currentConditions;
    NSArray *hourlyForecast = city.hourlyForecast;
    NSArray *dailyForecast = city.dailyForecast;
    
    if (currentWeather == nil) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            // Update weather information for city view
            WAWeather *currentWeather = [[WALibraryAPI sharedInstance] getCurrentWeatherForCity:cityView.city state:cityView.state];
            NSArray *hourlyForecast = [[WALibraryAPI sharedInstance] getHourlyForecastForCity:cityView.city state:cityView.state];
            NSArray *dailyForecast = [[WALibraryAPI sharedInstance] getDailyForecastForCity:cityView.city state:cityView.state];
            city.currentConditions = currentWeather;
            city.hourlyForecast = hourlyForecast;
            city.dailyForecast = dailyForecast;
            [self saveCurrentState];
            dispatch_sync(dispatch_get_main_queue(), ^{
                cityView.timeLabel.text = currentWeather.time;
                cityView.iconView.image = [UIImage imageNamed:currentWeather.icon];
                cityView.conditionsLabel.text = currentWeather.condition;
                cityView.temperatureLabel.text = [NSString stringWithFormat:@"%@°", currentWeather.temperature];
                cityView.hourlyForecast = hourlyForecast;
                cityView.dailyForecast = dailyForecast;
            });
        });
    } else {
        cityView.timeLabel.text = currentWeather.time;
        cityView.iconView.image = [UIImage imageNamed:currentWeather.icon];
        cityView.conditionsLabel.text = currentWeather.condition;
        cityView.temperatureLabel.text = [NSString stringWithFormat:@"%@°", currentWeather.temperature];
        cityView.hourlyForecast = hourlyForecast;
        cityView.dailyForecast = dailyForecast;
    }
    
    return cityView;
}

/// Loads album data and sets the current displayed view based on the current value of the current view index
- (void)reloadScroller
{
    allCities = [[WALibraryAPI sharedInstance] getCities];
    if (currentCityIndex < 0) currentCityIndex = 0;
    else if (currentCityIndex >= allCities.count) currentCityIndex = allCities.count-1;
    [scroller reload];
}

- (NSInteger)initialViewIndexForHorizontalScroller:(WAHorizontalScroller *)scroller
{
    return currentCityIndex;
}


@end
