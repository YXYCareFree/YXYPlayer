//
//  YXYPlayer.m
//  CasanubeMember
//
//  Created by 杨肖宇 on 2019/6/19.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import "YXYPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "Masonry.h"

#define KWeakSelf __weak typeof(self) weakSelf =self


#define NowTime \
({\
NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
[dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];\
([dateFormatter stringFromDate:[NSDate date]]);\
})\

#define NSLog(format, ...) do {                                           \
fprintf(stderr,"[%s] <%s:%d> %s\t%s\n\n", [NowTime UTF8String], [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, [[NSString stringWithFormat:format, ##__VA_ARGS__] UTF8String]);                                                       \
} while (0)

@interface YXYPlayer ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) NSURL *videoURL;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) id playerTimeObserver;
//当前播放时间
@property (nonatomic, assign) float currentPlayTime;

/**
 是否正在进行手势拖拽
 */
@property (nonatomic, assign) BOOL panGesturing;

@end

@implementation YXYPlayer

- (void)dealloc{
    NSLog(@"dealloc");
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [self.playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];

    if (@available(iOS 10.0, *)) {
        [self.player removeObserver:self forKeyPath:@"timeControlStatus"];
    }
    
    if (self.playerTimeObserver) {
        [self.player removeTimeObserver:self.playerTimeObserver];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!_playerLayer) {
        self.backgroundColor = UIColor.blackColor;
        [self.layer addSublayer:self.playerLayer];
    }else{
        self.playerLayer.frame = self.layer.frame;
    }
}

+ (instancetype)playerWithContentView:(UIView *)contentView control:(id<YXYPlayerControlDelegate>)control videoUrl:(NSURL *)url{
    YXYPlayer *player = YXYPlayer.new;
    player.videoURL = url;
    player.contentView = contentView;
    player.control = control;
    control.player = player;
    [player setUI];
    return player;
}

+ (instancetype)playerWithContentView:(UIView *)contentView videoUrl:(NSURL *)url{
    YXYPlayer *player = [[YXYPlayer alloc] init];
    player.videoURL = url;
    player.contentView = contentView;
    [player setUI];
    return player;
}

- (void)setUI{
    [self.contentView addSubview:self];
    [self.contentView sendSubviewToBack:self];
    [self.contentView addSubview:self.lblLoading];
    [self.lblLoading mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.width.height.equalTo(@60);
        [self.lblLoading layoutIfNeeded];
    }];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self addGuesture];
}

- (void)play{
    if (!self.playing) {
        NSLog(@"播放");
        self.playing = YES;
        [self.player play];
        if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
            [self.control playerStatus:YXYPlayerStatusPlay];
        }
        if (self.YXYPlayerStatusBlock) {
            self.YXYPlayerStatusBlock(YXYPlayerStatusPlay);
        }
    }
}

- (void)pause{
    if (self.playing) {
        NSLog(@"暂停");
        self.playing = NO;
        [self.player pause];
        if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
            [self.control playerStatus:YXYPlayerStatusPause];
        }
        if (self.YXYPlayerStatusBlock) {
            self.YXYPlayerStatusBlock(YXYPlayerStatusPause);
        }
    }
}

- (void)seekToTime:(NSInteger)time{
    [self.player seekToTime:CMTimeMake(time, 1)];
    [self play];
    if (time < self.totalTime) {
        if (self.YXYPlayerStatusBlock) {
            self.YXYPlayerStatusBlock(YXYPlayerStatusPlay);
        }
        if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
            [self.control playerStatus:YXYPlayerStatusPlay];
        }
    }
}

- (void)playDidEndNotification:(NSNotification *)noti{
    if (self.YXYPlayerStatusBlock) {
        self.YXYPlayerStatusBlock(YXYPlayerStatusPlayEnd);
    }
    if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
        [self.control playerStatus:YXYPlayerStatusPlayEnd];
    }
}
#pragma mark--手势
- (void)addGuesture{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizer:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
}

- (void)panGestureRecognizer:(UIPanGestureRecognizer *)pan{
    if (self.TouchesBlock) {
        self.TouchesBlock();
    }
    if (self.control && [self.control respondsToSelector:@selector(playerTouched)]) {
        [self.control playerTouched];
    }
    CGPoint translate = [pan translationInView:pan.view];
    CGPoint velocity = [pan velocityInView:pan.view];
//    NSLog(@"  translate=%@   velocity=%@", NSStringFromCGPoint(translate), NSStringFromCGPoint(velocity));
    if (fabs(translate.x) < 10) return;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            [self pause];
            if (fabs(velocity.x) > fabs(velocity.y)) {
                self.panGestureDirection = PlayerPanGestureDirectionH;
            }else{
                self.panGestureDirection = PlayerPanGestureDirectionV;
            }
        }break;
        case UIGestureRecognizerStateChanged:{
            [self pause];
            self.panGesturing = YES;
            NSInteger r = translate.x / 10;
            [self.player seekToTime:CMTimeMake(((r + self.currentPlayTime) > self.totalTime ? self.totalTime : (r + self.currentPlayTime)), 1)];
        }break;
        case UIGestureRecognizerStateEnded:{
            NSInteger r = translate.x / 10;
            float end = r + self.currentPlayTime;
            if (end < 0) {
                end = 0;
            }
            if (end > self.totalTime) {
                end = self.totalTime;
            }
//            NSLog(@"r=%ld, curr=%f, end=%f", r, self.currentPlayTime, end);
            self.panGesturing = NO;
            [self seekToTime:end];
        }break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.TouchesBlock) {
        self.TouchesBlock();
    }
    if (self.control && [self.control respondsToSelector:@selector(playerTouched)]) {
        [self.control playerTouched];
    }
}

