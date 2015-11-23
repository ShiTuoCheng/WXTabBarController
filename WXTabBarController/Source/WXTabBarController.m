//
//  WXTabBarController.m
//  WXTabBarController
//
//  Created by leichunfeng on 15/11/20.
//  Copyright © 2015年 leichunfeng. All rights reserved.
//

#import "WXTabBarController.h"

@interface WXTabBarController () <UIScrollViewDelegate>

@property (nonatomic, copy) NSArray<__kindof UIViewController *> *backingViewControllers;
@property (nonatomic, assign) NSUInteger backingSelectedIndex;

@property (nonatomic, copy) NSArray *tabBarButtons;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation WXTabBarController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    
    self.scrollView.pagingEnabled = YES;
    self.scrollView.bounces  = NO;
    self.scrollView.delegate = self;
    
    [self.view insertSubview:self.scrollView belowSubview:self.tabBar];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    self.scrollView.delegate = nil;
    self.scrollView.frame = CGRectMake(0, 0, size.width, size.height);
    self.scrollView.contentOffset = CGPointMake(size.width * self.backingSelectedIndex, 0);
    self.scrollView.contentSize = CGSizeMake(size.width * self.backingViewControllers.count, size.height);
    self.scrollView.delegate = self;
    
    [self.backingViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *_) {
        viewController.view.frame = CGRectMake(size.width * idx, 0, size.width, size.height);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.tabBarButtons enumerateObjectsUsingBlock:^(UIView *tabBarButton, NSUInteger idx, BOOL *_) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:tabBarButton.subviews.firstObject.frame];
            imageView.image = self.backingViewControllers[idx].tabBarItem.selectedImage;
            [tabBarButton insertSubview:imageView atIndex:0];
            
            imageView.translatesAutoresizingMaskIntoConstraints = NO;
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[1]
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[1]
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[1]
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:imageView
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[1]
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:0]];
            
            UILabel *label = [[UILabel alloc] initWithFrame:tabBarButton.subviews.lastObject.frame];
            label.textColor = self.tabBar.tintColor;
            label.font = [(UILabel *)tabBarButton.subviews.lastObject font];
            label.text = self.backingViewControllers[idx].tabBarItem.title;
            [tabBarButton insertSubview:label atIndex:1];
            
            label.translatesAutoresizingMaskIntoConstraints = NO;
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeTop
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[3]
                                                                     attribute:NSLayoutAttributeTop
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeLeft
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[3]
                                                                     attribute:NSLayoutAttributeLeft
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeBottom
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[3]
                                                                     attribute:NSLayoutAttributeBottom
                                                                    multiplier:1
                                                                      constant:0]];
            
            [tabBarButton addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                                     attribute:NSLayoutAttributeRight
                                                                     relatedBy:NSLayoutRelationEqual
                                                                        toItem:tabBarButton.subviews[3]
                                                                     attribute:NSLayoutAttributeRight
                                                                    multiplier:1
                                                                      constant:0]];
        }];
        
        self.selectedIndex = 0;
    });
}

#pragma mark - Getters and Setters

- (NSArray *)viewControllers {
    return nil;
}

- (void)setViewControllers:(NSArray *)viewControllers {
    [self setViewControllers:viewControllers animated:NO];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated {
    self.backingViewControllers = viewControllers;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController {
    self.selectedIndex = [self.backingViewControllers indexOfObject:selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex {
    _backingSelectedIndex = selectedIndex;
    
    CGRect rectToVisible = CGRectMake(CGRectGetWidth(self.view.frame) * selectedIndex, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
   
    self.scrollView.delegate = nil;
    [self.scrollView scrollRectToVisible:rectToVisible animated:NO];
    self.scrollView.delegate = self;
    
    [self.tabBarButtons enumerateObjectsUsingBlock:^(UIView *tabBarButton, NSUInteger idx, BOOL *_) {
        [self tabBarButton:tabBarButton highlighted:(idx == selectedIndex) deltaAlpha:0];
    }];
}

- (void)setBackingViewControllers:(NSArray *)backingViewControllers {
    _backingViewControllers = backingViewControllers;
   
    [backingViewControllers enumerateObjectsUsingBlock:^(UIViewController *viewController, NSUInteger idx, BOOL *_) {
        [self addChildViewController:viewController];
        viewController.view.frame = CGRectMake(CGRectGetWidth(self.view.frame) * idx, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
        [self.scrollView addSubview:viewController.view];
    }];
   
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame) * backingViewControllers.count, CGRectGetHeight(self.view.frame));
}

- (NSArray *)tabBarButtons {
    if (_tabBarButtons == nil) {
        NSMutableArray *tabBarButtons = [[NSMutableArray alloc] init];
        for (UIView *subview in self.tabBar.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
                [tabBarButtons addObject:subview];
            }
        };
        _tabBarButtons = tabBarButtons.copy;
    }
    return _tabBarButtons;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger index = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
    CGFloat mod = fmod(scrollView.contentOffset.x, CGRectGetWidth(self.view.frame));
    CGFloat deltaAlpha = mod * (1.0 / CGRectGetWidth(self.view.frame));

    [self.tabBarButtons enumerateObjectsUsingBlock:^(UIView *tabBarButton, NSUInteger idx, BOOL *_) {
        if (idx == index) {
            [self tabBarButton:tabBarButton highlighted:YES deltaAlpha:deltaAlpha];
        } else if (idx == index + 1) {
            [self tabBarButton:tabBarButton highlighted:NO deltaAlpha:deltaAlpha];
        }
    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _backingSelectedIndex = scrollView.contentOffset.x / CGRectGetWidth(self.view.frame);
}

#pragma mark - UITabBarControllerDelegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    self.selectedViewController = viewController;
    return NO;
}

#pragma mark - Private methods

- (void)tabBarButton:(UIView *)tabBarButton highlighted:(BOOL)highlighted deltaAlpha:(CGFloat)deltaAlpha {
    if (highlighted) {
        tabBarButton.subviews[0].alpha = 1 - deltaAlpha;
        tabBarButton.subviews[1].alpha = 1 - deltaAlpha;
        tabBarButton.subviews[2].alpha = 0 + deltaAlpha;
        tabBarButton.subviews[3].alpha = 0 + deltaAlpha;
    } else {
        tabBarButton.subviews[0].alpha = 0 + deltaAlpha;
        tabBarButton.subviews[1].alpha = 0 + deltaAlpha;
        tabBarButton.subviews[2].alpha = 1 - deltaAlpha;
        tabBarButton.subviews[3].alpha = 1 - deltaAlpha;
    }
}

@end
