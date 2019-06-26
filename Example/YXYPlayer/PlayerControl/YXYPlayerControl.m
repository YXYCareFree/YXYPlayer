//
//  YXYPlayerControl.m
//  CasanubeMember
//
//  Created by 杨肖宇 on 2019/6/19.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import "YXYPlayerControl.h"
#import "ZFSliderView.h"
#import "YXYLabel.h"
#import "YXYButton.h"
#import "Masonry.h"

#define KWeakSelf __weak typeof(self) weakSelf =self
#define LoadImageWithName(x)   [UIImage imageNamed:x]
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define Font_PingFang_Bold(x) [UIFont fontWithName:@"PingFangSC-Semibold" size:x]
#define Font_PingFang_Medium(x) [UIFont fontWithName:@"PingFangSC-Medium" size:x]
#define Font_PingFang_Regular(x) [UIFont fontWithName:@"PingFangSC-Regular" size:x]
#define ColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface YXYPlayerControl ()<ZFSliderViewDelegate>

@property (nonatomic, strong) UIView *vTop;
@property (nonatomic, strong) YXYLabel *lblTitle;
@property (nonatomic, strong) YXYLabel *lblLookNum;

@property (nonatomic, strong) UIView *vFunc;
@property (nonatomic, strong) YXYButton *lblFavourNum;

@property (nonatomic, strong) UIView *vBottom;
@property (nonatomic, strong) UIButton *btnPlay;
@property (nonatomic, strong) YXYLabel *lblTotalTime;
@property (nonatomic, strong) ZFSliderView *vProgress;

@property (nonatomic, strong) dispatch_block_t hideControlViewBlock;

@property (nonatomic, strong) YXYButton *btnReplay;
@property (nonatomic, strong) YXYLabel *lblReplay;

@end

@implementation YXYPlayerControl

@synthesize player = _player;

-(void)dealloc{
    NSLog(@"dealloc");
}

+ (instancetype)initWithContentModel:(YXYPlayerModel *)model{
    YXYPlayerControl *control = YXYPlayerControl.new;
    control.model = model;
    return control;
}

- (void)setPlayer:(YXYPlayer *)player{
    _player = player;
    [self setUI];
}

- (void)setUI{    
    [self.player.contentView addSubview:self.vTop];
    [self.player.contentView addSubview:self.vFunc];
    [self.player.contentView addSubview:self.vBottom];
    [self.vTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(@0);
        make.height.equalTo(@53);
    }];
    [self.vFunc mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@(-13));
        make.centerY.equalTo(@0);
    }];
    [self.vBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(@0);
        make.height.equalTo(@44);
    }];
    [self autoHideControlView];
    
    KWeakSelf;
    self.player.ProgressBlock = ^(CGFloat progress) {
        if (weakSelf.vProgress.value == 0) {
            weakSelf.lblTotalTime.title([weakSelf getTotalTime]);
        }
        weakSelf.vProgress.value = progress;
        if (progress >= 1.0) {
            [weakSelf showReplayView];
            [weakSelf pause];
        }
    };
    
    self.player.TouchesBlock = ^{
        [weakSelf showControlView];
    };
    
    self.player.YXYPlayerStatusBlock = ^(YXYPlayerStatus status) {
        if (status == YXYPlayerStatusPause || status == YXYPlayerStatusBuffering || status == YXYPlayerStatusPlayEnd) {
            [weakSelf.btnPlay setImage:LoadImageWithName(@"video_pause") forState:UIControlStateNormal];
            [weakSelf.btnReplay removeFromSuperview];
            [weakSelf.lblReplay removeFromSuperview];
            if (status == YXYPlayerStatusPlayEnd) {
                [weakSelf showReplayView];
            }
        }
        if (status == YXYPlayerStatusPlay) {
            [weakSelf.btnPlay setImage:LoadImageWithName(@"video_play") forState:UIControlStateNormal];
        }
    };
}

- (void)showReplayView{
    [self.player.contentView addSubview:self.btnReplay];
    [self.player.contentView addSubview:self.lblReplay];
    [self.btnReplay mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
    }];
    [self.lblReplay mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(@0);
        make.top.equalTo(self.btnReplay.mas_bottom).offset(3);
    }];
}

