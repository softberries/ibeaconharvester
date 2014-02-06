//
//  IconUtils.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 06/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "IconUtils.h"

@implementation IconUtils


+ (UIImage *)findImageByDistance:(float)distance{
    if(distance >= 20){
        return [UIImage imageNamed:@"marker"];
    }else if(distance >= 10 && distance < 20){
        return [UIImage imageNamed:@"markerYellow"];
    }else if(distance >= 1 && distance < 10){
        return [UIImage imageNamed:@"markerPink"];
    }else if(distance < 1){
        return [UIImage imageNamed:@"markerRed"];
    }else{
        return [UIImage imageNamed:@"marker"];
    }
}

@end
