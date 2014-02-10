//
//  SettingsViewController.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 09/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "SettingsViewController.h"
#import "SWRevealViewController.h"
#import "UUIDTableViewCell.h"
#import "UUIDItem.h"
#import "AppDelegate.h"
#import "IBHConstants.h"
#import <CoreData/CoreData.h>

@interface SettingsViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *uuidsTable;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UISwitch *notificationsSwitch;

@property (retain) NSMutableArray *uuids;
@end

@implementation SettingsViewController

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
	//add menu bar button
    UIBarButtonItem * showMenuButton =
    [[UIBarButtonItem alloc]
     initWithTitle:@"||||" style:UIBarButtonItemStylePlain
     target:self.revealViewController
     action:@selector( revealToggle: ) ];
    
    self.navigationItem.leftBarButtonItem = showMenuButton ;
    
    //set table delegate and datasource
    [self.uuidsTable setDelegate:self];
    [self.uuidsTable setDataSource:self];
    
    //init uuids array
    self.uuids = [[NSMutableArray alloc]init];
    
    //set up the checkbox for notification setting
    [self.notificationsSwitch addTarget:self action:@selector(setNotificationsState:) forControlEvents:UIControlEventValueChanged];
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:kibh_settings_send_notifications]) {
        [self.notificationsSwitch setOn:YES];
    } else {
        [self.notificationsSwitch setOn:NO];
    }
}

- (void)setNotificationsState:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:[sender isOn] forKey:kibh_settings_send_notifications];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Fetch the devices from persistent data store
    NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UUIDItem"];
    self.uuids = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"found uuidItems: %lu",(unsigned long)[self.uuids count]);
    
    if([self.uuids count] == 0){
        NSLog(@"Creating new uuid");
        //if no uuids were found add the estimote uuid by default
        UUIDItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"UUIDItem" inManagedObjectContext:managedObjectContext];
        item.name = kibh_estimote_name;
        item.uuid = kibh_estimote_uuid;
        NSError *error = nil;
        // Save the object to persistent store
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }else{
            self.uuids = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
        }
    }
    [self.uuidsTable reloadData];
}

#pragma mark - Edit/Save logic

- (IBAction)addUUIDAction:(id)sender {
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    UUIDItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"UUIDItem" inManagedObjectContext:context];
    [self.uuids insertObject:item atIndex:0];
    [self.uuidsTable reloadData];
    [self.addButton setEnabled:NO];
}

- (void)saveUUIDItemBeingEdited:(int)index cell:(UUIDTableViewCell *)cell{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    UUIDItem *item = [self.uuids objectAtIndex:index];
    item.uuid = cell.uuidTxt.text;
    item.name = cell.nameTxt.text;
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    [self.view endEditing:YES];
    [self.addButton setEnabled:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    UUIDTableViewCell *cell =(UUIDTableViewCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [self.uuidsTable indexPathForCell:cell];
    [self saveUUIDItemBeingEdited:indexPath.row cell:cell];
    return YES;
}

#pragma mark - Table related logic

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.uuids count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"uuidCell";
    UUIDTableViewCell *cell = [self.uuidsTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UUIDTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    UUIDItem *item = [self.uuids objectAtIndex:indexPath.row];
    cell.nameTxt.text = item.name;
    cell.uuidTxt.text = item.uuid;
    
    //set text field delegate
    [cell.nameTxt setDelegate:self];
    [cell.uuidTxt setDelegate:self];
    return cell;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    UUIDTableViewCell *cell =(UUIDTableViewCell *) textField.superview.superview.superview;
    NSIndexPath *indexPath = [self.uuidsTable indexPathForCell:cell];
    [self saveUUIDItemBeingEdited:indexPath.row cell:cell];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObjectContext *context = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete object from database
        [context deleteObject:[self.uuids objectAtIndex:indexPath.row]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Can't Delete! %@ %@", error, [error localizedDescription]);
            return;
        }
        
        // Remove device from table view
        [self.uuids removeObjectAtIndex:indexPath.row];
        [self.uuidsTable deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
