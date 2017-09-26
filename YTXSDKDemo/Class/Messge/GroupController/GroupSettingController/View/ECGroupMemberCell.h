//
//  ECGroupMemberCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/28.
//
//

#import <UIKit/UIKit.h>

@interface ECGroupMemberCell : UICollectionViewCell

@property (nonatomic, strong) ECGroupMember *groupMember;
@property (nonatomic, copy) NSString *imageName;

- (void)defaultCell;
@end
