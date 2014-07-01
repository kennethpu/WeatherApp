//
//  WACityView.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WACityView.h"
#import "WAWeather.h"
#import "WACoreDataHourlyWeather.h"
#import "WACoreDataDailyWeather.h"

// Constants to make it easier to modify layout
#define BLUR_ALPHA 0.3  // Alpha value of blur layer
#define INSET 20        // Inset variable so that all labels are evenly centered and spaced
#define CITY_HEIGHT 20
#define TIME_HEIGHT 18
#define TEMP_HEIGHT 90
#define ICON_HEIGHT 30

@interface WACityView ()

/// Height of screen
@property (nonatomic, assign) CGFloat screenHeight;

/// Represents background city image
@property (nonatomic, strong) UIImageView *bgImage;
/// Blur layer to make text more readable
@property (nonatomic, strong) UIToolbar *blurLayer;
/// Table view to display weather data
@property (nonatomic, strong) UITableView *tableView;

/// UILabel to display temperature
@property UILabel *temperatureLabel;
/// UILabel to display weather conditions
@property UILabel *conditionsLabel;
/// UILabel to display time observation was taken
@property UILabel *timeLabel;
/// UIImageView to display weather conditions icon
@property UIImageView *iconView;
/// Array to hold hourly forecast data
@property NSOrderedSet *hourlyForecast;
/// Array to hold daily forecast data
@property NSOrderedSet *dailyForecast;

@end

@implementation WACityView

/// Initializes a new CityView instance with the given properties
- (id)initWithFrame:(CGRect)frame
               name:(NSString*)name
              state:(NSString*)state
              bgUrl:(NSString*)bgUrl
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];

        self.screenHeight = frame.size.height;
        
        // Add background image
        self.bgImage = [[UIImageView alloc] initWithFrame:frame];
        self.bgImage.contentMode = UIViewContentModeScaleAspectFill;
        self.bgImage.clipsToBounds = YES;
        [self addSubview:self.bgImage];
        
        // Add blur layer
        self.blurLayer = [[UIToolbar alloc] initWithFrame:frame];
        self.blurLayer.autoresizingMask = self.autoresizingMask;
        self.blurLayer.backgroundColor = [UIColor blackColor];
        self.blurLayer.alpha = BLUR_ALPHA;
        [self addSubview:self.blurLayer];
        
        // Add table view to handle all data presentation
        self.tableView = [[UITableView alloc] initWithFrame:frame];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        self.tableView.pagingEnabled = YES;
        [self addSubview:self.tableView];
        
        // Set header of table view to be the same size as frame
        CGRect headerFrame = self.bounds;
        
        // Create frames for labels and icon views
        CGRect cityFrame = CGRectMake(0, INSET, self.bounds.size.width, CITY_HEIGHT);
        CGRect timeFrame = CGRectMake(0, INSET + cityFrame.size.height, self.bounds.size.width, TIME_HEIGHT);
        CGRect temperatureFrame = CGRectMake(INSET, headerFrame.size.height - (TEMP_HEIGHT + INSET), headerFrame.size.width, TEMP_HEIGHT);
        CGRect iconFrame = CGRectMake(INSET, temperatureFrame.origin.y - ICON_HEIGHT, ICON_HEIGHT, ICON_HEIGHT);
        CGRect conditionsFrame = CGRectMake(iconFrame.origin.x + (ICON_HEIGHT + INSET/2), temperatureFrame.origin.y - ICON_HEIGHT, self.bounds.size.width - (2*INSET + ICON_HEIGHT + INSET/2), ICON_HEIGHT);
        
        // Set current-conditions view as table header
        UIView *header = [[UIView alloc] initWithFrame:headerFrame];
        header.backgroundColor = [UIColor clearColor];
        self.tableView.tableHeaderView = header;
        
        // Build each required label to display weather data
        UILabel *cityLabel = [[UILabel alloc] initWithFrame:cityFrame];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.text = [NSString stringWithFormat:@"%@, %@", name, state];
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        cityLabel.textAlignment = NSTextAlignmentCenter;
        [header addSubview:cityLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:timeFrame];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textColor = [UIColor whiteColor];
        self.timeLabel.text = @"Loading...";
        self.timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        [header addSubview:self.timeLabel];
        
        self.temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
        self.temperatureLabel.backgroundColor = [UIColor clearColor];
        self.temperatureLabel.textColor = [UIColor whiteColor];
        self.temperatureLabel.text = @"0°";
        self.temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:110];
        [header addSubview:self.temperatureLabel];
        
        self.conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
        self.conditionsLabel.backgroundColor = [UIColor clearColor];
        self.conditionsLabel.textColor = [UIColor whiteColor];
        self.conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [header addSubview:self.conditionsLabel];
        
        // Add an image view for a weather icon
        self.iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        self.iconView.contentMode = UIViewContentModeScaleAspectFit;
        self.iconView.backgroundColor = [UIColor clearColor];
        [header addSubview:self.iconView];
        
        // Add refresh control
        self.refreshControl = [[UIRefreshControl alloc] init];
        [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:self.refreshControl];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WADownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"imageView":self.bgImage,@"bgUrl":bgUrl}];
    }
    return self;
}

- (void)refreshData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WARefreshWeatherNotification"
                                                        object:self
                                                      userInfo:@{@"cityView":self}];
}

/// Updates CityView with provided data
- (void)updateDataWithTime:(NSString *)time
                   iconImg:(UIImage *)icon
                conditions:(NSString *)conditions
               temperature:(NSString *)temperature
            hourlyForecast:(NSOrderedSet *)hourlyForecast
             dailyForecast:(NSOrderedSet *)dailyForecast
{
    self.timeLabel.text = time;
    self.iconView.image = icon;
    self.conditionsLabel.text = conditions;
    self.temperatureLabel.text = temperature;
    self.hourlyForecast = hourlyForecast;
    self.dailyForecast = dailyForecast;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        } else {
            WACoreDataHourlyWeather *weather = self.hourlyForecast[indexPath.row-1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            WACoreDataDailyWeather *weather = self.dailyForecast[indexPath.row-1];
            [self configureDailyCell:cell weather:weather];
        }
    }
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell*)cell
                      title:(NSString*)title
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

- (void)configureHourlyCell:(UITableViewCell *)cell
                   weather:(WACoreDataHourlyWeather*)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = weather.time;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°", weather.temperature];
    cell.imageView.image = [UIImage imageNamed:weather.icon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell
                   weather:(WACoreDataDailyWeather*)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = weather.time;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@° / %@°", weather.hiTemp, weather.loTemp];
    cell.imageView.image = [UIImage imageNamed:weather.icon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    return self.screenHeight / (CGFloat)cellCount;
}

@end
