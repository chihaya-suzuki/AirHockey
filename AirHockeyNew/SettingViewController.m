//
//  SettingViewController.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/15.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()
enum BUTTONTAG{BACK=100,BALL,ENEMY,ENEMYLENGTH,BALLSIZE,PLAYERLENGTH};

@end

@implementation SettingViewController
{
    int _x;
    int _y;
    
    UIButton *_backButton;
    UISlider *_ballSpeedSlider;
    UISlider *_enemySpeedSlider;
    UISlider *_enemyBarSlider;
    UISlider *_ballSizeSlider;
    UISlider *_playerBarSlider;
    
    NSMutableArray *_tableCells;
    UISegmentedControl *_segmentCtrl;
    
    UITableViewCell *_cell1;
    UITableViewCell *_cell2;
    UITableViewCell *_cell3;
    UITableViewCell *_cell4;
    UITableViewCell *_cell5;
    
    SystemSoundID _soundChangeScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"change_screen" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundChangeScreen);
    
    NSTimer *vibrationTimer = nil;
    vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(onTickVibration:) userInfo:nil repeats:YES];

    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // セグメントコントロールインスタンス作成、NSArrayで中の文字をセット
    UISegmentedControl *segmentCtrl = [[UISegmentedControl alloc]initWithItems:@[@"EASY",@"NORMAL",@"HARD"]];
    segmentCtrl.frame = CGRectMake((self.view.frame.size.width-320)/2,10,320,30);
    // 最初に選んでおくボタン（２つめ）
    segmentCtrl.selectedSegmentIndex = appDelegate.gameDifficulty;
    // イベント
    [segmentCtrl addTarget:self action:@selector(segmentChange:) forControlEvents:UIControlEventValueChanged];
    // 色
    segmentCtrl.tintColor = [UIColor whiteColor];
    // 載せたいViewに配置
    [self.view  addSubview:segmentCtrl];
    _segmentCtrl = segmentCtrl;

    // ナビゲーションバー分、テーブルビューを下に下げる
    CGRect tableViewFrame = CGRectMake(0,50,CGRectGetWidth(self.view.bounds),CGRectGetHeight(self.view.bounds)-50);
    UITableView *tableView = [[UITableView alloc]initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
    
    // データソースは自分
    tableView.dataSource = self;
    
    // ビューに配置する
    [self.view addSubview:tableView];
    
    // セルの入れ物作成
    _tableCells = [NSMutableArray array];

    UITableViewCell *cell1 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell1"];
    UISlider *ballSpeedSlider = [[UISlider alloc]initWithFrame:CGRectMake(cell1.frame.origin.x+160,cell1.frame.origin.y,cell1.frame.size.width-120,cell1.frame.size.height)];
    ballSpeedSlider.maximumValue = 10;
    ballSpeedSlider.minimumValue = 1;
    ballSpeedSlider.value = appDelegate.ballSpeed;
    ballSpeedSlider.tag = BALL;
    cell1.textLabel.text = [NSString stringWithFormat:@"BALL SPEED　%.0f",ballSpeedSlider.value];
    [ballSpeedSlider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [cell1.contentView addSubview:ballSpeedSlider];
    [_tableCells addObject:cell1];
    _ballSpeedSlider = ballSpeedSlider;
    _cell1 = cell1;

    UITableViewCell *cell2 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell2"];
    UISlider *ballSizeSlider = [[UISlider alloc]initWithFrame:CGRectMake(cell2.frame.origin.x+160,cell2.frame.origin.y,cell2.frame.size.width-120,cell2.frame.size.height)];
    ballSizeSlider.maximumValue = 150;
    ballSizeSlider.minimumValue = 10;
    ballSizeSlider.value = appDelegate.ballSize;
    ballSizeSlider.tag = BALLSIZE;
    cell2.textLabel.text = [NSString stringWithFormat:@"BALL SIZE　%.0f",ballSizeSlider.value];
    [ballSizeSlider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [cell2.contentView addSubview:ballSizeSlider];
    [_tableCells addObject:cell2];
    _ballSizeSlider = ballSizeSlider;
    _cell2 = cell2;

    UITableViewCell *cell3 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell3."];
    UISlider *enemySpeedSlider = [[UISlider alloc]initWithFrame:CGRectMake(cell3.frame.origin.x+160,cell3.frame.origin.y,cell3.frame.size.width-120,cell3.frame.size.height)];
    enemySpeedSlider.maximumValue = 10;
    enemySpeedSlider.minimumValue = 1;
    enemySpeedSlider.value = appDelegate.enemySpeed;
    enemySpeedSlider.tag = ENEMY;
    cell3.textLabel.text = [NSString stringWithFormat:@"CPU SPEED　%.0f",enemySpeedSlider.value];
    [enemySpeedSlider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [cell3.contentView addSubview:enemySpeedSlider];
    [_tableCells addObject:cell3];
    _enemySpeedSlider = enemySpeedSlider;
    _cell3 = cell3;
    
    UITableViewCell *cell4 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell4"];
    UISlider *enemyBarSlider = [[UISlider alloc]initWithFrame:CGRectMake(cell4.frame.origin.x+160,cell4.frame.origin.y,cell4.frame.size.width-120,cell4.frame.size.height)];
    enemyBarSlider.maximumValue = 400;
    enemyBarSlider.minimumValue = 20;
    enemyBarSlider.value = appDelegate.enemyBarLength;
    enemyBarSlider.tag = ENEMYLENGTH;
    cell4.textLabel.text = [NSString stringWithFormat:@"CPU BAR　%.0f",enemyBarSlider.value];
    [enemyBarSlider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [cell4.contentView addSubview:enemyBarSlider];
    [_tableCells addObject:cell4];
    _enemyBarSlider = enemyBarSlider;
    _cell4 = cell4;

    UITableViewCell *cell5 = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell5"];
    UISlider *playerBarSlider = [[UISlider alloc]initWithFrame:CGRectMake(cell5.frame.origin.x+160,cell5.frame.origin.y,cell5.frame.size.width-120,cell5.frame.size.height)];
    playerBarSlider.maximumValue = 400;
    playerBarSlider.minimumValue = 20;
    playerBarSlider.value = appDelegate.enemyBarLength;
    playerBarSlider.tag = PLAYERLENGTH;
    cell5.textLabel.text = [NSString stringWithFormat:@"PLAYER BAR　%.0f",playerBarSlider.value];
    [playerBarSlider addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    [cell5.contentView addSubview:playerBarSlider];
    [_tableCells addObject:cell5];
    _playerBarSlider = playerBarSlider;
    _cell5 = cell5;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-100,self.view.frame.size.height-50,200,20)];
    
    [backButton setTitle:@"BACK" forState:UIControlStateNormal];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
     backButton.tag = BACK;
    [backButton addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:backButton];
    _backButton = backButton;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)clickButton:(UIButton *)button
{
    if(button.tag == BACK){
        AudioServicesPlaySystemSound(_soundChangeScreen);
        AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
        appDelegate.ballSpeed = _ballSpeedSlider.value;
        appDelegate.enemySpeed = _enemySpeedSlider.value;
        appDelegate.enemyBarLength = _enemyBarSlider.value;
        appDelegate.ballSize = _ballSizeSlider.value;
        appDelegate.playerBarLength = _playerBarSlider.value;
        appDelegate.gameDifficulty = _segmentCtrl.selectedSegmentIndex;
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

}

-(void)onTickVibration:(NSTimer *)timer
{
    _x = arc4random_uniform(2)-1;
    _y = arc4random_uniform(2)-1;
    
    _backButton.frame = CGRectMake(self.view.frame.size.width/2-100+_x,self.view.frame.size.height-50+_y,200,20);
}

-(void)changeValue:(UISlider *)slider
{
    if(slider.tag == BALL) _cell1.textLabel.text = [NSString stringWithFormat:@"BALL SPEED　%.0f",_ballSpeedSlider.value];
    if(slider.tag == BALLSIZE) _cell2.textLabel.text = [NSString stringWithFormat:@"BALL SIZE　%.0f",_ballSizeSlider.value];
    if(slider.tag == ENEMY) _cell3.textLabel.text = [NSString stringWithFormat:@"CPU SPEED　%.0f",_enemySpeedSlider.value];
    if(slider.tag == ENEMYLENGTH) _cell4.textLabel.text = [NSString stringWithFormat:@"CPU BAR　%.0f",_enemyBarSlider.value];
    if(slider.tag == PLAYERLENGTH) _cell5.textLabel.text = [NSString stringWithFormat:@"PLAYER BAR　%.0f",_playerBarSlider.value];
}

#pragma mark - UITableViewDataSource
// セクションごとのデータ件数を教えてあげるメソッド
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_tableCells count];
}

// 各セルの作成
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 用意したセルを返すだけ
    return [_tableCells objectAtIndex:indexPath.row];
}

-(void)segmentChange:(UISegmentedControl *)segmentControl
{
    switch(_segmentCtrl.selectedSegmentIndex){
        case 0:
        {
            [UIView animateWithDuration:1 animations:^{
                [_ballSpeedSlider setValue:3 animated:YES];
                [_ballSizeSlider setValue:40 animated:YES];
                [_enemySpeedSlider setValue:3 animated:YES];
                [_enemyBarSlider setValue:40 animated:YES];
                [_playerBarSlider setValue:120 animated:YES];
            }];
            break;
        }
        case 1:
        {
            [UIView animateWithDuration:1 animations:^{
                [_ballSpeedSlider setValue:4 animated:YES];
                [_ballSizeSlider setValue:20 animated:YES];
                [_enemySpeedSlider setValue:4 animated:YES];
                [_enemyBarSlider setValue:80 animated:YES];
                [_playerBarSlider setValue:80 animated:YES];
            }];
            break;
        }
        case 2:
        {
            [UIView animateWithDuration:1 animations:^{
                [_ballSpeedSlider setValue:8 animated:YES];
                [_ballSizeSlider setValue:8 animated:YES];
                [_enemySpeedSlider setValue:10 animated:YES];
                [_enemyBarSlider setValue:80 animated:YES];
                [_playerBarSlider setValue:40 animated:YES];
            }];
        }
    }
    _cell1.textLabel.text = [NSString stringWithFormat:@"BALL SPEED　%.0f",_ballSpeedSlider.value];
    _cell2.textLabel.text = [NSString stringWithFormat:@"BALL SIZE　%.0f",_ballSizeSlider.value];
    _cell3.textLabel.text = [NSString stringWithFormat:@"CPU SPEED　%.0f",_enemySpeedSlider.value];
    _cell4.textLabel.text = [NSString stringWithFormat:@"CPU BAR　%.0f",_enemyBarSlider.value];
    _cell5.textLabel.text = [NSString stringWithFormat:@"PLAYER BAR　%.0f",_playerBarSlider.value];
}

@end
