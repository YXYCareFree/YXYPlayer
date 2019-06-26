//
//  YXYPlayerControl.h
//  CasanubeMember
//
//  Created by 杨肖宇 on 2019/6/19.
//  Copyright © 2019年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXYPlayer.h"
#import "YXYPlayerModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YXYPlayerControl : NSObject<YXYPlayerControlDelegate>

+ (instancetype)initWithContentModel:(YXYPlayerModel *)model;

@property (nonatomic, strong) YXYPlayerModel *model;

- (void)hideControlView;

@end

NS_ASSUME_NONNULL_END
