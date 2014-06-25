//
//  WACoreDataWeather.h
//  WeatherApp
//
//  Created by Kenneth Pu on 6/24/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface WACoreDataWeather : NSManagedObject

@property (nonatomic, retain) NSString * condition;
@property (nonatomic, retain) NSNumber * temperature;
@property (nonatomic, retain) NSNumber * hiTemp;
@property (nonatomic, retain) NSNumber * loTemp;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * time;

@end
