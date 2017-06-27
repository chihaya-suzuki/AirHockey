//
//  Bar.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "Bar.h"

@implementation Bar

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
    
    // バー
    CGContextSetRGBFillColor(context,1,1,1,1);
    CGContextSetLineWidth(context,1);
    CGContextFillRect(context,CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height));
}

// バー移動
-(void)move:(int)way{
    CGRect frame = self.frame;
    frame.origin.x += self.speed * way;
    self.frame = frame;
}

@end
