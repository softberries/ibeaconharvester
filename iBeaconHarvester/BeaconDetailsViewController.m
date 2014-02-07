//
//  BeaconDetailsViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 03/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "BeaconDetailsViewController.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "ESTBeaconManager.h"
#import "MBProgressHUD.h"
#import "IBeaconAnnotation.h"
#import <MapKit/MapKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@interface BeaconDetailsViewController ()<CLLocationManagerDelegate, ESTBeaconDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *majorNrLbl;
@property (weak, nonatomic) IBOutlet UILabel *minorNrLbl;
@property (weak, nonatomic) IBOutlet UILabel *batteryLevelLbl;
@property (weak, nonatomic) IBOutlet UILabel *advIntervalLbl;
@property (weak, nonatomic) IBOutlet UILabel *hardwareVerLbl;
@property (weak, nonatomic) IBOutlet UILabel *firmwareVerLbl;
@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *uuidLbl;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic) MBProgressHUD *hud;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

@implementation BeaconDetailsViewController

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
     [self.navigationController.view setUserInteractionEnabled:NO];
    [self displayIBeaconInformation];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

#pragma mark - iBeacon manager handling code

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    
    /* We received the new location */
    self.latitude = newLocation.coordinate.latitude;
    self.longitude = newLocation.coordinate.longitude;
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    /* Failed to receive user's location */
}

- (void)beaconDidDisconnect:(ESTBeacon *)beacon withError:(NSError *)error{
    NSLog(@"iBeacon disconnected!!!!");
    [self.navigationController.view setUserInteractionEnabled:YES];
}
- (void)beaconConnectionDidFail:(ESTBeacon*)beacon withError:(NSError*)error{
    NSLog(@"iBeacon connection failed!");
    self.hud.labelText = @"iBeacon Connection Failed!";
    [self.saveBtn setEnabled:NO];
    [self.hud hide:YES afterDelay:3];
    [self.navigationController.view setUserInteractionEnabled:YES];
}

- (void)beaconConnectionDidSucceeded:(ESTBeacon*)beacon{
    NSLog(@"iBeacon connected!!!!");
    self.hud.labelText = @"iBeacon Connected";
    [self.hud hide:YES afterDelay:1];
    
    //set up the rest of the fields
    [self.nameTxt setText:self.selectedBeacon.peripheral.name];
    [self.batteryLevelLbl setText:[NSString stringWithFormat:@"%d %%",self.selectedBeacon.batteryLevel.intValue]];
    [self.advIntervalLbl setText:[NSString stringWithFormat:@"%d", self.selectedBeacon.advInterval.intValue]];
    [self.hardwareVerLbl setText: self.selectedBeacon.hardwareVersion];
    [self.firmwareVerLbl setText: self.selectedBeacon.firmwareVersion];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    [self showBeaconOnTheMap:self.selectedBeacon.peripheral.name dateStr:dateString];
    [self.selectedBeacon disconnectBeacon];
}


#pragma mark - Display iBeacon info

-(void)displayIBeaconInformation{
    if(self.selectedBeacon){
        [self displayIBeaconFromManager];
    }else if(self.beaconFromDb){
        [self displayIBeaconFromDatabase];
    }
}

