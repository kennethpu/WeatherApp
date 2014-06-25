//
//  WACityView.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WACityView : UIView <UITableViewDataSource, UITableViewDelegate>

/// Refresh control to indicate when data is getting refreshed
@property UIRefreshControl *refreshControl;

/// Initializes a new CityView instance with the given properties
- (id)initWithFrame:(CGRect)frame
               name:(NSString*)name
              state:(NSString*)state
              bgUrl:(NSString*)bgUrl;

/// Updates CityView with provided data
- (void)updateDataWithTime:(NSString *)time
                   iconImg:(UIImage *)icon
                conditions:(NSString *)conditions
               temperature:(NSString *)temperature
            hourlyForecast:(NSArray *)hourlyForecast
             dailyForecast:(NSArray *)dailyForecast;

@end
