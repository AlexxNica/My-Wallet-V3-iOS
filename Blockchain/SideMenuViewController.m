//
//  SideMenuViewController.m
//  Blockchain
//
//  Created by Mark Pfluger on 10/3/14.
//  Copyright (c) 2014 Blockchain Luxembourg S.A. All rights reserved.
//

#import "SideMenuViewController.h"
#import "RootService.h"
#import "ECSlidingViewController.h"
#import "BCCreateAccountView.h"
#import "BCEditAccountView.h"
#import "AccountTableCell.h"
#import "SideMenuViewCell.h"
#import "BCLine.h"
#import "PrivateKeyReader.h"
#import "UIViewController+Autodismiss.h"


@interface SideMenuViewController ()

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation SideMenuViewController

ECSlidingViewController *sideMenu;

UITapGestureRecognizer *tapToCloseGestureRecognizer;

const int menuEntries = 6;
int balanceEntries = 0;
int accountEntries = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sideMenu = app.slidingViewController;
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - sideMenu.anchorLeftPeekAmount, MENU_ENTRY_HEIGHT * menuEntries) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.showsVerticalScrollIndicator = NO;
        tableView;
    });

    
    [self.view addSubview:self.tableView];
    
    // Blue background for bounce area
    CGRect frame = self.view.bounds;
    frame.origin.y = -frame.size.height;
    UIView* blueView = [[UIView alloc] initWithFrame:frame];
    blueView.backgroundColor = COLOR_BLOCKCHAIN_BLUE;
    [self.tableView addSubview:blueView];
    // Make sure the refresh control is in front of the blue area
    blueView.layer.zPosition -= 1;
    
    sideMenu.delegate = self;
    
    tapToCloseGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:app action:@selector(toggleSideMenu)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setSideMenuGestures];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self resetSideMenuGestures];
}

- (void)setSideMenuGestures
{
    // Hide status bar
    if (!app.pinEntryViewController.inSettings) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:NO];
    }
    
    // Disable all interactions on main view
    for (UIView *view in app.tabViewController.activeViewController.view.subviews) {
        [view setUserInteractionEnabled:NO];
    }
    [app.tabViewController.menuSwipeRecognizerView setUserInteractionEnabled:NO];
    
    // Enable Pan gesture and tap gesture to close sideMenu
    [app.tabViewController.activeViewController.view setUserInteractionEnabled:YES];
    ECSlidingViewController *sideMenu = app.slidingViewController;
    [app.tabViewController.activeViewController.view addGestureRecognizer:sideMenu.panGesture];
    
    [app.tabViewController.activeViewController.view addGestureRecognizer:tapToCloseGestureRecognizer];
    
    // Show shadow on current viewController in tabBarView
    UIView *castsShadowView = app.slidingViewController.topViewController.view;
    castsShadowView.layer.shadowOpacity = 0.3f;
    castsShadowView.layer.shadowRadius = 10.0f;
    castsShadowView.layer.shadowColor = [UIColor blackColor].CGColor;
}

- (void)resetSideMenuGestures
{
    // Show status bar again
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:YES];
    
    // Disable Pan and Tap gesture on main view
    [app.tabViewController.activeViewController.view removeGestureRecognizer:sideMenu.panGesture];
    [app.tabViewController.activeViewController.view removeGestureRecognizer:tapToCloseGestureRecognizer];
    
    // Enable interaction on main view
    for (UIView *view in app.tabViewController.activeViewController.view.subviews) {
        [view setUserInteractionEnabled:YES];
    }
    
    // Enable swipe to open side menu gesture on small bar on the left of main view
    [app.tabViewController.menuSwipeRecognizerView setUserInteractionEnabled:YES];
    [app.tabViewController.menuSwipeRecognizerView addGestureRecognizer:sideMenu.panGesture];
    
    // Enable swipe to switch between views on main view
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:app action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:app action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [app.tabViewController.activeViewController.view addGestureRecognizer:swipeLeft];
    [app.tabViewController.activeViewController.view addGestureRecognizer:swipeRight];
}

- (void)reload
{
    [self reloadNumberOfBalancesToDisplay];
    
    // Resize table view
    [self reloadTableViewSize];
    
    [self.tableView reloadData];
}

- (void)reloadTableView
{
    [self.tableView reloadData];
}

