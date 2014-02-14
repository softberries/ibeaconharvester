//
//  AllBeaconsTableViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 01/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "AllBeaconsTableViewController.h"
#import "SWRevealViewController.h"
#import "IBeacon.h"
#import "AppDelegate.h"
#import "BeaconListTableViewCell.h"
#import "BeaconDetailsViewController.h"
#import "IconUtils.h"

@interface AllBeaconsTableViewController () <NSFetchedResultsControllerDelegate>

@property(strong) NSMutableArray *beacons;

@end

@implementation AllBeaconsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    UIBarButtonItem *showMenuButton =
            [[UIBarButtonItem alloc]
                    initWithTitle:@"||||" style:UIBarButtonItemStylePlain
                           target:self.revealViewController
                           action:@selector( revealToggle: )];
    self.navigationItem.leftBarButtonItem = showMenuButton;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    self.beacons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"found beacons: %lu", (unsigned long) [self.beacons count]);
    [self.tableView reloadData];
}

#pragma mark - Table View handling

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSManagedObjectContext *context = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.beacons objectAtIndex:(NSUInteger) indexPath.row]];

        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }

        // Remove device from table view
        [self.beacons removeObjectAtIndex:(NSUInteger) indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.beacons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"beaconCell";
    BeaconListTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BeaconListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    // Configure the cell...
    IBeacon *beacon = [self.beacons objectAtIndex:(NSUInteger) indexPath.row];
    float distance = [beacon.distance floatValue];

    [cell.beaconCellNameLbl setText:beacon.name];
    [cell.beaconCellDistanceLbl setText:[NSString stringWithFormat:@"%0.2f m", distance]];
    [cell.beaconCellUUIDlbl setText:beacon.uuid];
    cell.beaconCellImg.image = [IconUtils findImageByDistance:distance];
    return cell;
}

#pragma mark - Seque handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // configure the destination view controller:
    if ([segue.destinationViewController isKindOfClass:[BeaconDetailsViewController class]] &&
            [sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        BeaconDetailsViewController *cvc = segue.destinationViewController;
        cvc.selectedBeacon = nil;
        cvc.beaconFromDb = [self.beacons objectAtIndex:(NSUInteger) indexPath.row];
    }
    // configure the segue.
    if ([segue isKindOfClass:[SWRevealViewControllerSegue class]]) {
        SWRevealViewControllerSegue *rvcs = (SWRevealViewControllerSegue *) segue;

        SWRevealViewController *rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );

        NSAssert( [rvc.frontViewController isKindOfClass:[UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );

        rvcs.performBlock = ^(SWRevealViewControllerSegue *rvc_segue, UIViewController *svc, UIViewController *dvc) {
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:dvc];
            [rvc setFrontViewController:nc animated:YES];
        };
    }
}
@end
