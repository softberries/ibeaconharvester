//
//  IBeaconAnnotation.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 04/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "IBeaconAnnotation.h"


@implementation IBeaconAnnotation

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                               title:(NSString *)paramTitle
                            subTitle:(NSString *)paramSubTitle
                                uuid:(NSString *)uuid
                               major:(int)major
                               minor:(int)minor{
    
    self = [super init];
    
    if (self != nil){
        _coordinate = paramCoordinates;
        _title = paramTitle;
        _subtitle = paramSubTitle;
        _uuid = uuid;
        _major = major;
        _minor = minor;
    }
    
    return self;
    
}

@end