- (void)reloadNumberOfBalancesToDisplay
{
    // Total entries: 1 entry for the total balance, 1 for each HD account, 1 for the total legacy addresses balance (if needed)
    int numberOfAccounts = [app.wallet getActiveAccountsCount];
    balanceEntries = [[app.wallet activeLegacyAddresses] count] > 0 ? numberOfAccounts + 1 : numberOfAccounts;
    accountEntries = numberOfAccounts;
}

- (void)reloadTableViewSize
{
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width - sideMenu.anchorLeftPeekAmount, MENU_ENTRY_HEIGHT * menuEntries + BALANCE_ENTRY_HEIGHT * (balanceEntries + 1) + SECTION_HEADER_HEIGHT + MENU_BITCOIN_TICKER_HEIGHT);
    if (![self showBalances]) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width - sideMenu.anchorLeftPeekAmount, MENU_ENTRY_HEIGHT * menuEntries + MENU_BITCOIN_TICKER_HEIGHT);
    }
    
    // If the tableView is bigger than the screen, enable scrolling and resize table view to screen size
    if (self.tableView.frame.size.height > self.view.frame.size.height ) {
        self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width - sideMenu.anchorLeftPeekAmount, self.view.frame.size.height);
        
        // Add some extra space to bottom of tableview so things look nicer when scrolling all the way down
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, SECTION_HEADER_HEIGHT, 0);
        
        self.tableView.scrollEnabled = YES;
    }
    else {
        self.tableView.scrollEnabled = NO;
    }
}

- (Boolean)showBalances
{
    // Return true if the user has upgraded and either legacy adresses or multiple accounts
    return [app.wallet didUpgradeToHd] && ([[app.wallet activeLegacyAddresses] count] > 0 || [app.wallet getActiveAccountsCount] >= 2);
}

