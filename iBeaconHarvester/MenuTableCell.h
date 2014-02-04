//
//  MenuTableCell.h
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 31/01/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *menuItemImg;
@property (weak, nonatomic) IBOutlet UILabel *menuItemTitle;
@property (weak, nonatomic) IBOutlet UILabel *menuItemSubtitle;

@end
