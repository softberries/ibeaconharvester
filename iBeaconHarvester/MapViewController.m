//
//  MapViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 31/01/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "MapViewController.h"
#import "SWRevealViewController.h"
#import "IBeaconAnnotation.h"
#import "IBeacon.h"
#import "BeaconDetailsViewController.h"
#import "AppDelegate.h"

@interface MapViewController () <MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property(weak, nonatomic) IBOutlet MKMapView *mapView;
@property(strong) NSMutableArray *beacons;
@property(nonatomic) IBeacon *selectedBeacon;

@end

@implementation MapViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    self.beacons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    [self reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController.navigationBar addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    UIBarButtonItem *showMenuButton =
            [[UIBarButtonItem alloc]
                    initWithTitle:@"||||" style:UIBarButtonItemStylePlain
                           target:self.revealViewController
                           action:@selector( revealToggle: )];

    self.navigationItem.leftBarButtonItem = showMenuButton;

    //set up map
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

/*
 Puts all the iBeacons found in the database onto the mapview
 */
- (void)reloadData {
    for (int i = 0; i < [self.beacons count]; i++) {
        IBeacon *beacon = [self.beacons objectAtIndex:(NSUInteger) i];
        double latitude = [[beacon valueForKey:@"latitude"] doubleValue];
        double longitude = [[beacon valueForKey:@"longitude"] doubleValue];
        if (latitude == 0 || longitude == 0) {
            continue;
        }
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        NSString *dateString = [formatter stringFromDate:[beacon valueForKey:@"dateAdded"]];
        IBeaconAnnotation *annotation =
                [[IBeaconAnnotation alloc] initWithCoordinates:location
                                                         title:beacon.name
                                                      subTitle:dateString
                                                          uuid:beacon.uuid
                                                         major:[beacon.major intValue]
                                                         minor:[beacon.minor intValue]
                ];
        [self.mapView addAnnotation:annotation];
    }
}

#pragma mark - MapView handling

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    IBeaconAnnotation *annotationTapped = (IBeaconAnnotation *) view.annotation;
    self.selectedBeacon = [self findIBeacon:annotationTapped.uuid major:annotationTapped.major minor:annotationTapped.minor];
    [self performSegueWithIdentifier:@"iBeaconDetail" sender:view];
}

#pragma mark - Core Data

/*
 Find iBeacon in the database when the annotation is clicked on the map.
 */
- (IBeacon *)findIBeacon:(NSString *)uuid major:(int)major minor:(int)minor {
    NSManagedObjectContext *managedObjectContext = [(AppDelegate *) [[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uuid == %@ AND major == %d AND minor == %d", uuid, major, minor]];
    NSArray *beaconsFound = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if (beaconsFound) {
        return [beaconsFound objectAtIndex:0];
    } else {
        return nil;
    }
}

#pragma mark - Segue handling

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // configure the destination view controller:
    if ([segue.destinationViewController isKindOfClass:[BeaconDetailsViewController class]]) {
        BeaconDetailsViewController *cvc = segue.destinationViewController;
        if (self.selectedBeacon) {
            cvc.beaconFromDb = self.selectedBeacon;
        } else {
            return;
        }
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