- (void)removeTransactionsFilter
{
    UITableViewHeaderFooterView *headerView = [self.tableView headerViewForSection:0];
    UIView *backgroundView = [[UIView alloc] initWithFrame:headerView.frame];
    [backgroundView setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
    headerView.backgroundView = backgroundView;
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    
    [app removeTransactionsFilter];
}

#pragma mark - SlidingViewController Delegate

- (id<UIViewControllerAnimatedTransitioning>)slidingViewController:(ECSlidingViewController *)slidingViewController animationControllerForOperation:(ECSlidingViewControllerOperation)operation topViewController:(UIViewController *)topViewController
{
    // SideMenu will slide in
    if (operation == ECSlidingViewControllerOperationAnchorRight) {
        [self setSideMenuGestures];
    }
    // SideMenu will slide out
    else if (operation == ECSlidingViewControllerOperationResetFromRight) {
        // Everything happens in viewDidDisappear: which is called after the slide animation is done
    }
    
    return nil;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self showBalances]) {
        if (indexPath.section != 1) {
#ifdef ENABLE_TRANSACTION_FILTERING
            BOOL deselected = NO;
            
            if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1 && [[app.wallet activeLegacyAddresses] count] > 0) {
                if ([app filterIndex] == FILTER_INDEX_IMPORTED_ADDRESSES) {
                    deselected = YES;
                } else {
                    [app filterTransactionsByImportedAddresses];
                }
            } else {
                if ([app.wallet getIndexOfActiveAccount:(int)indexPath.row] == [app filterIndex]) {
                    deselected = YES;
                } else {
                    [app filterTransactionsByAccount:[app.wallet getIndexOfActiveAccount:(int)indexPath.row]];
                }
            }
            
            if (deselected) {
                [self removeTransactionsFilter];
                [tableView deselectRowAtIndexPath:indexPath animated:NO];
            } else {
                UITableViewHeaderFooterView *headerView = [tableView headerViewForSection:indexPath.section];
                UIView *backgroundView = [[UIView alloc] initWithFrame:headerView.frame];
                [backgroundView setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
                headerView.backgroundView = backgroundView;
            }
#endif
            return;
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger row = indexPath.row;
    BOOL didUpgradeToHD = app.wallet.didUpgradeToHd;
    
    if (row == MENU_CELL_INDEX_ACCOUNTS_AND_ADDRESSES) {
        [app accountsAndAddressesClicked:nil];
    } else if (row == MENU_CELL_INDEX_SETTINGS) {
        [app accountSettingsClicked:nil];
    } else if (row == MENU_CELL_INDEX_MERCHANT){
        [app merchantClicked:nil];
    } else if (row == MENU_CELL_INDEX_SUPPORT) {
        [app supportClicked:nil];
    } else if (row == MENU_CELL_INDEX_UPGRADE) {
        if (didUpgradeToHD) {
            [app backupFundsClicked:nil];
        }
        else {
            [app showHdUpgrade];
        }
    } else if (row == MENU_CELL_INDEX_LOGOUT) {
        [app logoutClicked:nil];
    }
}

#pragma mark - UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![self showBalances]) {
        return MENU_ENTRY_HEIGHT;
    }
    if (indexPath.section != 2) {
        return BALANCE_ENTRY_HEIGHT;
    }
    return MENU_ENTRY_HEIGHT;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Empty table if not logged in:
    if (!app.wallet.guid) {
        return 0;
    }
    
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return MENU_BITCOIN_TICKER_HEIGHT;
    }
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // Total Balance
    if (section == 0) {
        UITableViewHeaderFooterView *view = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, MENU_BITCOIN_TICKER_HEIGHT)];
        UIView *backgroundView = [[UIView alloc] initWithFrame:view.frame];
        [backgroundView setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
        view.backgroundView = backgroundView;
        
        UILabel *tickerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.tableView.frame.size.width - 23, 18)];
        tickerLabel.adjustsFontSizeToFitWidth = YES;
        tickerLabel.text = [NSString stringWithFormat:@"%@ = %@", [NSNumberFormatter formatMoney:SATOSHI localCurrency:NO], [NSNumberFormatter formatMoney:SATOSHI localCurrency:YES]];
        tickerLabel.textColor = [UIColor whiteColor];
        tickerLabel.center = CGPointMake(tickerLabel.center.x, view.center.y);
        tickerLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:24];
        [view addSubview:tickerLabel];
        
        return view;
    }
    
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    if (sectionIndex == 0) {
        return 0;
    }
    if (sectionIndex == 1) {
        return menuEntries;
    }
    
    return balanceEntries;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier;
    
    if (indexPath.section == 1) {

        cellIdentifier = @"CellMenu";
        
        SideMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[SideMenuViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            
            UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
            [v setBackgroundColor:COLOR_BLOCKCHAIN_BLUE];
            cell.selectedBackgroundView = v;
        }
        NSString *upgradeOrBackupTitle;
        if (!app.wallet.didUpgradeToHd) {
            upgradeOrBackupTitle = BC_STRING_UPGRADE;
        }
        else {
            upgradeOrBackupTitle = BC_STRING_BACKUP_FUNDS;
        }
        
        NSMutableArray *titles;
        titles = [NSMutableArray arrayWithArray:@[upgradeOrBackupTitle, BC_STRING_SETTINGS, BC_STRING_ADDRESSES, BC_STRING_MERCHANT_MAP, BC_STRING_SUPPORT, BC_STRING_LOGOUT]];
        
        NSString *upgradeOrBackupImage;
        if (!app.wallet.didUpgradeToHd) {
            // XXX upgrade icon
            upgradeOrBackupImage = @"icon_upgrade";
        }
        else {
            upgradeOrBackupImage = @"security";
        }
        NSMutableArray *images;

        images = [NSMutableArray arrayWithArray:@[upgradeOrBackupImage, @"settings_icon", @"icon_wallet", @"icon_merchant", @"icon_support", @"logout_icon"]];
        
        cell.textLabel.text = titles[indexPath.row];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.imageView.image = [UIImage imageNamed:images[indexPath.row]];
        
        if ([images[indexPath.row] isEqualToString:@"security"]) {
            cell.imageView.image = [cell.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            [cell.imageView setTintColor:COLOR_BLOCKCHAIN_LIGHT_BLUE];
        }
        
        return cell;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        if ([self showBalances]) {
            // Custom separator inset
            float leftInset = (indexPath.section != 1) ? 56 : 15;
            [cell setSeparatorInset:UIEdgeInsetsMake(0, leftInset, 0, 0)];
            
            // No separator for last entry of each section
            if ((indexPath.section == 0 && indexPath.row == balanceEntries - 1) ||
                (indexPath.section == 1 && indexPath.row == menuEntries - 1)) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, CGRectGetWidth(cell.bounds)-15)];
            }
        } else {
            // Custom separator inset
            [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
            
            // No separator for last entry of each section
            if (indexPath.row == menuEntries - 1) {
                [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, CGRectGetWidth(cell.bounds)-15)];
            }
        }
    }
}

@end