/* called when the ibeacon given is from the ibeaconmanager */
-(void)displayIBeaconFromDatabase{
    self.nameTxt.text = [self.beaconFromDb valueForKey:@"name"];
    self.uuidLbl.text = [self.beaconFromDb valueForKey:@"uuid"];
    self.majorNrLbl.text = [[self.beaconFromDb valueForKey:@"major"] stringValue];
    self.minorNrLbl.text = [[self.beaconFromDb valueForKey:@"minor"]stringValue];
    self.firmwareVerLbl.text = [self.beaconFromDb valueForKey:@"firmware"];
    self.hardwareVerLbl.text = [self.beaconFromDb valueForKey:@"hardware"];
    self.batteryLevelLbl.text = [NSString stringWithFormat:@"%@ %%",[[self.beaconFromDb valueForKey:@"batteryLevel"]stringValue]];
    self.advIntervalLbl.text = [[self.beaconFromDb valueForKey:@"advertisingInterval"]stringValue];
    [self.saveBtn setEnabled:NO];
    
    //set the map
    self.latitude = [[self.beaconFromDb valueForKey:@"latitude"]doubleValue];
    self.longitude = [[self.beaconFromDb valueForKey:@"longitude"]doubleValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MM-yyyy HH:mm"];
    NSString *dateString = [formatter stringFromDate:[self.beaconFromDb valueForKey:@"dateAdded"]];
    [self showBeaconOnTheMap:self.nameTxt.text dateStr:dateString];
    [self.navigationController.view setUserInteractionEnabled:YES];
}
/* called when the ibeacon given is from the database */
-(void)displayIBeaconFromManager{
    self.uuidLbl.text = self.selectedBeacon.proximityUUID.UUIDString;
    self.majorNrLbl.text = [NSString stringWithFormat:@"%d",self.selectedBeacon.major.intValue];
    self.minorNrLbl.text = [NSString stringWithFormat:@"%d", self.selectedBeacon.minor.intValue];
    self.firmwareVerLbl.text = self.selectedBeacon.firmwareVersion;
    self.hardwareVerLbl.text = self.selectedBeacon.hardwareVersion;
    self.batteryLevelLbl.text = [NSString stringWithFormat:@"%.02f", self.selectedBeacon.batteryLevel.floatValue];
    self.advIntervalLbl.text = [NSString stringWithFormat:@"%d", self.selectedBeacon.advInterval.intValue];
    
    //location services
    if ([CLLocationManager locationServicesEnabled]){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        
        [self.locationManager startUpdatingLocation];
    } else {
        /* Location services are not enabled.
         Take appropriate action: for instance, prompt the
         user to enable the location services */
        NSLog(@"Location services are not enabled");
    }
    [self.selectedBeacon setDelegate:self];
    [self.selectedBeacon connectToBeacon];
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    // Set determinate bar mode
    self.hud.mode = MBProgressHUDModeIndeterminate;
    
    self.hud.delegate = self;
    
    // myProgressTask uses the HUD instance to update progress
    self.hud.labelText = @"Connecting to iBeacon...";
    [self.hud show:YES];
}
- (void)showIBeaconOnTheMap:(double)latitude
                  longitude:(double)longitude
                      title:(NSString *)title
                   subtitle:(NSString *)subtitle
                       uuid:(NSString *)uuid
                      major:(int)major
                      minor:(int)minor
{
    /* This is just a sample location */
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(latitude, longitude);
    
    /* Create the annotation using the location */
    IBeaconAnnotation *annotation =
    [[IBeaconAnnotation alloc] initWithCoordinates:location
                                             title:title
                                          subTitle:subtitle
                                              uuid:uuid
                                             major:major
                                             minor:minor
     ];
    
    /* And eventually add it to the map */
    [self.mapView addAnnotation:annotation];
    
}

- (void) showBeaconOnTheMap:(NSString *)name dateStr:(NSString *)dateStr{
    [self showIBeaconOnTheMap:self.latitude
                    longitude:self.longitude
                        title:name subtitle:dateStr
                         uuid:nil
                        major:0
                        minor:0];
}

#pragma mark - Seque handling

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    if(self.selectedBeacon && self.selectedBeacon.isConnected){
        [self.selectedBeacon disconnectBeacon];
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

#pragma mark - Core Data

-(IBeacon *)findIBeacon:(NSString *)uuid major:(int)major minor:(int)minor{
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"uuid == %@ AND major == %d AND minor == %d", uuid, major, minor]];
    NSArray *beaconsFound = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    if(beaconsFound && [beaconsFound count] > 0){
        return [beaconsFound objectAtIndex:0];
    }else{
        return nil;
    }
}

- (IBAction)save:(id)sender {
    NSManagedObjectContext *context = [self managedObjectContext];
    IBeacon *bikon = [self findIBeacon:self.uuidLbl.text major:[self.majorNrLbl.text intValue] minor:[self.minorNrLbl.text intValue]];
    if(bikon){
        NSLog(@"saving existing object...");
        [bikon setValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
        [bikon setValue:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
        [bikon setValue:self.hardwareVerLbl.text forKey:@"hardware"];
        [bikon setValue:self.firmwareVerLbl.text forKey:@"firmware"];
        [bikon setValue:[NSDate date] forKey:@"dateAdded"];
        [bikon setValue:[NSNumber numberWithFloat:[self.batteryLevelLbl.text floatValue]] forKey:@"batteryLevel"];
        [bikon setValue:[NSNumber numberWithInteger:[self.advIntervalLbl.text integerValue]] forKey:@"advertisingInterval"];
        [bikon setValue:[NSNumber numberWithFloat:[self.selectedBeacon.distance floatValue]] forKey:@"distance"];
    }else{
        // Create a new managed object
        NSLog(@"saving new object...");
        NSManagedObject *newBeacon = [NSEntityDescription insertNewObjectForEntityForName:@"IBeacon" inManagedObjectContext:context];
        [newBeacon setValue:self.uuidLbl.text forKey:@"uuid"];
        [newBeacon setValue:self.nameTxt.text forKey:@"name"];
        [newBeacon setValue:[NSNumber numberWithInteger:[self.minorNrLbl.text integerValue]] forKey:@"minor"];
        [newBeacon setValue:[NSNumber numberWithInteger:[self.majorNrLbl.text integerValue]] forKey:@"major"];
        [newBeacon setValue:[NSNumber numberWithDouble:self.latitude] forKey:@"latitude"];
        [newBeacon setValue:[NSNumber numberWithDouble:self.longitude] forKey:@"longitude"];
        [newBeacon setValue:self.hardwareVerLbl.text forKey:@"hardware"];
        [newBeacon setValue:self.firmwareVerLbl.text forKey:@"firmware"];
        [newBeacon setValue:[NSDate date] forKey:@"dateAdded"];
        [newBeacon setValue:[NSNumber numberWithFloat:[self.batteryLevelLbl.text floatValue]] forKey:@"batteryLevel"];
        [newBeacon setValue:[NSNumber numberWithInteger:[self.advIntervalLbl.text integerValue]] forKey:@"advertisingInterval"];
        [newBeacon setValue:[NSNumber numberWithFloat:[self.selectedBeacon.distance floatValue]] forKey:@"distance"];
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [self.revealViewController revealToggleAnimated:YES];
}

- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}

@end