- (void)popViewController{
    if ([self getCurrentViewController].presentingViewController) {
        [[self getCurrentViewController] dismissViewControllerAnimated:YES completion:nil];
    }else
    [[self getCurrentViewController].navigationController popViewControllerAnimated:YES];
}

- (void)btnCollectClicked{
    NSLog(@"点击了收藏");
    [self showControlView];
}

- (void)btnFavourClicked{
    NSLog(@"点击了喜欢");
    [self showControlView];
}

- (void)btnPlayClicked{
    [self showControlView];
    if (self.player.playing) {
        [self pause];
    }else{
        [self play];
    }
}

- (void)pause{
    [self.player pause];
    [self.btnPlay setImage:LoadImageWithName(@"video_pause") forState:UIControlStateNormal];
}

- (void)play{
    [self.player play];
    [self.btnPlay setImage:LoadImageWithName(@"video_play") forState:UIControlStateNormal];
}

- (void)btnReplayClicked{
    [self.player seekToTime:0];
    [self.btnReplay removeFromSuperview];
    [self.lblReplay removeFromSuperview];
    [self.btnPlay setImage:LoadImageWithName(@"video_play") forState:UIControlStateNormal];
}

- (void)showControlView{
    [self cancelHideControlViewBlock];

    [UIView animateWithDuration:.25 animations:^{
        [self.player.contentView setNeedsLayout];
        [self.vTop mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kScreenWidth));
            make.height.equalTo(@(53));
            make.top.equalTo(self.player.contentView.mas_top).offset(0);
        }];
        [self.vBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kScreenWidth));
            make.height.equalTo(@(44));
            make.bottom.equalTo(self.player.contentView.mas_bottom).offset(0);
        }];
        [self.vFunc mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.player.contentView.mas_right).offset(0);
            make.centerY.equalTo(self.player.contentView);
        }];
        [self.player.contentView layoutIfNeeded];
    }];
    [self autoHideControlView];
}

- (void)autoHideControlView{
    [self cancelHideControlViewBlock];
    KWeakSelf;
    self.hideControlViewBlock = dispatch_block_create(0, ^{
        [weakSelf hideControlView];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.hideControlViewBlock);
}

- (void)cancelHideControlViewBlock{
    if (self.hideControlViewBlock) {
        dispatch_block_cancel(self.hideControlViewBlock);
        self.hideControlViewBlock = nil;
    }
}

- (void)hideControlView{
    [UIView animateWithDuration:.25 animations:^{
        [self.player.contentView setNeedsLayout];
        [self.vTop mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kScreenWidth));
            make.height.equalTo(@(53));
            make.bottom.equalTo(self.player.contentView.mas_top).offset(0);
        }];
        [self.vBottom mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(kScreenWidth));
            make.height.equalTo(@(44));
            make.top.equalTo(self.player.contentView.mas_bottom).offset(0);
        }];
        [self.vFunc mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.player.contentView.mas_right).offset(0);
            make.centerY.equalTo(self.player.contentView);
        }];
        [self.player.contentView layoutIfNeeded];
    }];
}

#pragma mark--ZFSliderViewDelegate
- (void)sliderTouchBegan:(float)value{
    NSLog(@"开始滑动=%f", value);
    [self.player pause];
}

- (void)sliderValueChanged:(float)value{
    NSLog(@"滑动change=%f", value);

    [self showControlView];
}
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value{
    NSLog(@"滑动结束%f", value);
    [self.player seekToTime:value * self.player.totalTime];
}
// 滑杆点击
- (void)sliderTapped:(float)value{
    [self showControlView];
}

