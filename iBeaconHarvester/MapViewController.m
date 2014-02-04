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
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>

@interface MapViewController ()<MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (strong) NSMutableArray *beacons;
@property (nonatomic) IBeacon *selectedBeacon;

@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    self.beacons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"found beacons: %d",[self.beacons count]);
    [self reloadData];
}

-(IBeacon *)findIBeacon:(NSString *)uuid major:(int)major minor:(int)minor{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uuid == %@ AND major == %d AND minor == %d", uuid, major, minor]];
    NSArray *beaconsFound = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if(beaconsFound){
        return [beaconsFound objectAtIndex:0];
    }else{
        return nil;
    }
}

-(void)reloadData{
    for(int i = 0; i < [self.beacons count]; i++){
        NSManagedObject *beacon = [self.beacons objectAtIndex:i];
        double latitude = [[beacon valueForKey:@"latitude"] doubleValue];
        double longitude = [[beacon valueForKey:@"longitude"] doubleValue];
        if(latitude == 0 || longitude == 0){
            continue;
        }
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
        NSString *dateString = [formatter stringFromDate:[beacon valueForKey:@"dateAdded"]];
        IBeaconAnnotation *annotation =
        [[IBeaconAnnotation alloc] initWithCoordinates:location
                                                 title:[beacon valueForKey:@"name"]
                                              subTitle:dateString
                                                  uuid:[beacon valueForKey:@"uuid"]
                                                 major:[[beacon valueForKey:@"major"]intValue]
                                                 minor:[[beacon valueForKey:@"minor"]intValue]
         ];
        [self.mapView addAnnotation:annotation];
    }
    NSLog(@"Loading data: %d",[self.beacons count]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    
    UIBarButtonItem * showMenuButton =
    [[UIBarButtonItem alloc]
     initWithTitle:@"||||" style:UIBarButtonItemStylePlain
     target:self.revealViewController
     action:@selector( revealToggle: ) ];
    
    self.navigationItem.leftBarButtonItem = showMenuButton ;
    
    //set up map
    self.mapView.delegate = self;
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"loc"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    IBeaconAnnotation *annotationTapped = (IBeaconAnnotation *)view.annotation;
    NSLog(@"tapped point on the map! %@",annotationTapped.uuid);
    NSLog(@"found iBeacon: %@",[self findIBeacon:annotationTapped.uuid major:annotationTapped.major minor:annotationTapped.minor]);
    self.selectedBeacon = [self findIBeacon:annotationTapped.uuid major:annotationTapped.major minor:annotationTapped.minor];
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [segue.destinationViewController isKindOfClass: [BeaconDetailsViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        BeaconDetailsViewController* cvc = segue.destinationViewController;
        if(self.selectedBeacon){
            cvc.beaconFromDb = self.selectedBeacon;
        }else{
            return;
        }
    }
    // configure the segue.
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );
        
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );
        
        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:dvc];
            [rvc setFrontViewController:nc animated:YES];
        };
    }
}
- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
