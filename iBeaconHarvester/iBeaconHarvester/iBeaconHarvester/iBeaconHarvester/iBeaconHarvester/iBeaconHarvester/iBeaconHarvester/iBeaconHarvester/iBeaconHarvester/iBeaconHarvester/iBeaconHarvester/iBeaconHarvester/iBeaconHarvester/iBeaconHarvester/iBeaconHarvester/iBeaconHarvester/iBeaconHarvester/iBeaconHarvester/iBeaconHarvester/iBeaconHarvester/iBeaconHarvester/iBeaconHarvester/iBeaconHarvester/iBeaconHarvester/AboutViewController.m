//
//  AboutViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 04/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "AboutViewController.h"
#import "SWRevealViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    UIBarButtonItem * showMenuButton =
    [[UIBarButtonItem alloc]
     initWithTitle:@"||||" style:UIBarButtonItemStylePlain
     target:self.revealViewController
     action:@selector( revealToggle: ) ];
    self.navigationItem.leftBarButtonItem = showMenuButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
