//
//  Ball.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "Ball.h"

@implementation Ball

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
    
    // ボール
    CGContextSetRGBFillColor(context,1,1,1,1);
    CGContextFillEllipseInRect(context, CGRectMake(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height));
}

#pragma mark - 移動
// ボール移動
-(void)moveWithMoveX:(float)moveX moveY:(float)moveY{
    CGRect frame = self.frame;
    frame.origin.x += self.speed * moveX;
    frame.origin.y += self.speed * moveY;
    self.frame = frame;
}

// 初動の進行方向ランダム
-(void)moveWay
{
    _moveX = (float)arc4random_uniform(2)*2-1;
    _moveY = (float)arc4random_uniform(2)*2-1;
}

@end
