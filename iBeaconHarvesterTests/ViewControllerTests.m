//
//  ViewControllerTests.m
//  iBeaconHarvester
//
//  Test cases for ViewController
//
//  Created by Krzysztof Grajek on 14/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ViewController.h"

@interface ViewControllerTests : XCTestCase

@property (nonatomic, strong) ViewController *myViewController;

@end

@implementation ViewControllerTests

- (void)setUp {
    
    [super setUp];
    [self setMyViewController:[[ViewController alloc]init]];
    
}

- (void)tearDown {
    
    [self setMyViewController:nil];
    [super tearDown];
}

- (void)testInitNotNil {
    
    XCTAssertNotNil(self.myViewController, @"Test ViewController object not instantiated");
}

- (void)testThatMethodAReturns64 {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.myViewController = [storyboard instantiateViewControllerWithIdentifier:@"radar"];
    [self.myViewController performSelectorOnMainThread:@selector(loadView) withObject:nil waitUntilDone:YES];

}

@end