- (NSString *)getTotalTime{
    NSInteger min = self.player.totalTime / 60;
    NSInteger sec = (NSInteger)self.player.totalTime % 60;
    NSString *m = @"00";
    NSString *s = @"00";
    if (min >= 10) {
        m = [NSString stringWithFormat:@"%ld", min];
    }else m = [NSString stringWithFormat:@"0%ld", min];
    if (sec >= 10) {
        s = [NSString stringWithFormat:@"%ld", sec];
    }else s = [NSString stringWithFormat:@"0%ld", sec];

    return [NSString stringWithFormat:@"%@:%@", m, s];
}
#pragma mark--Getter
- (UIView *)vTop{
    if (!_vTop) {
        _vTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 53)];
        _vTop.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        UIButton *btnBack = [[UIButton alloc] init];
        btnBack.adjustsImageWhenHighlighted = NO;
        [btnBack setImage:LoadImageWithName(@"back") forState:UIControlStateNormal];
        [btnBack addTarget:self action:@selector(popViewController) forControlEvents:UIControlEventTouchUpInside];
        [_vTop addSubview:btnBack];
        [btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@(20));
            make.width.height.equalTo(@33);
        }];
        
        self.lblTitle = [YXYLabel new];
        self.lblTitle.titleFont(Font_PingFang_Medium(16)).color(UIColor.whiteColor).title(self.model.title);
        [_vTop addSubview:self.lblTitle];
        [self.lblTitle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(btnBack.mas_right).offset(2);
            make.centerY.equalTo(btnBack);
        }];
        
        self.lblLookNum = YXYLabel.new;
        self.lblLookNum.titleFont(Font_PingFang_Regular(14)).color(UIColor.whiteColor).title(self.model.browseNumber);
        [_vTop addSubview:self.lblLookNum];
        [self.lblLookNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-15));
            make.centerY.equalTo(btnBack);
        }];
        
        UIImageView *imgV = [[UIImageView alloc] initWithImage:LoadImageWithName(@"content_look")];
        imgV.tintColor = UIColor.whiteColor;
        imgV.image = [imgV.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [_vTop addSubview:imgV];
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.lblLookNum.mas_left).offset(-3);
            make.centerY.equalTo(btnBack);
        }];
    }
    return _vTop;
}

- (UIView *)vFunc{
    if (!_vFunc) {
        _vFunc = [UIView new];
        _vFunc.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.5];
        _vFunc.layer.cornerRadius = 13;
        _vFunc.clipsToBounds = YES;
        UIButton *btnCollect = [[UIButton alloc] init];
        btnCollect.adjustsImageWhenHighlighted = NO;
        btnCollect.tintColor = UIColor.whiteColor;
        [btnCollect setImage:[LoadImageWithName(@"content_collect") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnCollect addTarget:self action:@selector(btnCollectClicked) forControlEvents:UIControlEventTouchUpInside];
        [_vFunc addSubview:btnCollect];
        [btnCollect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.vFunc);
            make.top.equalTo(@10);
        }];
        YXYButton *lblCollect = [YXYButton new];
        lblCollect.titleFont(Font_PingFang_Regular(12)).color(ColorFromHex(0xf2f2f2), UIControlStateNormal).title(@"收藏", UIControlStateNormal);
        [lblCollect addTarget:self action:@selector(btnCollectClicked) forControlEvents:UIControlEventTouchUpInside];
        [_vFunc addSubview:lblCollect];
        [lblCollect mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btnCollect.mas_bottom).offset(0);
            make.centerX.equalTo(btnCollect);
        }];
        
        UIView *vSplit = UIView.new;
        vSplit.backgroundColor = UIColor.whiteColor;
        [_vFunc addSubview:vSplit];
        [vSplit mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(lblCollect.mas_bottom).offset(3);
            make.width.equalTo(@35);
            make.left.equalTo(@10);
            make.right.equalTo(@(-10));
            make.height.equalTo(@1);
        }];
        
        UIButton *btnFavour = [[UIButton alloc] init];
        btnFavour.tintColor = UIColor.whiteColor;
        btnFavour.adjustsImageWhenHighlighted = NO;
        [btnFavour setImage:[LoadImageWithName(@"content_favour") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnFavour addTarget:self action:@selector(btnFavourClicked) forControlEvents:UIControlEventTouchUpInside];
        [_vFunc addSubview:btnFavour];
        [btnFavour mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.vFunc);
            make.top.equalTo(vSplit.mas_bottom).offset(3);
        }];
        self.lblFavourNum = [YXYButton new];
        [self.lblFavourNum.titleFont(Font_PingFang_Regular(12)).color(ColorFromHex(0xf2f2f2), UIControlStateNormal).title(self.model.likeNum, UIControlStateNormal) addTarget:self action:@selector(btnFavourClicked) forControlEvents:UIControlEventTouchUpInside];
        [_vFunc addSubview:self.lblFavourNum];
        [self.lblFavourNum mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(btnFavour.mas_bottom).offset(0);
            make.centerX.equalTo(btnFavour);
            make.bottom.equalTo(@(-5));
        }];
    }
    return _vFunc;
}

