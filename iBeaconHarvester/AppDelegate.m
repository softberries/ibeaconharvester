//
//  AppDelegate.m
//  BeaconHarvester
//
//  Created by Krzysztof Grajek on 31/01/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "AppDelegate.h"
#import "IBeacon.h"
#import "UUIDItem.h"
#import "IBHConstants.h"

@implementation AppDelegate


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"iBeaconHarvester" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"iBeaconHarvester.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        [self displayValidationError:error];
    }
    
    return _persistentStoreCoordinator;
}

- (void)displayValidationError:(NSError *)anError {
    if (anError && [[anError domain] isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;
        
        // multiple errors?
        if ([anError code] == NSValidationMultipleErrorsError) {
            errors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
        
        if (errors && [errors count] > 0) {
            NSString *messages = @"Reason(s):\n";
            
            for (NSError * error in errors) {
                NSString *entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString *attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
                NSString *msg;
                switch ([error code]) {
                    case NSManagedObjectValidationError:
                        msg = @"Generic validation error.";
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        msg = [NSString stringWithFormat:@"The attribute '%@' must not be empty.", attributeName];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' doesn't have enough entries.", attributeName];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' has too many entries.", attributeName];
                        break;
                    case NSValidationRelationshipDeniedDeleteError:
                        msg = [NSString stringWithFormat:@"To delete, the relationship '%@' must be empty.", attributeName];
                        break;
                    case NSValidationNumberTooLargeError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too large.", attributeName];
                        break;
                    case NSValidationNumberTooSmallError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too small.", attributeName];
                        break;
                    case NSValidationDateTooLateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too late.", attributeName];
                        break;
                    case NSValidationDateTooSoonError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too soon.", attributeName];
                        break;
                    case NSValidationInvalidDateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is invalid.", attributeName];
                        break;
                    case NSValidationStringTooLongError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too long.", attributeName];
                        break;
                    case NSValidationStringTooShortError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too short.", attributeName];
                        break;
                    case NSValidationStringPatternMatchingError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' doesn't match the required pattern.", attributeName];
                        break;
                    default:
                        msg = [NSString stringWithFormat:@"Unknown error (code %i).", [error code]];
                        break;
                }
                
                messages = [messages stringByAppendingFormat:@"%@%@%@\n", (entityName?:@""),(entityName?@": ":@""),msg];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation Error"
                                                            message:messages
                                                           delegate:nil
                                                  cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //set up default settings if not yest set
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kibh_settings_send_notifications]==nil){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kibh_settings_send_notifications];
    }
    //set up estimote as default
    NSManagedObjectContext *managedObjectContext = [(AppDelegate *)[[UIApplication sharedApplication] delegate] managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"UUIDItem"];
    NSArray *uuids = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if([uuids count] == 0){
        //if no uuids were found add the estimote uuid by default
        UUIDItem *item = [NSEntityDescription insertNewObjectForEntityForName:@"UUIDItem" inManagedObjectContext:managedObjectContext];
        item.name = kibh_estimote_name;
        item.uuid = kibh_estimote_uuid;
        NSError *error = nil;
        // Save the object to persistent store
        if (![managedObjectContext save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
