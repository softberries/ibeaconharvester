//
//  UUIDItem.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 09/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UUIDItem : NSManagedObject

@property (nonatomic, retain) NSString * uuid;
@property (nonatomic, retain) NSString * name;

@end
