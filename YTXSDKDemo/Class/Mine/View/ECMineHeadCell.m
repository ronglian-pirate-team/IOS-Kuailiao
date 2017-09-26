//
//  ECMineHeadCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/7/24.
//  Copyright © 2017年 xt. All rights reserved.
//

#import "ECMineHeadCell.h"

#define EC_Person_Icon_WH 64.0f

@implementation ECMineHeadCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        self.detailTextLabel.font = EC_Font_System(10.0f);
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.ec_x = 88.0f;
    self.textLabel.ec_y = 21;
    self.detailTextLabel.ec_y = CGRectGetMaxY(self.textLabel.frame) + 10;
    self.detailTextLabel.ec_x = self.textLabel.ec_x;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = EC_Person_Icon_WH / 2;
    self.imageView.frame = CGRectMake(12, 10, EC_Person_Icon_WH, EC_Person_Icon_WH);
}

@end
