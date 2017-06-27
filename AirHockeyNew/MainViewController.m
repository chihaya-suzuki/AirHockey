//
//  MainViewController.m
//  AirHockeyNew
//
//  Created by 鈴木千早 on 2015/09/14.
//  Copyright (c) 2015年 鈴木千早. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    // クラス保管用
    AppDelegate *_appDelegate;
    Ball *_ball;
    Bar *_enemyBar;
    Bar *_playerBar;

    // フレーム保管用
    CGRect _ballFrame;
    CGRect _enemyBarFrame;
    CGRect _playerBarFrame;
    
    // SE用
    SystemSoundID _soundBounce;
    SystemSoundID _soundEnd;
    SystemSoundID _soundGetScore;
    SystemSoundID _soundChangeScreen;
    SystemSoundID _soundShrink;
    
    // 進行方向系
    int _ballWay;
    int _enemyWay;

    // タイマー
    __weak NSTimer *_barTimer;
    __weak NSTimer *_ballTimer;
    __weak NSTimer *_bombTimer;
    __weak NSTimer *_labelTimer;
    __weak NSTimer *_mainTimer;
    __weak NSTimer *_vibrationTimer;
    
    // スコア
    int _playerScore;
    int _enemyScore;
    
    // ラベル保管用
    UILabel *_playerScoreLabel;
    UILabel *_enemyScoreLabel;
    UILabel *_gameEnd;
    UILabel *_endMessage;
    
    CGFloat _labelAlpha;
    
    // バー揺らす用カウント
    int _shakeCount;
    
    // バーを揺らすポイント数
    int _x;
    int _y;
    
    // バーの距離縮める用カウント
    int distanceCount;
}

#pragma mark - 初期化処理
-(void)myInit
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication]delegate];
    
    // 背景
    BackgroundView *backgroundView = [[BackgroundView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:backgroundView];
    
    // プレイヤーのバー作成
    Bar *playerBar = [[Bar alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - appDelegate.playerBarLength / 2, self.view.frame.size.height - 80 - 20, appDelegate.playerBarLength, 20)];
    _playerBar = playerBar;
    // 判定用にフレーム情報を避難
    _playerBarFrame = playerBar.frame;
    [self.view addSubview:playerBar];
    
    // 敵のバー作成
    Bar *enemyBar = [[Bar alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - appDelegate.enemyBarLength / 2, 80, appDelegate.enemyBarLength, 20)];
    _enemyBar = enemyBar;
    _enemyBar.speed = appDelegate.enemySpeed;
    // 判定用にフレーム情報を避難
    _enemyBarFrame = enemyBar.frame;
    [self.view addSubview:enemyBar];

    // ボールの作成
    Ball *ball = [[Ball alloc]initWithFrame:CGRectMake(self.view.frame.size.width / 2 - appDelegate.ballSize / 2  , self.view.frame.size.height / 2 - appDelegate.ballSize / 2, appDelegate.ballSize, appDelegate.ballSize)];
    _ball = ball;
    // 判定用にフレーム情報を避難
    _ballFrame = ball.frame;
    _ball.speed = appDelegate.ballSpeed;
    // opaque属性にNOを設定する事で、背景透過を許可する
    ball.opaque = NO;
    // backgroundColorにalpha=0.0fの背景色を設定することで、背景色を透明にしている
    ball.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.0f];
    [self.view addSubview:ball];
    // 移動方向初期値
    [ball moveWay];
    
    // バー揺らし用
    appDelegate.enemyShakeY = 0;
    appDelegate.playerShakeY = 0;
    
    // バー移動タイマー
    _barTimer = nil;
    
    // ボール移動タイマー
    _ballTimer = nil;
    
    // 当たった時のエフェクトタイマー
    _bombTimer = nil;
    
    // ラベル透過用タイマー
    _labelTimer = nil;
    
    // 文字揺らしタイマー
    _vibrationTimer = nil;
    
    // ゲーム状況判断変数
    _gameMode = 0;
    
    // バーの距離縮める用
    distanceCount = 0;
    
    // ラベル透過変数、最初は表示
    _labelAlpha = 1;
    
    // クラス保管用
    _appDelegate = appDelegate;
    
    //効果音ファイル読み込み
    NSString *path = [[NSBundle mainBundle] pathForResource:@"bounce" ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundBounce);
    
    path = [[NSBundle mainBundle] pathForResource:@"end" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundEnd);
    
    path = [[NSBundle mainBundle] pathForResource:@"get_score" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundGetScore);
    
    path = [[NSBundle mainBundle] pathForResource:@"change_screen" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundChangeScreen);
    
    path = [[NSBundle mainBundle] pathForResource:@"shrink" ofType:@"mp3"];
    url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &_soundShrink);
}

