//
//  Ball.h
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Ball : UIView

@property float speed;
@property float moveX;
@property float moveY;

-(void)moveWithMoveX:(float)moveX moveY:(float)moveY;
-(void)moveWay;

@end
