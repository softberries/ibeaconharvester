//
//  BeaconDetailsViewController.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 03/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ESTBeacon;
@class IBeacon;

@interface BeaconDetailsViewController : UIViewController

@property(nonatomic) ESTBeacon *selectedBeacon;
@property(nonatomic) IBeacon *beaconFromDb;

@end