// 次のターンに行く前の初期化
-(void)nextTurnInit
{
    if(!(_playerScore == 5 || _enemyScore == 5)){
        AudioServicesPlaySystemSound(_soundGetScore);
    }
    
    _gameMode = 2;
    _labelAlpha = 1;
    _ballFrame.origin.x = [UIScreen mainScreen].bounds.size.width / 2 - _appDelegate.ballSize / 2;
    _ballFrame.origin.y = [UIScreen mainScreen].bounds.size.height / 2 - _appDelegate.ballSize / 2;
    _playerBarFrame.origin.x = [UIScreen mainScreen].bounds.size.width / 2 - _appDelegate.playerBarLength / 2;
    _playerBarFrame.origin.y = [UIScreen mainScreen].bounds.size.height - 80 - 20;
    _enemyBarFrame.origin.x = [UIScreen mainScreen].bounds.size.width / 2 - _appDelegate.enemyBarLength / 2;
    _enemyBarFrame.origin.y = 80;
    distanceCount = 0;
    [_ball moveWay];
}

#pragma mark - ラベル描画
-(void)drawLabel
{
    // スコア＆メッセージのラベル作成（まずは非表示）
    UILabel *enemyScoreLabel = [[UILabel alloc]init];
    enemyScoreLabel.text = [NSString stringWithFormat:@"%d",_enemyScore];
    enemyScoreLabel.textColor = [UIColor whiteColor];
    enemyScoreLabel.font = [UIFont systemFontOfSize:150];
    enemyScoreLabel.textAlignment = NSTextAlignmentCenter;
    enemyScoreLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-100,[UIScreen mainScreen].bounds.size.height/2-200-50,200,200);
    enemyScoreLabel.alpha = 0;
    
    [self.view addSubview:enemyScoreLabel];
    _enemyScoreLabel = enemyScoreLabel;
    
    UILabel *playerScoreLabel = [[UILabel alloc]init];
    playerScoreLabel.text = [NSString stringWithFormat:@"%d",_playerScore];
    playerScoreLabel.textColor = [UIColor whiteColor];
    playerScoreLabel.font = [UIFont systemFontOfSize:150];
    playerScoreLabel.textAlignment = NSTextAlignmentCenter;
    playerScoreLabel.frame = CGRectMake([UIScreen mainScreen].bounds.size.width/2-100,[UIScreen mainScreen].bounds.size.height/2+50,200,200);
    playerScoreLabel.alpha = 0;
    
    [self.view addSubview:playerScoreLabel];
    _playerScoreLabel = playerScoreLabel;
    
    UILabel *gameEnd = [[UILabel alloc]init];
    gameEnd.textColor = [UIColor whiteColor];
    gameEnd.font = [UIFont systemFontOfSize:70];
    gameEnd.textAlignment = NSTextAlignmentCenter;
    gameEnd.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height/2-100,[UIScreen mainScreen].bounds.size.width,100);
    gameEnd.alpha = 0;
    
    [self.view addSubview:gameEnd];
    _gameEnd = gameEnd;
    
    UILabel *endMessage = [[UILabel alloc]init];
    endMessage.textColor = [UIColor whiteColor];
    endMessage.font = [UIFont systemFontOfSize:40];
    endMessage.textAlignment = NSTextAlignmentCenter;
    endMessage.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height/2,[UIScreen mainScreen].bounds.size.width,100);
    endMessage.alpha = 0;
    
    [self.view addSubview:endMessage];
    _endMessage = endMessage;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // ゲーム画面描画
    [self myInit];
    [self drawLabel];
    
    // メインループ突入
    _mainTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(mainLoop:) userInfo:nil repeats:YES];
}