#pragma mark--KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if (object == self.player) {
        if (@available(iOS 10.0, *)) {
            if (self.player.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
                self.playing = YES;
                NSLog(@"播放了");
                self.lblLoading.hidden = YES;
                if (self.YXYPlayerStatusBlock) {
                    self.YXYPlayerStatusBlock(YXYPlayerStatusPlay);
                }
                if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
                    [self.control playerStatus:YXYPlayerStatusPlay];
                }
            }else{
                self.playing = NO;
                if (self.YXYPlayerStatusBlock) {
                    self.YXYPlayerStatusBlock(YXYPlayerStatusPause);
                }
                if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
                    [self.control playerStatus:YXYPlayerStatusPause];
                }
            }
        }
    }
    if ([object isKindOfClass:self.playerItem.class]) {
        if ([keyPath isEqualToString:@"status"]) {
            switch (self.playerItem.status) {
                case AVPlayerItemStatusUnknown:
                    NSLog(@"加载失败");
                    break;
                case AVPlayerItemStatusReadyToPlay:
                { NSLog(@"即将播放");
                    self.totalTime = CMTimeGetSeconds(self.player.currentItem.duration);
                    KWeakSelf;
                    self.playerTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
//                        NSLog(@"curr=%f", CMTimeGetSeconds(time));
                        if (!weakSelf.panGesturing) {
                            weakSelf.currentPlayTime = CMTimeGetSeconds(time);
                        }
                        if (weakSelf.ProgressBlock) {
                            weakSelf.ProgressBlock(CMTimeGetSeconds(time) / CMTimeGetSeconds(weakSelf.player.currentItem.duration));
                        }
                        if (weakSelf.control && [weakSelf.control respondsToSelector:@selector(playerPlayProgress:)]) {
                            [weakSelf.control playerPlayProgress:CMTimeGetSeconds(time) / CMTimeGetSeconds(weakSelf.player.currentItem.duration)];
                        }
                    }];
                } break;
                case AVPlayerItemStatusFailed:
                    NSLog(@"加载失败");
                    break;
                default:
                    break;
            }
        }
        if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSArray * array = self.playerItem.loadedTimeRanges;
            CMTimeRange timeRange = [array.firstObject CMTimeRangeValue]; //本次缓冲的时间范围
            NSTimeInterval totalBuffer = CMTimeGetSeconds(timeRange.start) + CMTimeGetSeconds(timeRange.duration); //缓冲总长度
            if (self.BufferBlock) {
                self.BufferBlock(totalBuffer);
            }
            if (self.control && [self.control respondsToSelector:@selector(playerBuffer:)]) {
                [self.control playerBuffer:totalBuffer];
            }
//            NSLog(@"共缓冲%.2f",totalBuffer);
        }
        if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            self.lblLoading.hidden = NO;
            NSLog(@"正在缓冲");
            if (self.YXYPlayerStatusBlock) {
                self.YXYPlayerStatusBlock(YXYPlayerStatusBuffering);
            }
            if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
                [self.control playerStatus:YXYPlayerStatusBuffering];
            }
        }
        if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            if (change[NSKeyValueChangeNewKey] == 1) {
                self.lblLoading.hidden = YES;
                NSLog(@"缓冲完成");
                if (self.YXYPlayerStatusBlock) {
                    self.YXYPlayerStatusBlock(YXYPlayerStatusBufferEnd);
                }
                if (self.control && [self.control respondsToSelector:@selector(playerStatus:)]) {
                    [self.control playerStatus:YXYPlayerStatusBufferEnd];
                }
            }
        }
    }
}

#pragma mark-- Getter
- (AVPlayer *)player{
    if (!_player) {
        AVURLAsset *asset = [AVURLAsset assetWithURL:self.videoURL];
        AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
        self.playerItem = item;
        [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
//        监听缓冲进度
        [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
//        正在缓冲状态
        [self.playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
//        缓冲完成
        [self.playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];

        _player = [AVPlayer playerWithPlayerItem:item];
        if (@available(iOS 10.0, *)) {
            [_player addObserver:self forKeyPath:@"timeControlStatus" options:NSKeyValueObservingOptionNew context:nil];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playDidEndNotification:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return _player;
}

- (AVPlayerLayer *)playerLayer{
    if (!_playerLayer) {
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        _playerLayer.frame = self.bounds;
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    }
    return _playerLayer;
}

- (YXYLoadingLabel *)lblLoading{
    if (!_lblLoading) {
        _lblLoading = [[YXYLoadingLabel alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _lblLoading.lineColor = UIColor.whiteColor;
        _lblLoading.text = @"加载中...";
        _lblLoading.font = [UIFont systemFontOfSize:12];
        _lblLoading.textColor = UIColor.whiteColor;
    }
    return _lblLoading;
}
@end
