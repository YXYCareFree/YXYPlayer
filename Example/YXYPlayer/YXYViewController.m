//
//  YXYViewController.m
//  YXYPlayer
//
//  Created by YXYCareFree on 06/26/2019.
//  Copyright (c) 2019 YXYCareFree. All rights reserved.
//

#import "YXYViewController.h"
#import "YXYPlayer.h"
#import "YXYPlayerControl.h"

@interface YXYViewController ()


@end

@implementation YXYViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    YXYPlayerModel *model = YXYPlayerModel.new;
    model.title = @"我是标题";
    model.likeNum = @"100";
    model.browseNumber = @"124";
    YXYPlayer *player = [YXYPlayer playerWithContentView:self.view control:[YXYPlayerControl initWithContentModel:model] videoUrl:[NSURL URLWithString:@"https://www.apple.com/105/media/cn/mac/family/2018/46c4b917_abfd_45a3_9b51_4e3054191797/films/bruce/mac-bruce-tpl-cn-2018_1280x720h.mp4"]];
    [player play];
}




@end
