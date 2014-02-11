//
//  ViewControllerTestTests.m
//  iBeaconHarvester
//
//  Test cases for ViewControllerTest.
//  Setup will instantiate an instance from the storyboard.
//
//  Instructions: modify setup to match the names of your storyboard and vc.
//
//  Created by Krzysztof Grajek on 06/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface ViewControllerTestTests : XCTestCase

@property (nonatomic, strong) ViewController *vc;

@end

@implementation ViewControllerTestTests

- (void)setUp
{
    [super setUp];
    // Replace @"Main" with the name of the viewController as specified in the storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.vc = [storyboard instantiateViewControllerWithIdentifier:@"radar"];
    [self.vc performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];
}

- (void)tearDown
{
    self.vc = nil;
    [super tearDown];
}

- (void)testInitNotNil
{
    XCTAssertNotNil(self.vc, @"Test ViewControllerTest object not instantiated");
}

@end
