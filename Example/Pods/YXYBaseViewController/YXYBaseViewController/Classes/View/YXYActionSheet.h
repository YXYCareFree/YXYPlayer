//
//  YXYActionSheet.h
//  AFNetworking
//
//  Created by apple on 2019/1/5.
//

#import <UIKit/UIKit.h>

@protocol YXYActionSheetDelegate <NSObject>

- (void)YXYActionSheetRegisterCell:(UITableView *)tableView;

- (UITableViewCell *)YXYActionSheetCellForRowAtIndexPath:(NSIndexPath *)indexPath tableView:(UITableView *)tableView;

@end

NS_ASSUME_NONNULL_BEGIN

@interface YXYActionSheet : UIView

@property (nonatomic, strong) UIButton *btnBottom;
@property (nonatomic, strong) UIFont *font;//选项lbl的font
@property (nonatomic, strong) UIColor *color;//选项lbl的Color

@property (nonatomic, weak) id <YXYActionSheetDelegate>delegate;



/**
 @param dataSource <#dataSource description#>
 @param heigh cell的高度，默认为46
 @param completion <#completion description#>
 @return <#return value description#>
 */
+ (instancetype)actionSheetWithDataSource:(NSArray *)dataSource rowHeigh:(CGFloat)heigh completion:(void(^)(NSInteger idx))completion;


/**
 自定义Cell的实例化方法
 @param dataSource <#dataSource description#>
 @param delegate <#delegate description#>
 @param heigh cell的高度，默认46
 @param completion <#completion description#>
 @return <#return value description#>
 */
+ (instancetype)actionSheetWithDataSource:(NSArray *)dataSource delegate:(id)delegate rowHeigh:(CGFloat)heigh completion:(void (^)(NSInteger))completion;


@end


@interface YXYActionSheetCell : UITableViewCell

@property (nonatomic, strong) UILabel *lblTitle;

@end
NS_ASSUME_NONNULL_END
