//
//  TitleViewController.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "TitleViewController.h"
enum BUTTONTAG{SETTING=100};
@interface TitleViewController ()

@end

@implementation TitleViewController
{
    int _x;
    int _y;
    
    UILabel *_title;
    UILabel *_click;
    UIButton *_settingButton;

    SystemSoundID _soundChangeScreen;
    SystemSoundID _soundStart;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"start" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundStart);
    
    path = [[NSBundle mainBundle] pathForResource:@"change_screen" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundChangeScreen);

    NSTimer *vibrationTimer = nil;
    vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(onTickVibration:) userInfo:nil repeats:YES];
    
    BackgroundView *backgroundView = [[BackgroundView alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width,self.view.frame.size.height)];
    [self.view addSubview:backgroundView];
    
    UILabel *title = [[UILabel alloc]init];
    title.text = @"球をアレするやつ";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont systemFontOfSize:40];
    title.textAlignment = NSTextAlignmentCenter;
    title.frame = CGRectMake(0,self.view.frame.size.height/3-60,self.view.frame.size.width,40);
    
    [self.view addSubview:title];
    _title = title;
    
    UILabel *click = [[UILabel alloc]init];
    click.text = @"PLEASE TOUCH!";
    click.textColor = [UIColor whiteColor];
    click.textAlignment = NSTextAlignmentCenter;
    click.frame = CGRectMake(0,self.view.frame.size.height/2-20,self.view.frame.size.width,20);
    
    [self.view addSubview:click];
    _click = click;
    
    UIButton *settingButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-130,self.view.frame.size.height-50,260,20)];
    
    [settingButton setTitle:@"GAME SETTING" forState:UIControlStateNormal];
    settingButton.tag = SETTING;
    [settingButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:settingButton];
    _settingButton = settingButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickButton:(UIButton *)button
{
    if(button.tag == SETTING){
        AudioServicesPlaySystemSound(_soundChangeScreen);
        SettingViewController *settingViewController = [[SettingViewController alloc]init];
        [self presentViewController:settingViewController animated:YES completion:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    AudioServicesPlaySystemSound(_soundStart);

    MainViewController *mainViewController = [[MainViewController alloc]init];
    mainViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    
    [self presentViewController:mainViewController animated:YES completion:nil];
}

-(void)onTickVibration:(NSTimer *)timer
{
    _x = arc4random_uniform(3)-1;
    _y = arc4random_uniform(3)-1;
    
    _title.frame = CGRectMake(0+_x,self.view.frame.size.height/3-60+_y,self.view.frame.size.width,40);
    
    _x = arc4random_uniform(2)-1;
    _y = arc4random_uniform(2)-1;
    
    _click.frame = CGRectMake(0+_x,self.view.frame.size.height/2-20+_y,self.view.frame.size.width,20);
    
    _x = arc4random_uniform(2)-1;
    _y = arc4random_uniform(2)-1;
    
    _settingButton.frame = CGRectMake(self.view.frame.size.width/2-130+_x,self.view.frame.size.height-50+_y,260,20);
}


@end
