//
//  SideMenuViewController.h
//  Blockchain
//
//  Created by Mark Pfluger on 10/3/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ECSlidingViewController.h"

@interface SideMenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ECSlidingViewControllerDelegate>

- (void)reload;
- (void)reloadTableView;
- (void)clearMenuRows;
- (void)addMenuRow:(NSString *)name icon:(NSString *)icon;

@end