- (UIView *)vBottom{
    if (!_vBottom) {
        _vBottom = [UIView.alloc initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
        _vBottom.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.2];
        self.btnPlay = [[UIButton alloc] init];
        [self.btnPlay setImage:LoadImageWithName(@"video_play") forState:UIControlStateNormal];
        [self.btnPlay addTarget:self action:@selector(btnPlayClicked) forControlEvents:UIControlEventTouchUpInside];
        [_vBottom addSubview:self.btnPlay];
        [self.btnPlay mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.vBottom);
            make.left.equalTo(@0);
            make.width.equalTo(@60);
            make.height.equalTo(@44);
        }];
        
        self.lblTotalTime = YXYLabel.new;
        self.lblTotalTime.titleFont(Font_PingFang_Regular(14)).color(ColorFromHex(0xdddddd)).title([self getTotalTime]);
        [_vBottom addSubview:self.lblTotalTime];
        [self.lblTotalTime mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-15));
            make.centerY.equalTo(self.vBottom);
        }];
        
        self.vProgress = [[ZFSliderView alloc] initWithFrame:CGRectMake(0, 0, 90, 4)];
        self.vProgress.minimumTrackTintColor = ColorFromHex(0xdddddd);
        self.vProgress.maximumTrackTintColor = ColorFromHex(0x999999);
        self.vProgress.delegate = self;
        self.vProgress.clipsToBounds = YES;
        self.vProgress.layer.cornerRadius = 2;
        [self.vBottom addSubview:self.vProgress];
        [self.vProgress mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.btnPlay.mas_right).offset(10);
            make.right.equalTo(self.lblTotalTime.mas_left).offset(-26);
            make.centerY.equalTo(@0);
            make.top.bottom.equalTo(@0);
        }];
    }
    return _vBottom;
}

- (YXYButton *)btnReplay{
    if (!_btnReplay) {
        _btnReplay = [YXYButton new];
        [_btnReplay setImage:LoadImageWithName(@"play") forState:UIControlStateNormal];
        [_btnReplay addTarget:self action:@selector(btnReplayClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnReplay;
}

- (YXYLabel *)lblReplay{
    if (!_lblReplay) {
        _lblReplay = YXYLabel.new;
        _lblReplay.title(@"重新播放").titleFont(Font_PingFang_Regular(14)).color(ColorFromHex(0xf2f2f2));
    }
    return _lblReplay;
}


//适用范围，tabbar的子视图都是NavigationController，其它情况可以根据情况调整
- (UIViewController *)getCurrentViewController{
    
    UIViewController * result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    //app的windowLevel是UIWindowLevelNormal，如果不是，找到是UIWindowLevelNormal的Window
    if (window.windowLevel != UIWindowLevelNormal) {
        
        NSArray * windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tempWindow in windows) {
            
            if (tempWindow.windowLevel == UIWindowLevelNormal) {
                window = tempWindow;
                break;
            }
        }
    }
    id nextResponder = nil;
    UIViewController * appRootVC = window.rootViewController;
    //如果是present上来的vc，则appRootVC.presentedViewController不为nil
    if (appRootVC.presentedViewController) {
        nextResponder = appRootVC.presentedViewController;
    }else{
        
        UIView * frontView = [[window subviews] objectAtIndex:0];
        nextResponder = [frontView nextResponder];
    }
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]) {
        
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        UINavigationController * nav = (UINavigationController *)tabbar.selectedViewController;
        result = nav.childViewControllers.lastObject;
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        
        UIViewController * nav = (UIViewController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else{
        result = nextResponder;
    }
    
    return result;
}

@end
