//
//  WACityView.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WACityView : UIView <UITableViewDataSource, UITableViewDelegate>

/// UILabels to display weather data
@property UILabel *temperatureLabel, *conditionsLabel, *timeLabel;

/// UIImageView to display weather conditions icon
@property UIImageView *iconView;

/// Arrays to hold hourly and daily forecast data
@property NSArray *hourlyForecast, *dailyForecast;

@property NSString *city, *state;

@property UIRefreshControl *refreshControl;

/// Initializes a new CityView instance with the given properties
- (id)initWithFrame:(CGRect)frame
               name:(NSString*)name
              state:(NSString*)state
              bgUrl:(NSString*)bgUrl;

@end