-(void)refreshDisplay
{
    // 移動後のフレーム情報に書き換え
    _ball.frame = _ballFrame;
    _playerBar.frame = _playerBarFrame;
    _enemyBar.frame = _enemyBarFrame;
}

#pragma mark - メインループ(タイマー)
-(void)mainLoop:(NSTimer *)timer{
    // タイトル画面から来たばかりか、得点が入った直後ならスコア表示
    if(_gameMode == 0 || _gameMode == 2){
        // 敵とボールのタイマー動いてれば停止
        if([_barTimer isValid] || [_ballTimer isValid]){
            [_barTimer invalidate];
            [_ballTimer invalidate];
        }
        
        // ちょっとずつ薄くして消す
        _playerScoreLabel.alpha = _labelAlpha;
        _enemyScoreLabel.alpha = _labelAlpha;
        
        // 薄くするタイマー開始
        if(_labelAlpha == 1 && ![_labelTimer isValid]){
            _labelTimer = [NSTimer scheduledTimerWithTimeInterval:1/40.0 target:self selector:@selector(onTickScoreLabel:)userInfo:nil repeats:YES];
        }
        
        // 透明になったらタイマー停止
        if(_labelAlpha < 0){
            // ゲーム中のフラグ立ててゲーム開始させる
            _gameMode = 1;
            _labelAlpha = 0;
            [_labelTimer invalidate];
            _labelTimer = nil;
        }
    // ゲーム中のルーチン
    }else if(_gameMode == 1){
        distanceCount++;
        // 大体5秒毎にお互いのバーの距離を縮める
        if(distanceCount > 500){
            // スリ抜け防止のため、ボールとバーの距離が100以上だったら距離を縮める
            if(_playerBarFrame.origin.y - _ballFrame.origin.y > 100 && _ballFrame.origin.y - _enemyBarFrame.origin.y > 100){
                AudioServicesPlaySystemSound(_soundShrink);
                _playerBarFrame.origin.y = _playerBarFrame.origin.y - 20;
                _enemyBarFrame.origin.y = _enemyBarFrame.origin.y + 20;
                distanceCount = 0;
            }else{
                // ボールとバーの距離が近い場合カウント2.5秒目に戻す
                distanceCount = 250;
            }
        }
        
        // 敵のバーとボールのタイマーを開始して動かす
        if(![_barTimer isValid] && ![_ballTimer isValid]){
            _barTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(onTickBar:) userInfo:nil repeats:YES];
            _ballTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(onTickBall:) userInfo:nil repeats:YES];
        }
        
        // ゲーム画面描画
        [self refreshDisplay];
        
    // どちらかが5点先取したらゲーム終了
    }else if(_gameMode == 3){
        AudioServicesPlaySystemSound(_soundEnd);
        // 敵のバーとボールのタイマーを止めましょう
        if([_barTimer isValid] || [_ballTimer isValid]){
            [_barTimer invalidate];
            [_ballTimer invalidate];
        }
        
        // スコア表示します
        _playerScoreLabel.alpha = _labelAlpha;
        _enemyScoreLabel.alpha = _labelAlpha;
        
        // メッセージ注入中
        if(_playerScore > _enemyScore){
            _gameEnd.text = @"YOU WIN";
        }else{
            _gameEnd.text = @"YOU LOSE";
        }
        _gameEnd.alpha = 1;
        
        int remainder = _playerScore - _enemyScore;
        
        switch(remainder){
            case -5:
                _endMessage.text = @"超弱い！";
                break;
            case -4:
                _endMessage.text = @"割と弱い！";
                break;
            case -3:
                _endMessage.text = @"弱い！";
                break;
            case -2:
                _endMessage.text = @"惜しい！";
                break;
            case -1:
                _endMessage.text = @"接戦！";
                break;
            case 1:
                _endMessage.text = @"あわや！";
                break;
            case 2:
                _endMessage.text = @"やった！";
                break;
            case 3:
                _endMessage.text = @"強い！";
                break;
            case 4:
                _endMessage.text = @"すごい！";
                break;
            case 5:
                _endMessage.text = @"鬼か！";
                break;
        }
        _endMessage.alpha = 1;

        // メッセージ揺らします
        if(![_vibrationTimer isValid]){
            _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1/100.0 target:self selector:@selector(onTickVibration:) userInfo:nil repeats:YES];
        }
        
        // メインループのタイマー停止
        if([_mainTimer isValid]){
            [_mainTimer invalidate];
        }
    }
}

