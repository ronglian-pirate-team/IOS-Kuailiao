//
//  ECGroupDeclaredCell.h
//  YTXSDKDemo
//
//  Created by xt on 2017/7/27.
//
//

#import <UIKit/UIKit.h>

@interface ECGroupDeclaredCell : UITableViewCell

@property (nonatomic, copy) NSString *groupDeclared;

- (instancetype)initDeclared:(NSString *)groupDeclared reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, assign) BOOL isDiscuss;
@end
