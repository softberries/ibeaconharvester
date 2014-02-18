//
//  IconUtilsTests.m
//  iBeaconHarvester
//
//  Test cases for IconUtils
//
//  Created by Krzysztof Grajek on 11/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "IconUtils.h"

@interface IconUtilsTests : XCTestCase

@property (nonatomic, strong) IconUtils *myIconUtils;

@end

@implementation IconUtilsTests

- (void)setUp {
    
    [super setUp];
    [self setMyIconUtils:[[IconUtils alloc]init]];
    
}

- (void)tearDown {
    
    [self setMyIconUtils:nil];
    [super tearDown];
}

- (void)testInitNotNil {
    
    XCTAssertNotNil(self.myIconUtils, @"Test IconUtils object not instantiated");
}

- (void)testFindImageByDistance{
    //marker, markerYellow, markerPink, markerRed else marker
    float distance = 20;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"marker"]]);
    distance = 21;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"marker"]]);
    distance = 19;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"markerYellow"]]);
    distance = 10;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"markerYellow"]]);
    distance = 9;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"markerPink"]]);
    distance = 1;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"markerPink"]]);
    distance = 0.5f;
    XCTAssertTrue([[IconUtils findImageByDistance:distance] isEqual:[UIImage imageNamed:@"markerRed"]]);
}

@end
