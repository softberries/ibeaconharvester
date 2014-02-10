//
//  IBeaconAnnotation.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 04/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>

@interface IBeaconAnnotation : NSObject <MKAnnotation>
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *subtitle;

@property (nonatomic, copy, readonly) NSString *uuid;
@property (nonatomic) int major;
@property (nonatomic) int minor;

- (instancetype) initWithCoordinates:(CLLocationCoordinate2D)paramCoordinates
                               title:(NSString *)paramTitle
                            subTitle:(NSString *)paramSubTitle
                                uuid:(NSString *)uuid
                               major:(int)major
                               minor:(int)minor;
@end
