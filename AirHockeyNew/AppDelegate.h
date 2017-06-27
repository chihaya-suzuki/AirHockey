//
//  AppDelegate.h
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleViewController.h"
#import "Bar.h"
#import "Ball.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property float ballSpeed;
@property float enemySpeed;
@property float enemyBarLength;
@property float playerBarLength;
@property float ballSize;
@property NSInteger gameDifficulty;
// バー
@property Bar *playerBar;
@property Bar *enemyBar;

// ボール
@property Ball *ball;

// バーを揺らす用
@property float enemyShakeY;
@property float playerShakeY;

@end

