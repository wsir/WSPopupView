//
//  WSPopupView.m
//
//  Created by wangsai on 2018/11/7.
//  Copyright © 2018年 WS. All rights reserved.
//

#import "WSPopupView.h"

@interface WSPopupView ()

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, assign) CGRect contentOriginFrame;
@property (nonatomic, assign) CGRect contentBeginFrame;
@property (nonatomic, assign) CGRect contentShowFrame;
@property (nonatomic, assign) CGRect contentEndFrame;

@property (nonatomic, assign) BOOL startAnimated;

@property (nonatomic, assign) BOOL showing;

@property (nonatomic, assign) NSInteger showCount;

@end

@implementation WSPopupView

#pragma mark - life cycle
- (instancetype)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self _setup];
    }
    return self;
}

- (void)_setup
{
    [self _setupDefaultValues];
    [self _setupSubViews];
}

- (void)_setupDefaultValues
{
    self.showType = WSPopupShowTypeFadeIn;
    self.hiddenType = WSPopupHiddenTypeFadeOut;
    self.contentPosition = WSPopupContentPositionCenter;
    self.hiddenOnBackgroundTouch = YES;
    self.hiddenOnContentTouch = NO;
    self.duration = 0.2f;
    self.backgroundAlpfa = 0.5f;
    self.startAnimated = YES;
}

- (void)_setupSubViews
{
    self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.backgroundView];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *aTouch = [touches anyObject];
    CGPoint currentPoint = [aTouch locationInView:self];
    if (CGRectContainsPoint(self.backgroundView.frame, currentPoint) && !CGRectContainsPoint(self.contentView.frame, currentPoint)) {
        if (self.hiddenOnBackgroundTouch) {
            [self hiddenWithAnimated:self.startAnimated];
        }
    } else if (CGRectContainsPoint(self.contentView.frame, currentPoint)) {
        if (self.hiddenOnContentTouch) {
            [self hiddenWithAnimated:self.startAnimated];
        }
    }
}

#pragma mark - public methods
+ (instancetype)popupViewWithContentView:(UIView *)contentView
{
    WSPopupView *popupView = [[WSPopupView alloc] init];
    popupView.contentView = contentView;
    return popupView;
}

+ (instancetype)popupViewWithContentView:(UIView *)contentView showType:(WSPopupShowType)showType hiddenType:(WSPopupHiddenType)hiddenType
{
    WSPopupView *popupView = [[WSPopupView alloc] init];
    popupView.contentView = contentView;
    popupView.showType = showType;
    popupView.hiddenType = hiddenType;
    return popupView;
}

- (void)show
{
    [self showInView:nil];
}

- (void)showWithAnimated:(BOOL)animated
{
    [self showInView:nil animated:animated];
}

- (void)showWithAnimated:(BOOL)animated completion:(void (^)(void))completion
{
    [self showInView:nil animated:animated completion:completion];
}

- (void)showInView:(UIView *)superView
{
    [self showInView:superView animated:YES];
}

- (void)showInView:(UIView *)superView animated:(BOOL)animated
{
    [self showInView:superView animated:animated completion:NULL];
}

- (void)showInView:(UIView *)superView animated:(BOOL)animated completion:(void(^)(void))completion
{
    void(^animateCompletion)(BOOL finished) = ^(BOOL finished) {
        if (self.hiddenAfterDelayDuration > 0) {
            NSInteger currentShowCount = self.showCount;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.hiddenAfterDelayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.showCount == currentShowCount) {
                    [self hiddenWithAnimated:self.startAnimated];
                }
            });
        }
        if (self.showCompletedBlock) {
            self.showCompletedBlock();
        }
        if (completion) {
            completion();
        }
    };
    
    if (superView == nil) {
        superView = [UIApplication sharedApplication].keyWindow;
    }
    self.frame = CGRectOffset(superView.bounds, self.popupOffset.x, self.popupOffset.y);
    self.startAnimated = animated;
    self.showCount++;
    for (UIView *subView in superView.subviews) {
        if ([subView isKindOfClass:[self class]] && subView != self) {
            [(WSPopupView *)subView hiddenWithAnimated:NO completion:NULL];
        }
    }
    if (self.showing) {
        [self hiddenWithAnimated:self.startAnimated completion:^{
            [self showInView:superView animated:animated completion:completion];
        }];
        return;
    }
    self.showing = YES;
    [superView addSubview:self];
    NSTimeInterval duration = animated ? self.duration : 0.f;
    self.contentView.frame = self.contentBeginFrame;
    if (!animated || self.showType == WSPopupShowTypeNone) {
        self.contentView.frame = self.contentShowFrame;
        if (self.showCompletedBlock) {
            self.showCompletedBlock();
        }
        if (completion) {
            completion();
        }
        return;
    }
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
    
    switch (self.showType) {
        case WSPopupShowTypeBounceIn:
        {
            self.contentView.frame = self.contentShowFrame;
            self.contentView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
            self.contentView.alpha = 0.f;
            [UIView animateWithDuration:duration delay:0.f usingSpringWithDamping:0.8f initialSpringVelocity:15.f options:UIViewAnimationOptionCurveLinear animations:^{
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:self.backgroundAlpfa];
                self.contentView.transform = CGAffineTransformIdentity;
                self.contentView.alpha = 1.f;
            } completion:animateCompletion];
        }
            break;
        case WSPopupShowTypeFadeIn:
        {
            self.contentView.alpha = 0.f;
            [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:self.backgroundAlpfa];
                self.contentView.frame = self.contentShowFrame;
                self.contentView.alpha = 1.f;
            } completion:animateCompletion];
        }
            break;
        default:
        {
            [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:self.backgroundAlpfa];
                self.contentView.frame = self.contentShowFrame;
            } completion:animateCompletion];
        }
            break;
    }
}

