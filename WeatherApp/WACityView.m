//
//  WACityView.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WACityView.h"
#import "WAWeather.h"

@interface WACityView ()

@property (nonatomic, strong) UIImageView *bgImage;                 // Represents background city image
@property (nonatomic, strong) UIToolbar *blurLayer;                 // Blur layer to make text more readable
@property (nonatomic, strong) UITableView *tableView;               // Table view to display weather data
@property (nonatomic, strong) UIActivityIndicatorView *indicator;   // Indicates activity while background image is being downloaded
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, assign) CGFloat screenHeight;

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
        _city = name;
        _state = state;
        
        // Add background image
        _bgImage = [[UIImageView alloc] initWithFrame:frame];
        _bgImage.contentMode = UIViewContentModeScaleAspectFill;
        _bgImage.clipsToBounds = YES;
        [self addSubview:_bgImage];
        
        // Add blur layer
        _blurLayer = [[UIToolbar alloc] initWithFrame:frame];
        _blurLayer.autoresizingMask = self.autoresizingMask;
        _blurLayer.backgroundColor = [UIColor blackColor];
        _blurLayer.alpha = 0.3;
        [self addSubview:_blurLayer];
        
        // Add table view to handle all data presentation
        _tableView = [[UITableView alloc] initWithFrame:frame];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
        _tableView.pagingEnabled = YES;
        [self addSubview:_tableView];
        
        // Set header of table view to be the same size as frame
        CGRect headerFrame = self.bounds;
        
        // Create an inset variable so that all labels are evenly centered and spaced
        CGFloat inset = 20;
        
        // Create and initialize height variables for various views
        CGFloat cityHeight = 20;
        CGFloat timeHeight = 18;
        CGFloat temperatureHeight = 110;
        CGFloat iconHeight = 30;
        
        // Create frames for labels and icon views
        CGRect cityFrame = CGRectMake(0, inset, self.bounds.size.width, cityHeight);
        CGRect timeFrame = CGRectMake(0, inset + cityFrame.size.height, self.bounds.size.width, timeHeight);
        CGRect temperatureFrame = CGRectMake(inset, headerFrame.size.height - (temperatureHeight + inset), headerFrame.size.width, temperatureHeight);
        CGRect iconFrame = CGRectMake(inset, temperatureFrame.origin.y - iconHeight, iconHeight, iconHeight);
        CGRect conditionsFrame = CGRectMake(iconFrame.origin.x + (iconHeight + 10), temperatureFrame.origin.y - iconHeight, self.bounds.size.width - (2*inset + iconHeight + 10), iconHeight);
        
        // Set current-conditions view as table header
        UIView *header = [[UIView alloc] initWithFrame:headerFrame];
        header.backgroundColor = [UIColor clearColor];
        _tableView.tableHeaderView = header;
        
        // Build each required label to display weather data
        UILabel *cityLabel = [[UILabel alloc] initWithFrame:cityFrame];
        cityLabel.backgroundColor = [UIColor clearColor];
        cityLabel.textColor = [UIColor whiteColor];
        cityLabel.text = [NSString stringWithFormat:@"%@, %@", name, state];
        cityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        cityLabel.textAlignment = NSTextAlignmentCenter;
        [header addSubview:cityLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:timeFrame];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.text = @"Loading...";
        _timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        [header addSubview:_timeLabel];
        
        _temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
        _temperatureLabel.backgroundColor = [UIColor clearColor];
        _temperatureLabel.textColor = [UIColor whiteColor];
        _temperatureLabel.text = @"0°";
        _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:120];
        [header addSubview:_temperatureLabel];
        
        _conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
        _conditionsLabel.backgroundColor = [UIColor clearColor];
        _conditionsLabel.textColor = [UIColor whiteColor];
        _conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [header addSubview:_conditionsLabel];
        
        // Add an image view for a weather icon
        _iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.backgroundColor = [UIColor clearColor];
        [header addSubview:_iconView];

        // Add activity indicator
        _indicator = [[UIActivityIndicatorView alloc] init];
        _indicator.center = self.center;
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [_indicator startAnimating];
        [self addSubview:_indicator];
        
        // Add refresh control
        _refreshControl = [[UIRefreshControl alloc] init];
        [_refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        [_tableView addSubview:_refreshControl];
        
        [_bgImage addObserver:self forKeyPath:@"image" options:0 context:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WADownloadImageNotification"
                                                            object:self
                                                          userInfo:@{@"imageView":_bgImage,@"bgUrl":bgUrl}];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"image"]) {
        [_indicator stopAnimating];
    }
}

- (void)refreshData
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WARefreshWeatherNotification"
                                                        object:self
                                                      userInfo:@{@"cityView":self}];
    [_refreshControl endRefreshing];
}

- (void) dealloc
{
    [_bgImage removeObserver:self forKeyPath:@"image"];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // TODO - Get number of rows for daily and hourly forecassts
//    if (section == 0) {
//        return MIN(hourlyForecast count, 6) + 1;
//    }
//    return MIN(dailyForecast count, 6) + 1;
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
            WAWeather *weather = self.hourlyForecast[indexPath.row-1];
            [self configureHourlyCell:cell weather:weather];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        } else {
            WAWeather *weather = self.dailyForecast[indexPath.row-1];
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
                   weather:(WAWeather*)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = weather.time;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°", weather.temperature];
    cell.imageView.image = [UIImage imageNamed:weather.icon];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)configureDailyCell:(UITableViewCell *)cell
                   weather:(WAWeather*)weather
{
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    cell.textLabel.text = weather.time;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@° / %.@°", weather.hiTemp, weather.loTemp];
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
