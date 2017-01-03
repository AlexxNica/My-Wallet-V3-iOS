//
//  BCNavigationController.h
//  Blockchain
//
//  Created by Kevin Wu on 10/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCFadeView.h"
#import "RootService.h"

@interface BCNavigationController : UINavigationController <TopViewController>
@property (nonatomic) UIView *topBar;
@property (nonatomic) BCFadeView *busyView;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) UILabel *busyLabel;
@property (nonatomic) NSString *headerTitle;
@property (nonatomic) UIButton *topRightButton;

@property (nonatomic) BOOL shouldHideBusyView;

- (id)initWithRootViewController:(UIViewController *)rootViewController title:(NSString *)title;
- (id)initWithRootViewControllerFromMainTab:(UIViewController *)rootViewController title:(NSString *)headerTitle;
- (void)showBusyViewWithLoadingText:(NSString *)text;
- (void)hideBusyView;

- (UIButton *)createTopRightButton;

@end
