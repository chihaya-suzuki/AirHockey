//
//  MainViewController.h
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "AppDelegate.h"
#import "BackgroundView.h"
#import "Bar.h"
#import "Ball.h"

@interface MainViewController : UIViewController

/* ゲームモード
 0 タイトル画面からきたばかり
 1 ゲーム中
 2 ボールが入った
 3 ゲーム終了
 */
@property int gameMode;

@end
