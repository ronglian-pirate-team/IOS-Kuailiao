//
//  ECRecordShortVideoVC.h
//  YTXSDKDemo
//
//  Created by xt on 2017/8/8.
//
//

#import <UIKit/UIKit.h>

@protocol ECRecordShortVideoDelegate <NSObject>

- (void)didFinishRecordingToOutputFilePath:(NSString *)outputFilePath;

@end

@interface ECRecordShortVideoVC : UIViewController

@property (nonatomic, assign) NSTimeInterval videoMaximumDuration;
@property (nonatomic, assign) NSTimeInterval videoMinimumDuration;
@property (nonatomic, weak) id<ECRecordShortVideoDelegate> delegate;

- (instancetype)initWithOutputFilePath:(NSString *)outputFilePath outputSize:(CGSize)outputSize themeColor:(UIColor *)themeColor;

@end