- (void)hidden
{
    [self hiddenWithAnimated:YES];
}

- (void)hiddenWithAnimated:(BOOL)animated
{
    [self hiddenWithAnimated:animated completion:NULL];
}

- (void)hiddenWithAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    void(^animateCompletion)(BOOL finished) = ^(BOOL finished) {
        [self hiddenCompletion];
        if (completion) {
            completion();
        }
    };
    
    NSTimeInterval duration = animated ? self.duration : 0.f;
    self.contentView.frame = self.contentShowFrame;
    if (!animated || self.hiddenType == WSPopupHiddenTypeNone) {
        [self hiddenCompletion];
        if (completion) {
            completion();
        }
        return;
    }
    
    switch (self.hiddenType) {
        case WSPopupHiddenTypeBounceOut:
        {
            [UIView animateWithDuration:duration / 2 delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
                self.contentView.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:self.backgroundAlpfa / 2];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:duration / 2 delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
                    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
                    self.contentView.alpha = 0.f;
                    self.contentView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
                } completion:animateCompletion];
            }];
        }
            break;
        case WSPopupHiddenTypeFadeOut:
        {
            [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
                self.contentView.frame = self.contentEndFrame;
                self.contentView.alpha = 0.f;
            } completion:animateCompletion];
        }
            break;
        default:
        {
            [UIView animateWithDuration:duration delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.f];
                self.contentView.frame = self.contentEndFrame;
            } completion:animateCompletion];
        }
            break;
    }
}

#pragma mark - private methods
- (void)hiddenCompletion
{
    self.contentView.alpha = 1.f;
    self.contentView.transform = CGAffineTransformIdentity;
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:self.backgroundAlpfa];
    self.showing = NO;
    if (self.hiddenCompletedBlock) {
        self.hiddenCompletedBlock();
    }
    [self removeFromSuperview];
}

- (void)updateContentOriginFrame
{
    self.contentOriginFrame = CGRectMake(self.contentOriginFrame.origin.x, self.contentOriginFrame.origin.y, self.bounds.size.width * self.contentWidthMultiplied + self.contentWidthOffset, self.bounds.size.height * self.contentHeightMultiplied + self.contentHeightOffset);
}

