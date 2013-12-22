//
//  SGSwipeControl.h
//  SGSwipeControl
//
//  Created by Spiros Gerokostas on 12/22/13.
//  Copyright (c) 2013 Spiros Gerokostas. All rights reserved.
//

@protocol SGSwipeDelegate;

@interface SGSwipeControl : UIControl <UIScrollViewDelegate>

@property (nonatomic, assign) id<SGSwipeDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *data;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UIColor *backgroundControl;
@property (nonatomic, strong) UIColor *backgroundColorButton;
@property (nonatomic, assign) CGFloat dx;
@property (nonatomic, assign) CGFloat dy;

@end

#pragma mark - Protocols

@protocol SGSwipeDelegate <NSObject>

- (void)touch:(SGSwipeControl *)view withValue:(NSString *)value;
- (void)swipeControl:(SGSwipeControl *)view withValue:(NSString *)value;

@end
