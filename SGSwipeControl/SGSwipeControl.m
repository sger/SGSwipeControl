//
//  SGSwipeControl.m
//  SGSwipeControl
//
//  Created by Spiros Gerokostas on 12/22/13.
//  Copyright (c) 2013 Spiros Gerokostas. All rights reserved.
//

#import "SGSwipeControl.h"

@interface SGSwipeControl ()

@property (nonatomic, strong) NSMutableArray *buttons;

- (void)_setup;
- (void)_touchButton:(id)sender;
- (void)_previous:(id)sender;
- (void)_next:(id)sender;

@end

@implementation SGSwipeControl

@synthesize scrollView = _scrollView;
@synthesize data = _data;
@synthesize currentIndex = _currentIndex;
@synthesize margin = _margin;
@synthesize dx = _dx;
@synthesize dy = _dy;
@synthesize backgroundControl = _backgroundControl;
@synthesize backgroundColorButton = _backgroundColorButton;
@synthesize delegate = _delegate;

#pragma mark - Accessors

- (void)setBackgroundControl:(UIColor *)backgroundControl
{
    _backgroundControl = backgroundControl;
    self.backgroundColor = _backgroundControl;
    [self setNeedsDisplay];
}

- (void)setBackgroundColorButton:(UIColor *)backgroundColorButton
{
    _backgroundColorButton = backgroundColorButton;
    [self setNeedsDisplay];
}

- (void)setDx:(CGFloat)dx
{
    _dx = dx;
    [self setNeedsLayout];
}

- (void)setDy:(CGFloat)dy
{
    _dy = dy;
    [self setNeedsLayout];
}

- (void)setData:(NSArray *)value
{
    if (_data == value)
    {
        return;
    }
    
    [self willChangeValueForKey:@"data"];
    
    _data = value;
    
    _buttons = [[NSMutableArray alloc] init];
    
    while ([[_scrollView subviews] count] > 0)
    {
        [[[_scrollView subviews] objectAtIndex:0] removeFromSuperview];
    }
    
    NSUInteger num = [value count];
    
    for (int i = 0; i < num; i++)
    {
        UIButton *buttonLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        [buttonLabel setTitle:[_data objectAtIndex:i] forState:UIControlStateNormal];
        [buttonLabel.titleLabel setFont:[UIFont systemFontOfSize:24.0f]];
        [buttonLabel.titleLabel setTextColor:[UIColor whiteColor]];
        [buttonLabel.titleLabel setTextAlignment:NSTextAlignmentCenter];
        buttonLabel.backgroundColor = self.backgroundColorButton;
        [buttonLabel setAlpha:0.3f];
        [buttonLabel addTarget:self action:@selector(_touchButton:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:buttonLabel];
         [_buttons addObject:buttonLabel];
    }
    
    CGSize size = _scrollView.bounds.size;
    _scrollView.contentSize = CGSizeMake(size.width * [_data count], size.height);
    [self didChangeValueForKey:@"data"];
    
    UILabel *currentLabel = [_buttons objectAtIndex:(long)self.currentIndex];
    currentLabel.alpha = 1.0f;
}

- (void)setMargin:(CGFloat)value
{
    _margin = value;
    [self setNeedsLayout];
}

- (void)setCurrentIndex:(NSInteger)value
{
    if (value >= [_data count])
    {
        value = ([_data count] > 0) ? [_data count] - 1 : 0;
    }
    
    if (value == _currentIndex)
    {
        return;
    }
    
    [self willChangeValueForKey:@"currentIndex"];
    _currentIndex = value;
    [_scrollView setContentOffset:CGPointMake(value * _scrollView.bounds.size.width, 0) animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self didChangeValueForKey:@"currentIndex"];
}

#pragma mark - Actions

- (void)_touchButton:(id)sender
{
    UIButton *button = (UIButton *)sender;
    
    if ([_delegate respondsToSelector:@selector(touch:withValue:)])
    {
        [_delegate touch:self withValue:button.titleLabel.text];
    }
}

#pragma mark - NSObject

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self _setup];
    }
    
    return self;
}

- (void)dealloc
{
    _data = nil;
    _buttons = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = CGRectInset(self.bounds, self.margin, 0.0f);
    
    if (!CGRectEqualToRect(frame, _scrollView.frame))
    {
        _scrollView.frame = frame;
        _scrollView.contentOffset = CGPointMake(self.currentIndex * _scrollView.bounds.size.width, 0.0f);
    }
    
    CGSize size = _scrollView.bounds.size;
    
    NSInteger index = 0;
    
    for (UIView *view in [_scrollView subviews])
    {
        view.frame = CGRectInset(CGRectMake(size.width * index, 0.0f, size.width, size.height), self.dx, self.dy);
        index++;
    }
    
    _scrollView.contentSize = CGSizeMake(size.width * [[_scrollView subviews] count], size.height);
}


#pragma mark - Private implementation

- (void)_setup
{
    self.backgroundControl = [UIColor blackColor];
    self.backgroundColor = self.backgroundControl;
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = YES;
    _scrollView.alwaysBounceHorizontal = YES;
    _scrollView.clipsToBounds = NO;
    _scrollView.delegate = self;
    [self addSubview:_scrollView];
    
    self.backgroundColorButton = [UIColor grayColor];
    self.margin = 0.0f;
    self.dx = 0.0f;
    self.dy = 0.0f;
}

- (void)_previous:(id)sender
{
    if (self.currentIndex > 0)
    {
        [self setCurrentIndex:self.currentIndex - 1];
    }
}

- (void)_next:(id)sender
{
    [self setCurrentIndex:self.currentIndex + 1];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    UILabel *currentLabel = [_buttons objectAtIndex:(long)self.currentIndex];
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        currentLabel.alpha = 0.3f;
        
    } completion:nil];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat width = _scrollView.bounds.size.width;
    [self willChangeValueForKey:@"currentIndex"];
    _currentIndex = roundf(_scrollView.contentOffset.x / width);
    
    UIButton *currentButton = [_buttons objectAtIndex:(long)self.currentIndex];
    
    if ([_delegate respondsToSelector:@selector(swipeControl:withValue:)])
    {
        [_delegate swipeControl:self withValue:currentButton.currentTitle];
    }
    
    [UIView animateWithDuration:0.4 delay:0.0f options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction animations:^{
        
        currentButton.alpha = 1.0f;
        
    } completion:nil];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    [self willChangeValueForKey:@"currentPage"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    if (location.x < self.bounds.size.width / 2)
    {
        [self _previous:nil];
    }
    else if (location.x > self.bounds.size.height - _margin)
    {
        [self _next:nil];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    [_scrollView setContentOffset: CGPointMake(_scrollView.contentOffset.x, 0)];
}

@end
