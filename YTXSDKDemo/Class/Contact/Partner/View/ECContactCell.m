//
//  ECContactCell.m
//  YTXSDKDemo
//
//  Created by xt on 2017/8/29.
//
//

#import "ECContactCell.h"

@implementation ECContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.layer.masksToBounds = YES;
    self.imageView.layer.cornerRadius = 20;
    self.imageView.frame = CGRectMake(12, 7, 40, 40);
    self.imageView.center = CGPointMake(self.imageView.center.x, self.contentView.center.y);
    self.textLabel.ec_x = 64;
    self.separatorInset = UIEdgeInsetsMake(0, 64, 0,  0);
}

@end
