//
//  IBeacon.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 03/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IBeacon : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSNumber * major;
@property (nonatomic, retain) NSNumber * minor;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * firmware;
@property (nonatomic, retain) NSString * hardware;
@property (nonatomic, retain) NSNumber * batteryLevel;
@property (nonatomic, retain) NSNumber * advertisingInterval;
@property (nonatomic, retain) NSString * name;

@end