#pragma mark - タイマー
// ラベルを少しずつ薄くする
-(void)onTickScoreLabel:(NSTimer *)timer
{
    _labelAlpha = _labelAlpha - 0.03;
}

// ボール移動
-(void)onTickBall:(NSTimer *)timer
{
    // 移動量計算
    [_ball moveWithMoveX:_ball.moveX moveY:_ball.moveY];
    // 計算結果をフレームに代入
    _ballFrame = _ball.frame;
    
    // プレイヤーが点を入れた
    if(_ballFrame.origin.y < 0){
        _playerScore++;
        _playerScoreLabel.text = [NSString stringWithFormat:@"%d",_playerScore];
        [self nextTurnInit];
    // 敵が点を入れた
    }else if(_ballFrame.origin.y + _appDelegate.ballSize > [UIScreen mainScreen].bounds.size.height){
        _enemyScore++;
        _enemyScoreLabel.text = [NSString stringWithFormat:@"%d",_enemyScore];
        [self nextTurnInit];
    };
    
    // どちらかが5点先取したら終了フラグ立てます
    if(_playerScore == 5 || _enemyScore == 5)
    {
        _gameMode = 3;
    }
    
    if(_gameMode == 1){
        
        [self hitJudge];
        
        // 壁にぶつかったら反転する処理
        if(_ballFrame.origin.x < 0){
            // 反射音
            AudioServicesPlaySystemSound(_soundBounce);
            _ballFrame.origin.x = 0;
            _ball.moveX = 1;
        };
        
        if(_ballFrame.origin.x + _appDelegate.ballSize > [UIScreen mainScreen].bounds.size.width){
            // ぽよ音
            AudioServicesPlaySystemSound(_soundBounce);
            _ballFrame.origin.x = [UIScreen mainScreen].bounds.size.width - _appDelegate.ballSize;
            _ball.moveX = -1;
        };
        
        // 当たり判定
        [self hitJudge];
    }
}

// 敵のバー移動
-(void)onTickBar:(NSTimer *)timer
{
    float distanceX = (_ballFrame.origin.x + _appDelegate.ballSize / 2) - (_enemyBarFrame.origin.x + _appDelegate.enemyBarLength / 2);
    if(_ball.moveY == -1 && _ballFrame.origin.y + _appDelegate.ballSize < [UIScreen mainScreen].bounds.size.height * 2 / 3){
        if(distanceX > 0){
            _enemyWay = 1;
        }else{
            _enemyWay = -1;
        }
    }
    
    // 敵バーの移動
    [_enemyBar move:_enemyWay];
    _enemyBarFrame = _enemyBar.frame;
    
    // 画面の端っこ判断
    if(_enemyBarFrame.origin.x + _appDelegate.enemyBarLength > [UIScreen mainScreen].bounds.size.width){
        _enemyBarFrame.origin.x = [UIScreen mainScreen].bounds.size.width - _appDelegate.enemyBarLength;
    }else if (_enemyBarFrame.origin.x < 0){
        _enemyBarFrame.origin.x = 0;
    }
    
    // 当たり判定
    [self hitJudge];
}

