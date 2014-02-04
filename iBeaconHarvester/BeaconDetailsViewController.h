//
//  BeaconDetailsViewController.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 03/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ESTBeacon.h"
#import "IBeacon.h"

@interface BeaconDetailsViewController : UIViewController

@property (nonatomic) ESTBeacon *selectedBeacon;
@property (nonatomic) IBeacon *beaconFromDb;

@end
