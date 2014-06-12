//
//  WACity.m
//  WeatherApp
//
//  Created by Kenneth Pu on 6/9/14.
//  Copyright (c) 2014 Kenneth Pu. All rights reserved.
//

#import "WACity.h"
#import "WALibraryAPI.h"

@implementation WACity

/// Initializes a City instance with the required properties
- (id)initWithName:(NSString*)name
             state:(NSString*)state
{
    self = [super init];
    if (self) {
        _name = name;
        _state = state;
        NSString* query = [NSString stringWithFormat:@"%@ %@", _name, _state];
        _imgUrl = [[WALibraryAPI sharedInstance] getImageUrl:query];
    }
    return self;
}

/// Initializes a City instance with the required properties
- (id)initWithName:(NSString*)name
             state:(NSString*)state
            imgUrl:(NSString*)imgUrl
{
    self = [super init];
    if (self) {
        _name = name;
        _state = state;
        _imgUrl = imgUrl;
    }
    return self;
}

/// Archives an instance of a City
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.state forKey:@"state"];
    [aCoder encodeObject:self.imgUrl forKey:@"img_url"];
}

/// Unarchives an instance of a City
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        _name = [aDecoder decodeObjectForKey:@"name"];
        _state = [aDecoder decodeObjectForKey:@"state"];
        _imgUrl = [aDecoder decodeObjectForKey:@"img_url"];
    }
    return self;
}

@end