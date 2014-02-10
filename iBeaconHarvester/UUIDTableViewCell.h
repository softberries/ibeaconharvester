//
//  UUIDTableViewCell.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 09/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UUIDTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *nameTxt;
@property (weak, nonatomic) IBOutlet UITextField *uuidTxt;

@end
