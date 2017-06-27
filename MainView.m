//
//  MainView.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "MainView.h"

@implementation MainView

#pragma mark - イニシャライザ
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    return self;
}

#pragma mark - 描画
- (void)drawRect:(CGRect)rect {
    // グラフィックスコンテキストの取得(描画に必要 drawRectメソッド内でしか得られない)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // コンテキストの保存（クリッピングのため）
    CGContextSaveGState(context);
    
    // グラデーションしたい矩形のパスを作る
    CGContextBeginPath(context);
    CGContextAddRect(context,CGRectMake(0,0,self.layer.frame.size.width,self.layer.frame.size.height));
    CGContextClosePath(context);
    
    // 描画領域をその矩形の領域に限定とする
    CGContextClip(context);
    
    // グラデーション４つ（赤、緑、青、透過）で何色から何色へのグラデーションか指定する
    CGFloat colors[12] = {
        0/255.0f,0/255.0f,0/255.0f,1, // 透けない黒色
        175/255.0f,175/255.0f,175/255.0f,1, // 透けない白
        0/255.0f,0/255.0f,0/255.0f,1 // 透けない黒色
    };
    
    // どこからグラデーションをかけるか0.0〜1.0で指定。仮に3色なら0.0,0.5,1.0のように指定
    CGFloat colorStops[3] = {0.0,0.5,1.0};
    // 色空間オブジェクトの作成(allocに相当)、赤、緑、青の三原色での指定
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // グラデーションオブジェクト生成(allocに相当)
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace,colors,colorStops,3);
    // 色空間オブジェクト解放
    CGColorSpaceRelease(colorSpace);
    // グラデーション描画
    CGContextDrawLinearGradient(context,gradient,CGPointMake(self.layer.frame.size.width/2,0),CGPointMake(self.layer.frame.size.width/2,self.layer.frame.size.height),0);
    
    // グラデーションオブジェクト解放
    CGGradientRelease(gradient);
    // コンテキスト復元(クリッピングオフ)
    CGContextRestoreGState(context);
}

@end