// ボール当たったら敵のバーを揺らす
-(void)onTickEnemyShake:(NSTimer *)timer
{
    // 一定時間揺らしたら止める
    if([_bombTimer isValid] && _shakeCount < 0){
        [_bombTimer invalidate];
        _bombTimer = nil;
        _appDelegate.enemyShakeY = 0;
    }
    
    _appDelegate.enemyShakeY = (float)arc4random_uniform(5)-1;
    _shakeCount--;
}

// ボール当たったらプレイヤーのバー揺らす
-(void)onTickPlayerShake:(NSTimer *)timer
{
    if([_bombTimer isValid] && _shakeCount < 0){
        [_bombTimer invalidate];
        _bombTimer = nil;
        _appDelegate.playerShakeY = 0;
    }
    
    _appDelegate.playerShakeY = (float)arc4random_uniform(5)-1;
    _shakeCount--;
}

// 文字を揺らす
-(void)onTickVibration:(NSTimer *)timer
{
    _x = arc4random_uniform(3)-1;
    _y = arc4random_uniform(3)-1;
    
    _endMessage.frame = CGRectMake(0+_x,[UIScreen mainScreen].bounds.size.height/2+_y,[UIScreen mainScreen].bounds.size.width,100);
    
    _x = arc4random_uniform(3)-1;
    _y = arc4random_uniform(3)-1;
    
    _gameEnd.frame = CGRectMake(0+_x,[UIScreen mainScreen].bounds.size.height/2-100+_y,[UIScreen mainScreen].bounds.size.width,100);
}

