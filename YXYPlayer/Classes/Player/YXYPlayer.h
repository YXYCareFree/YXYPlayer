//
//  YXYPlayer.h
//  CasanubeHealth
//
//  Created by 杨肖宇 on 2019/6/19.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YXYLoadingLabel.h"

typedef enum : NSUInteger {
    PlayerPanGestureDirectionH,
    PlayerPanGestureDirectionV,
} PlayerPanGestureDirection;

typedef enum : NSUInteger {
    YXYPlayerStatusPause,
    YXYPlayerStatusPlay,
    YXYPlayerStatusBuffering,//缓冲中
    YXYPlayerStatusBufferEnd,//缓冲结束
    YXYPlayerStatusPlayEnd,//播放结束
} YXYPlayerStatus;

@class YXYPlayer;

@protocol YXYPlayerControlDelegate <NSObject>

@required
@property (nonatomic, weak) YXYPlayer *player;

@optional

/**
 player当前的status
 @param status player当前的status
 */
- (void)playerStatus:(YXYPlayerStatus)status;

/**
 player的播放进度
 @param progress  player的播放进度
 */
- (void)playerPlayProgress:(CGFloat)progress;

/**
 player当前缓冲的总进度（秒）
 @param buffer  player当前缓冲的总进度（秒）
 */
- (void)playerBuffer:(CGFloat)buffer;

/**
水平滑动的距离
 @param x 水平滑动的距离
 */
- (void)panGestureDirectionH:(CGFloat)x;

/**
 playerView发生了触摸事件：此时可以展示控制层
 */
- (void)playerTouched;

@end


NS_ASSUME_NONNULL_BEGIN

@interface YXYPlayer : UIView


+ (instancetype)playerWithContentView:(UIView *)contentView videoUrl:(NSURL *)url;

+ (instancetype)playerWithContentView:(UIView *)contentView control:(id<YXYPlayerControlDelegate>)control videoUrl:(NSURL *)url;


/**
 播放视频的View, 可在此view上添加控制层
 */
@property (nonatomic, weak) UIView *contentView;

/**
 控制层
 */
@property (nonatomic, strong) id<YXYPlayerControlDelegate> control;

@property (nonatomic, strong) YXYLoadingLabel *lblLoading;

@property (nonatomic, assign) BOOL playing;

/**
 视频总时长(秒)s
 */
@property (nonatomic, assign) CGFloat totalTime;

@property (nonatomic, assign) PlayerPanGestureDirection panGestureDirection;


/**
 水平方向移动了多少距离
 */
@property (nonatomic, copy) void(^PanGestureDirectionHBlock)(CGFloat x);

@property (nonatomic, copy) void(^YXYPlayerStatusBlock)(YXYPlayerStatus status);

/**
 播放进度
 */
@property (nonatomic, copy) void(^ProgressBlock)(CGFloat progress);

/**
 缓冲进度 总缓冲时长
 */
@property (nonatomic, copy) void(^BufferBlock)(CGFloat buffer);

/**
 触摸播放视图时回调 此时可以展示controlView
 */
@property (nonatomic, copy) void(^TouchesBlock)(void);



- (void)pause;

- (void)play;

- (void)seekToTime:(NSInteger)time;

@end

NS_ASSUME_NONNULL_END
