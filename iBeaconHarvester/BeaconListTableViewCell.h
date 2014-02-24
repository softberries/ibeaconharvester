//
//  BeaconListTableViewCell.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 03/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BeaconListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *beaconCellNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *beaconCellUUIDlbl;
@property (weak, nonatomic) IBOutlet UILabel *beaconCellDistanceLbl;
@property (weak, nonatomic) IBOutlet UIImageView *beaconCellImg;
@property (weak, nonatomic) IBOutlet UIProgressView *beaconCellRssi;
@property (weak, nonatomic) IBOutlet UILabel *beaconCellMajorLbl;
@property (weak, nonatomic) IBOutlet UILabel *beaconCellMinorLbl;
@end
