//
//  UUIDTableViewCell.m
//  iBeaconHarvester
//
//  Created by Krzysztof Grajek on 09/02/14.
//  Copyright (c) 2014 Krzysztof Grajek. All rights reserved.
//

#import "UUIDTableViewCell.h"

@implementation UUIDTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