#pragma mark - getter and setter
- (UIView *)backgroundView
{
    if (_backgroundView == nil) {
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _backgroundView;
}

- (void)setContentView:(UIView *)contentView
{
    if (_contentView) {
        [_contentView removeFromSuperview];
        _contentView = nil;
    }
    _contentView = contentView;
    self.contentOriginFrame = contentView.frame;
    [self addSubview:contentView];
}

- (void)setContentPosition:(WSPopupContentPosition)contentPosition
{
    _contentPosition = contentPosition;
    switch (contentPosition) {
        case WSPopupContentPositionCustom:
            self.contentShowFrame = self.contentOriginFrame;
            break;
        case WSPopupContentPositionCenter:
            self.contentShowFrame = CGRectMake(self.bounds.size.width / 2 - self.contentOriginFrame.size.width / 2, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionTop:
            self.contentShowFrame = CGRectMake(self.contentOriginFrame.origin.x, 0.f, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionLeft:
            self.contentShowFrame = CGRectMake(0.f, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionBottom:
            self.contentShowFrame = CGRectMake(self.contentOriginFrame.origin.x, self.bounds.size.height - self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionRight:
            self.contentShowFrame = CGRectMake(self.bounds.size.width - self.contentOriginFrame.size.width, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionCenterTop:
            self.contentShowFrame = CGRectMake(self.bounds.size.width / 2 - self.contentOriginFrame.size.width / 2, 0.f, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionCenterLeft:
            self.contentShowFrame = CGRectMake(0.f, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionCenterBottom:
            self.contentShowFrame = CGRectMake(self.bounds.size.width / 2 - self.contentOriginFrame.size.width / 2, self.bounds.size.height - self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupContentPositionCenterRight:
            self.contentShowFrame = CGRectMake(self.bounds.size.width - self.contentOriginFrame.size.width, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        default:
            break;
    }
}

- (void)setShowType:(WSPopupShowType)showType
{
    _showType = showType;
    switch (showType) {
        case WSPopupShowTypeNone:
            self.contentBeginFrame = self.contentOriginFrame;
            break;
        case WSPopupShowTypeSlideFromTop:
            self.contentBeginFrame = CGRectMake(self.contentOriginFrame.origin.x, -self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromLeft:
            self.contentBeginFrame = CGRectMake(-self.contentOriginFrame.size.width, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromBottom:
            self.contentBeginFrame = CGRectMake(self.contentOriginFrame.origin.x, CGRectGetMaxY(self.bounds), self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromRight:
            self.contentBeginFrame = CGRectMake(self.bounds.size.width, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromCenterTop:
            self.contentBeginFrame = CGRectMake((self.bounds.size.width - self.contentOriginFrame.size.width) / 2, -self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromCenterLeft:
            self.contentBeginFrame = CGRectMake(-self.contentOriginFrame.size.width, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromCenterBottom:
            self.contentBeginFrame = CGRectMake((self.bounds.size.width - self.contentOriginFrame.size.width) / 2, CGRectGetMaxY(self.bounds), self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeSlideFromCenterRight:
            self.contentBeginFrame = CGRectMake(self.bounds.size.width, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupShowTypeBounceIn:
            self.contentBeginFrame = self.contentOriginFrame;
            break;
        case WSPopupShowTypeFadeIn:
            self.contentBeginFrame = self.contentShowFrame;
            break;
        default:
            break;
    }
}

- (void)setHiddenType:(WSPopupHiddenType)hiddenType
{
    _hiddenType = hiddenType;
    switch (hiddenType) {
        case WSPopupHiddenTypeNone:
            self.contentEndFrame = self.contentOriginFrame;
            break;
        case WSPopupHiddenTypeSlideToTop:
            self.contentEndFrame = CGRectMake(self.contentOriginFrame.origin.x, -self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToLeft:
            self.contentEndFrame = CGRectMake(-self.contentOriginFrame.size.width, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToBottom:
            self.contentEndFrame = CGRectMake(self.contentOriginFrame.origin.x, CGRectGetMaxY(self.bounds), self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToRight:
            self.contentEndFrame = CGRectMake(self.bounds.size.width, self.contentOriginFrame.origin.y, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToCenterTop:
            self.contentEndFrame = CGRectMake((self.bounds.size.width - self.contentOriginFrame.size.width) / 2, -self.contentOriginFrame.size.height, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToCenterLeft:
            self.contentEndFrame = CGRectMake(-self.contentOriginFrame.size.width, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToCenterBottom:
            self.contentEndFrame = CGRectMake((self.bounds.size.width - self.contentOriginFrame.size.width) / 2, CGRectGetMaxY(self.bounds), self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeSlideToCenterRight:
            self.contentEndFrame = CGRectMake(self.bounds.size.width, self.bounds.size.height / 2 - self.contentOriginFrame.size.height / 2, self.contentOriginFrame.size.width, self.contentOriginFrame.size.height);
            break;
        case WSPopupHiddenTypeBounceOut:
            self.contentEndFrame = self.contentOriginFrame;
            break;
        case WSPopupHiddenTypeFadeOut:
            self.contentEndFrame = self.contentShowFrame;
            break;
        default:
            break;
    }
}

- (void)setBackgroundAlpfa:(CGFloat)backgroundAlpfa
{
    _backgroundAlpfa = backgroundAlpfa;
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0.f alpha:backgroundAlpfa];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [self setContentWidthMultiplied:self.contentWidthMultiplied];
    [self setContentHeightMultiplied:self.contentHeightMultiplied];
}

- (void)setContentWidthMultiplied:(CGFloat)contentWidthMultiplied
{
    _contentWidthMultiplied = contentWidthMultiplied;
    
    [self updateContentOriginFrame];
}

- (void)setContentHeightMultiplied:(CGFloat)contentHeightMultiplied
{
    _contentHeightMultiplied = contentHeightMultiplied;
    
    [self updateContentOriginFrame];
}

- (void)setContentWidthOffset:(CGFloat)contentWidthOffset
{
    _contentWidthOffset = contentWidthOffset;
    
    [self updateContentOriginFrame];
}

- (void)setContentHeightOffset:(CGFloat)contentHeightOffset
{
    _contentHeightOffset = contentHeightOffset;
    
    [self updateContentOriginFrame];
}

- (void)setContentOriginFrame:(CGRect)contentOriginFrame
{
    _contentOriginFrame = contentOriginFrame;
    _contentWidthMultiplied = (contentOriginFrame.size.width - self.contentWidthOffset) / self.bounds.size.width;
    _contentHeightMultiplied = (contentOriginFrame.size.height - self.contentHeightOffset) / self.bounds.size.height;
    
    [self setShowType:self.showType];
    [self setHiddenType:self.hiddenType];
    [self setContentPosition:self.contentPosition];
}

@end
