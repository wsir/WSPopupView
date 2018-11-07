//
//  WSPopupView.h
//
//  Created by wangsai on 2018/11/7.
//  Copyright © 2018年 WS. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WSPopupShowType) {
    WSPopupShowTypeNone = 0,
    WSPopupShowTypeSlideFromTop,
    WSPopupShowTypeSlideFromLeft,
    WSPopupShowTypeSlideFromBottom,
    WSPopupShowTypeSlideFromRight,
    WSPopupShowTypeSlideFromCenterTop,
    WSPopupShowTypeSlideFromCenterLeft,
    WSPopupShowTypeSlideFromCenterBottom,
    WSPopupShowTypeSlideFromCenterRight,
    WSPopupShowTypeBounceIn,
    WSPopupShowTypeFadeIn,                     //default
};

typedef NS_ENUM(NSInteger, WSPopupHiddenType) {
    WSPopupHiddenTypeNone = 0,
    WSPopupHiddenTypeSlideToTop,
    WSPopupHiddenTypeSlideToLeft,
    WSPopupHiddenTypeSlideToBottom,
    WSPopupHiddenTypeSlideToRight,
    WSPopupHiddenTypeSlideToCenterTop,
    WSPopupHiddenTypeSlideToCenterLeft,
    WSPopupHiddenTypeSlideToCenterBottom,
    WSPopupHiddenTypeSlideToCenterRight,
    WSPopupHiddenTypeBounceOut,
    WSPopupHiddenTypeFadeOut,                  //default
};

typedef NS_ENUM(NSInteger, WSPopupContentPosition) {
    WSPopupContentPositionCustom = 0,
    WSPopupContentPositionTop,
    WSPopupContentPositionLeft,
    WSPopupContentPositionBottom,
    WSPopupContentPositionRight,
    WSPopupContentPositionCenter,              //default
    WSPopupContentPositionCenterTop,
    WSPopupContentPositionCenterLeft,
    WSPopupContentPositionCenterBottom,
    WSPopupContentPositionCenterRight,
};

@interface WSPopupView : UIView

///显示的内容
@property (nonatomic, strong) UIView *contentView;

///显示的动画 Defaults to WSPopupShowTypeFadeIn
@property (nonatomic, assign) WSPopupShowType showType;

///隐藏的动画 Defaults to WSPopupHiddenTypeFadeOut
@property (nonatomic, assign) WSPopupHiddenType hiddenType;

///显示位置 Defaults to WSPopupContentPositionCenter
@property (nonatomic, assign) WSPopupContentPosition contentPosition;

///动画时间 Defaults to 0.2f
@property (nonatomic, assign) NSTimeInterval duration;

///是否背景点击hidden Defaults to YES
@property (nonatomic, assign) BOOL hiddenOnBackgroundTouch;

///是否内容视图点击hidden Defaults to NO
@property (nonatomic, assign) BOOL hiddenOnContentTouch;

///背景色透明度 Defaults to 0.5f
@property (nonatomic, assign) CGFloat backgroundAlpfa;

///是否显示中（包括动画中）
@property (nonatomic, assign, readonly) BOOL showing;

///显示之后延时自动消失，0为不自动消失 Defaults to 0
@property (nonatomic, assign) CGFloat hiddenAfterDelayDuration;

///宽度与父视图的比例
@property (nonatomic, assign) CGFloat contentWidthMultiplied;
///高度与父视图的比例
@property (nonatomic, assign) CGFloat contentHeightMultiplied;
///宽度的偏移量
@property (nonatomic, assign) CGFloat contentWidthOffset;
///高度的偏移量
@property (nonatomic, assign) CGFloat contentHeightOffset;
///popup偏移量
@property (nonatomic, assign) CGPoint popupOffset;

///隐藏完成之后的回调
@property (nonatomic, copy) void (^showCompletedBlock)(void);
@property (nonatomic, copy) void (^hiddenCompletedBlock)(void);

/**
 *  新建popup视图
 *
 *  @param contentView 显示的内容
 *  @param showType    显示动画
 *  @param hiddenType  隐藏动画
 */
+ (instancetype)popupViewWithContentView:(UIView *)contentView showType:(WSPopupShowType)showType hiddenType:(WSPopupHiddenType)hiddenType;

/**
 *  新建popup视图
 *
 *  @param contentView 显示的内
 */
+ (instancetype)popupViewWithContentView:(UIView *)contentView;

- (void)show;
- (void)showWithAnimated:(BOOL)animated;
- (void)showWithAnimated:(BOOL)animated completion:(void(^)(void))completion;
- (void)showInView:(UIView *)superView;
- (void)showInView:(UIView *)superView animated:(BOOL)animated;
- (void)showInView:(UIView *)superView animated:(BOOL)animated completion:(void(^)(void))completion;
- (void)hidden;
- (void)hiddenWithAnimated:(BOOL)animated;
- (void)hiddenWithAnimated:(BOOL)animated completion:(void(^)(void))completion;

@end
