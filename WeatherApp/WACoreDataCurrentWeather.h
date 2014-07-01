//
//  WACoreDataCurrentWeather.h
//  WeatherApp
//
//  Created by Kenneth Pu on 7/1/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class WACoreDataCity;

@interface WACoreDataCurrentWeather : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) WACoreDataCity *city;

@end
