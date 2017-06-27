//
//  BarView.m
//  AirHockeyNew
//
//  Created by Chihaya Suzuki on 2015/09/18.
//  Copyright © 2015年 鈴木千早. All rights reserved.
//

#import "BarView.h"

@implementation BarView

- (void)drawRect:(CGRect)rect {
    // グラフィックスコンテキストの取得(描画に必要 drawRectメソッド内でしか得られない)
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBFillColor(context,1,1,1,1);
    CGContextSetLineWidth(context,1);
    CGContextFillRect(context,CGRectMake(_appDelegate.playerBar.x,_appDelegate.playerBar.y + _appDelegate.playerShakeY,_appDelegate.playerBar.width,_appDelegate.playerBar.height));

}

@end
