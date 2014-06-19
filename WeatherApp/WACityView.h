//
//  WACityView.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WACityView : UIView <UITableViewDataSource, UITableViewDelegate>

/// English name of city
@property NSString *city;

/// English name of state/country containing city
@property NSString *state;

/// UILabel to display temperature
@property UILabel *temperatureLabel;

/// UILabel to display weather conditions
@property UILabel *conditionsLabel;

/// UILabel to display time observation was taken
@property UILabel *timeLabel;

/// UIImageView to display weather conditions icon
@property UIImageView *iconView;

/// Arrays to hold hourly forecast data
@property NSArray *hourlyForecast;

/// Arrays to hold daily forecast data
@property NSArray *dailyForecast;

/// Refresh control to indicate when data is getting refreshed
@property UIRefreshControl *refreshControl;

/// Initializes a new CityView instance with the given properties
- (id)initWithFrame:(CGRect)frame
               name:(NSString*)name
              state:(NSString*)state
              bgUrl:(NSString*)bgUrl;

@end
