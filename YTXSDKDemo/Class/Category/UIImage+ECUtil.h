//
//  UIImage+ECUtil.h
//  YTXSDKDemo
//
//  Created by huangjue on 2017/7/26.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (ECUtil)


/**
 @brief 通过指定颜色生成一张图片

 @param color 颜色
 @return 创建的图片
 */
+ (UIImage *)ec_imageWithColor:(UIColor*)color;


/**
 @brief 通过指定颜色生成一张图片
 
 @param color 颜色
 @param size 尺寸
 @return 创建的图片
 */
+ (UIImage *)ec_imageWithColor:(UIColor*)color withSize:(CGSize)size;


/**
 画出一张圆形图片

 @param color 颜色
 @param size 尺寸
 @return 返回一张圆形图片
 */
+ (UIImage*)ec_circleImageWithColor:(UIColor*)color withSize:(CGSize)size;

/**
 画出一张圆形图片

 @param color 图片背景颜色
 @param size 圆形图片尺寸
 @param name 图片上水印的文字内容
 @return 返回一张圆形图片
 */
+ (UIImage*)ec_circleImageWithColor:(UIColor*)color withSize:(CGSize)size withName:(NSString *)name;

/**
 @brief 群组二维码图片生成

 @param data 群组数据
 @param width 生产二维码图片的宽度
 @return 生成的二维码图片
 */
+ (UIImage *)ec_imageWithQRCodeData:(NSString *)data imageWidth:(CGFloat)width;


/**
 根据视频文件的一个地址获取第一帧图

 @param videoURL 视频文件的地址
 @return 返回第一针图
 */
+ (UIImage *)ec_GetVideoImage:(NSString *)videoURL;


/**
 传入一个view截取截取生成一张图片

 @param shotView 传入要截图的view
 @return 返回一张图片
 */
+ (UIImage *)ec_screenshotWithView:(UIView *)shotView;

/**
 传入一个view截取截取生成一张图片
 
 @param shotView 传入要截图的view
 @param shotSize 截取的范围
 @return 返回一张图片
 */
+ (UIImage *)ec_screenshotWithView:(UIView *)shotView shotSize:(CGSize)shotSize;


/**
 @brief 压缩图片
 
 @param image 待压缩图片
 @param viewsize 需要压缩图片的size
 @return 压缩后图片
 */
+ (UIImage *)ec_compressImage:(UIImage *)image withSize:(CGSize)viewsize;

/**
 @brief 转换图片方向
 
 @param aImage 原始图片
 @return 转换后生成的目标图片
 */
+ (UIImage *)ec_fixOrientation:(UIImage *)aImage;

@end