-(void)hitJudge
{
    // ボールとバーのRect作成
    CGRect playerBarRect = CGRectMake(_playerBarFrame.origin.x,_playerBarFrame.origin.y,_playerBar.frame.size.width,_playerBar.frame.size.height);
    CGRect enemyBarRect = CGRectMake(_enemyBarFrame.origin.x,_enemyBarFrame.origin.y,_enemyBar.frame.size.width,_enemyBar.frame.size.height);
    CGRect ballRect = CGRectMake(_ballFrame.origin.x,_ballFrame.origin.y,_appDelegate.ballSize,_appDelegate.ballSize);
    
    // ボールとプレイヤーバーの当たり判定
    if(CGRectIntersectsRect(playerBarRect,ballRect)){
        
        // 反射音
        AudioServicesPlaySystemSound(_soundBounce);
        
        // 当たったエフェクトを出す為の初期化
        _shakeCount = 10;
        if(![_bombTimer isValid]){
            _bombTimer = [NSTimer scheduledTimerWithTimeInterval:1/50.0 target:self selector:@selector(onTickPlayerShake:) userInfo:nil repeats:YES];
        }
        
        // バーの左端
        if(_ballFrame.origin.x + _appDelegate.ballSize < _playerBarFrame.origin.x + 10 && _ballFrame.origin.y + _appDelegate.ballSize < _playerBarFrame.origin.y + 10){
            _ball.moveY *= -1;
            _ball.moveX *= -1;
            _ballFrame.origin.x = _playerBarFrame.origin.x - _appDelegate.ballSize - 2;
            _ballFrame.origin.y = _playerBarFrame.origin.y - _appDelegate.ballSize - 2;
            // バーの右端
        }else if(_ballFrame.origin.x > _playerBarFrame.origin.x + _appDelegate.playerBarLength - 10 &&  _ballFrame.origin.y + _appDelegate.ballSize < _playerBarFrame.origin.y + 10){
            _ball.moveY *= -1;
            _ball.moveX *= -1;
            _ballFrame.origin.x = _playerBarFrame.origin.x + _appDelegate.playerBarLength + 2;
            _ballFrame.origin.y = _playerBarFrame.origin.y - _appDelegate.ballSize - 2;
            // 上から
        }else if(_ballFrame.origin.y + _appDelegate.ballSize < _playerBarFrame.origin.y + 10){
            _ball.moveY *= -1;
            _ballFrame.origin.y = _playerBarFrame.origin.y - _appDelegate.ballSize - 2;
            // 左から
        }else if(_ballFrame.origin.x + _appDelegate.ballSize < _playerBarFrame.origin.x + 10){
            _ball.moveX *= -1;
            _ballFrame.origin.x = _playerBarFrame.origin.x - 10 - 2;
            // 右から
        }else if(_ballFrame.origin.x > _playerBarFrame.origin.x + _appDelegate.playerBarLength - 10){
            _ball.moveX *= -1;
            _ballFrame.origin.x = _playerBarFrame.origin.x + _appDelegate.playerBarLength + 10 + 2;
        }
        // ボールと敵バーの当たり判定
    }else if(CGRectIntersectsRect(enemyBarRect,ballRect)){
        
        // 反射音
        AudioServicesPlaySystemSound(_soundBounce);
        
        // 敵の動きを止める
        _enemyWay = 0;
        
        // 当たったエフェクトを出す為の初期化
        _shakeCount = 10;
        if(![_bombTimer isValid]){
            _bombTimer = [NSTimer scheduledTimerWithTimeInterval:1/50.0 target:self selector:@selector(onTickEnemyShake:) userInfo:nil repeats:YES];
        }
        
        // バーの左端
        if(_ballFrame.origin.x + _appDelegate.ballSize < _enemyBarFrame.origin.x + 10 && _ballFrame.origin.y > _enemyBarFrame.origin.y + _appDelegate.enemyBarLength - 10){
            _ball.moveY *= -1;
            _ball.moveX *= -1;
            _ballFrame.origin.x = _enemyBarFrame.origin.x - _appDelegate.ballSize - 2;
            _ballFrame.origin.y = _enemyBarFrame.origin.y + _enemyBar.frame.size.height + 2;
            // バーの右端
        }else if(_ballFrame.origin.x > _enemyBarFrame.origin.x + _appDelegate.enemyBarLength - 10 && _ballFrame.origin.y > _enemyBarFrame.origin.y + _appDelegate.enemyBarLength - 10){
            _ball.moveY *= -1;
            _ball.moveX *= -1;
            _ballFrame.origin.x = _enemyBarFrame.origin.x + _appDelegate.enemyBarLength + 2;
            _ballFrame.origin.y = _enemyBarFrame.origin.y + _enemyBar.frame.size.height + 2;
            // 下から
        }else if(_ballFrame.origin.y > _enemyBarFrame.origin.y + _enemyBar.frame.size.height - 10){
            _ball.moveY *= -1;
            _ballFrame.origin.y = _enemyBarFrame.origin.y + _enemyBar.frame.size.height + 2;
            // 左から
        }else if(_ballFrame.origin.x + _appDelegate.ballSize < _enemyBarFrame.origin.x + 10){
            _ball.moveX *= -1;
            _ballFrame.origin.x = _enemyBarFrame.origin.x - 10 - 2;
            // 右から
        }else if(_ballFrame.origin.x > _enemyBarFrame.origin.x + _appDelegate.enemyBarLength - 10){
            _ball.moveX *= -1;
            _ballFrame.origin.x = _enemyBarFrame.origin.x + _appDelegate.enemyBarLength + 10 + 2;
        }
    }
}
#pragma mark - タッチメソッド
// ゲーム終了時にタッチしたらタイトルに戻る
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_gameMode == 3){
        AudioServicesPlaySystemSound(_soundChangeScreen);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

// スワイプでプレイヤーのバー移動
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGPoint originalPoint = [touch previousLocationInView:self.view];
    
    int moveX = (originalPoint.x - point.x);
    _playerBarFrame.origin.x = _playerBarFrame.origin.x - moveX;
    
    // 画面の端っこ判断
    if(_playerBarFrame.origin.x + _appDelegate.playerBarLength > [UIScreen mainScreen].bounds.size.width){
        _playerBarFrame.origin.x = [UIScreen mainScreen].bounds.size.width - _appDelegate.playerBarLength;
    }else if (_playerBarFrame.origin.x < 0){
        _playerBarFrame.origin.x = 0;
    }
    
    // 当たり判定
    [self hitJudge];
}


@end
