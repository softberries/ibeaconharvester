//
//  ViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 31/01/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "ViewController.h"
#import "ESTBeaconManager.h"
#import "BeaconListTableViewCell.h"
#import "BeaconDetailsViewController.h"
#import "MBProgressHUD.h"
#import "IBeacon.h"
#import <CoreData/CoreData.h>

@interface ViewController ()<ESTBeaconManagerDelegate, UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nrOfBeaconsLbl;
@property (weak, nonatomic) IBOutlet UITableView *beaconsListTableView;

@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, copy) NSArray* beacons;
@property (nonatomic) MBProgressHUD *hud;

//core data
@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (strong) NSMutableArray *dbBeacons;
@property (nonatomic) NSMutableDictionary *beaconDict;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    
    //iBeacon menager initialization
    self.beaconManager = [[ESTBeaconManager alloc] init];
    self.beaconManager.delegate = self;
    self.beaconManager.avoidUnknownStateBeacons = YES;
    
    ESTBeaconRegion *region = [[ESTBeaconRegion alloc] initRegionWithIdentifier:@"iBeaconHarvesterRegion"];
    // start looking for estimote beacons in region
    // when beacon ranged beaconManager:didRangeBeacons:inRegion: invoked
    [self.beaconManager startRangingBeaconsInRegion:region];
    
    //register current class as delegate and data source for the table view
    [self.beaconsListTableView setDelegate:self];
    [self.beaconsListTableView setDataSource:self];
    
    
    UIBarButtonItem * showMenuButton =
    [[UIBarButtonItem alloc]
     initWithTitle:@"||||" style:UIBarButtonItemStylePlain
     target:self.revealViewController
     action:@selector( revealToggle: ) ];
    
    self.navigationItem.leftBarButtonItem = showMenuButton ;
    self.title = @"Radar";
    
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:self.hud];
	
	// Set determinate bar mode
	self.hud.mode = MBProgressHUDModeAnnularDeterminate;
	
	self.hud.delegate = self;
    
    // myProgressTask uses the HUD instance to update progress
	[self.hud showWhileExecuting:@selector(showLoader) onTarget:self withObject:nil animated:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IBeacon"];
    self.beacons = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"beacons in db: %d",[self.beacons count]);
    [self populateBeaconNames];
}

-(void)populateBeaconNames{
    self.beaconDict = [[NSMutableDictionary alloc] init];
    for(int i = 0; i < [self.beacons count]; i++){
        NSManagedObject *beacon = [self.beacons objectAtIndex:i];
        NSString *key = [NSString stringWithFormat:@"%@--%@--%@",
                         [beacon valueForKey:@"uuid"],
                         [[beacon valueForKey:@"major"] stringValue],
                         [[beacon valueForKey:@"minor"] stringValue]];
        NSLog(@"Key: %@ , Value: %@",key,[beacon valueForKey:@"name"]);
        [self.beaconDict setObject:[beacon valueForKey:@"name"] forKey:key];
    }
}

-(NSString *)findBeaconName:(NSString *)uuid major:(int)major minor:(int)minor{
    NSString *key = [NSString stringWithFormat:@"%@--%d--%d",uuid, major, minor];
    NSLog(@"Finding beacon: %@", key);
    NSLog(@"found: %@",[self.beaconDict objectForKey:key]);
    return [self.beaconDict objectForKey:key];
}

/*
 B9407F30-F5F8-466E-AFF9-25556B57FE6D--5728--54971 , Value: estimote
 B9407F30-F5F8-466E-AFF9-25556B57FE6D--5728--54971 , Value: estimote
 B9407F30-F5F8-466E-AFF9-25556B57FE6D--2784--56774 , Value: estimote
 
 B9407F30-F5F8-466E-AFF9-25556B57FE6D--2784--56774
 
 */

- (void)showLoader {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		self.hud.progress = progress;
		usleep(5000);
	}
    //end of HUD
}

-(void)beaconManager:(ESTBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(ESTBeaconRegion *)region
{
    self.beacons = beacons;
    int size = [beacons count];
    NSLog(@"There are %d beacons in the array", size);
    NSString *noBStr = [NSString stringWithFormat:@"%d", size];
    [self.nrOfBeaconsLbl setText:noBStr];
    [self.beaconsListTableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.beacons){
        return [self.beacons count];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"beaconCell";
    BeaconListTableViewCell *cell = [self.beaconsListTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[BeaconListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    ESTBeacon *closestBeacon = [self.beacons objectAtIndex:indexPath.row];
    float distance = closestBeacon.distance.floatValue;
    cell.beaconCellImg.image = [self findImageByDistance:distance];
    NSString *name = [self findBeaconName:closestBeacon.proximityUUID.UUIDString major:closestBeacon.major.intValue minor:closestBeacon.minor.intValue];
    if(name){
        cell.beaconCellNameLbl.text = name;
    }
    cell.beaconCellUUIDlbl.text = @"Unknown";
    cell.beaconCellDistanceLbl.text = [NSString stringWithFormat:@"%.02f m",distance];
    cell.beaconCellUUIDlbl.text = closestBeacon.proximityUUID.UUIDString;
    return cell;
}

- (UIImage *)findImageByDistance:(float)distance{
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


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    // configure the destination view controller:
    if ( [segue.destinationViewController isKindOfClass: [BeaconDetailsViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        NSIndexPath *indexPath = [self.beaconsListTableView indexPathForCell:sender];
        BeaconDetailsViewController* cvc = segue.destinationViewController;
        if(self.beacons.count > 0){
            cvc.selectedBeacon = [self.beacons objectAtIndex:indexPath.row];
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
