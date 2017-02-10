//
//  RootService.h
//  Blockchain
//
//  Created by Kevin Wu on 8/15/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import "Wallet.h"
#import "RootService.h"
#import "MultiAddressResponse.h"
#import "TabViewController.h"
#import "PEPinEntryController.h"
#import "BCModalView.h"
#import "BCModalViewController.h"
#import "ECSlidingViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "UpgradeViewController.h"
#import "SettingsNavigationController.h"
#import <AVFoundation/AVFoundation.h>
#import "AccountsAndAddressesNavigationController.h"
#import "TransactionsViewController.h"
#import "TransferAllFundsViewController.h"
#import "NSNumberFormatter+Currencies.h"
#import "CertificatePinner.h"
#import "ReminderModalViewController.h"
#import <WebKit/WebKit.h>

@protocol TopViewController;

@class TransactionsViewController, BCFadeView, ReceiveCoinsViewController, SendViewController, BCCreateWalletView, BCManualPairView, MultiAddressResponse, PairingCodeParser, MerchantMapViewController, BCWebViewController, BackupNavigationViewController, BuyBitcoinViewController;

@interface RootService : NSObject <UIApplicationDelegate, WalletDelegate, PEPinEntryControllerDelegate, MFMailComposeViewControllerDelegate, CertificatePinnerDelegate, ReminderModalDelegate> {
    
    Wallet *wallet;
    
    SystemSoundID alertSoundID;
    SystemSoundID beepSoundID;
    SystemSoundID dingSoundID;
    
    IBOutlet BCFadeView *busyView;
    IBOutlet UILabel *busyLabel;
    
    IBOutlet BCCreateWalletView *createWalletView;
    IBOutlet BCModalContentView *pairingInstructionsView;
    IBOutlet BCManualPairView *manualPairView;
    
    IBOutlet UIButton *scanPairingCodeButton;
    IBOutlet UIButton *manualPairButton;
    
    BOOL validateSecondPassword;
    IBOutlet UILabel *secondPasswordDescriptionLabel;
    IBOutlet UIView *secondPasswordView;
    IBOutlet UITextField *secondPasswordTextField;
    IBOutlet UIButton *secondPasswordButton;
    
    IBOutlet UIView *mainPasswordView;
    IBOutlet UITextField *mainPasswordTextField;
    IBOutlet UIButton *forgetWalletButton;
    
@public
    
    BOOL symbolLocal;
}

@property (nonatomic, weak) UIViewController <TopViewController> *topViewControllerDelegate;

@property (strong, nonatomic) IBOutlet ECSlidingViewController *slidingViewController;
@property (strong, nonatomic) IBOutlet TabViewcontroller *tabViewController;
@property (strong, nonatomic) IBOutlet TransactionsViewController *transactionsViewController;
@property (strong, nonatomic) IBOutlet ReceiveCoinsViewController *receiveViewController;
@property (strong, nonatomic) IBOutlet SendViewController *sendViewController;
@property (strong, nonatomic) IBOutlet MerchantMapViewController *merchantViewController;
@property (strong, nonatomic) IBOutlet BCWebViewController *bcWebViewController;
@property (strong, nonatomic) IBOutlet BackupNavigationViewController *backupNavigationViewController;
@property (strong, nonatomic) SettingsNavigationController *settingsNavigationController;
@property (strong, nonatomic) AccountsAndAddressesNavigationController *accountsAndAddressesNavigationController;

@property (strong, nonatomic) IBOutlet UIImageView *mainLogoImageView;
@property (strong, nonatomic) IBOutlet UILabel *mainTitleLabel;

@property (nonatomic, assign) UIBackgroundTaskIdentifier backgroundUpdateTask;

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (strong, nonatomic) Wallet *wallet;
@property (strong, nonatomic) MultiAddressResponse *latestResponse;
@property (nonatomic, strong) NSString *loadingText;

@property (strong, nonatomic) IBOutlet BCModalView *modalView;
@property (strong, nonatomic) NSMutableArray *modalChain;

@property (strong, nonatomic) TransferAllFundsViewController *transferAllFundsModalController;

@property (nonatomic) BuyBitcoinViewController *buyBitcoinViewController;

// PIN Entry
@property (nonatomic, strong) PEPinEntryController *pinEntryViewController;
@property (nonatomic, copy) void (^pinViewControllerCallback)(BOOL);
@property (nonatomic, assign) NSUInteger lastEnteredPIN;
@property (nonatomic) NSTimer *loginTimer;

@property(nonatomic, strong) NSNumberFormatter *btcFormatter;
@property(nonatomic, strong) NSNumberFormatter *localCurrencyFormatter;

@property (nonatomic) BOOL changedPassword;

// Certificate Pinning
@property (nonatomic) CertificatePinner *certificatePinner;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidBecomeActive:(UIApplication *)application;
- (void)applicationWillResignActive:(UIApplication *)application;
- (void)applicationDidEnterBackground:(UIApplication *)application;
- (void)applicationWillEnterForeground:(UIApplication *)application;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

- (void)setAccountData:(NSString*)guid sharedKey:(NSString*)sharedKey;

- (void)playBeepSound;
- (void)playAlertSound;

- (TabViewcontroller*)tabViewController;
- (TransactionsViewController*)transactionsViewController;

- (void)showWelcome;
- (void)logout;
- (void)forgetWallet;
- (void)showPasswordModal;

- (void)toggleSideMenu;
- (void)closeSideMenu;

- (void)swipeLeft;
- (void)swipeRight;

// BC Modal
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText;
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume;
- (void)showModalWithContent:(UIView *)contentView closeType:(ModalCloseType)closeType showHeader:(BOOL)showHeader headerText:(NSString *)headerText onDismiss:(void (^)())onDismiss onResume:(void (^)())onResume;
- (void)closeModalWithTransition:(NSString *)transition;
- (void)closeAllModals;

- (NSDictionary*)parseURI:(NSString*)string;

// Wallet Delegate
- (void)didSetLatestBlock:(LatestBlock*)block;
- (void)walletFailedToDecrypt;

// Display a message
- (void)standardNotifyAutoDismissingController:(NSString *)message;
- (void)standardNotifyAutoDismissingController:(NSString *)message title:(NSString *)title;
- (void)standardNotify:(NSString*)message;
- (void)standardNotify:(NSString*)message title:(NSString*)title;

// Busy view with loading text
- (void)showBusyViewWithLoadingText:(NSString *)text;
- (void)updateBusyViewLoadingText:(NSString *)text;
- (void)hideBusyView;

// Request Second Password From User
- (void)getSecondPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error;
- (void)getPrivateKeyPassword:(void (^)(NSString *))success error:(void (^)(NSString *))error;

- (void)reload;
- (void)reloadAfterMultiAddressResponse;
- (void)toggleSymbol;

- (void)logoutAndShowPasswordModal;

- (NSInteger)filterIndex;
- (void)filterTransactionsByAccount:(int)accountIndex;
- (void)filterTransactionsByImportedAddresses;
- (void)removeTransactionsFilter;

- (void)pushWebViewController:(NSString*)url title:(NSString *)title;

- (void)showSendCoins;
- (void)showAccountsAndAddresses;
- (void)showDebugMenu:(int)presenter;
- (void)showHdUpgrade;
- (void)showBackupReminder:(BOOL)firstReceive;

- (void)reloadTransactionFilterLabel;

- (IBAction)receiveCoinClicked:(UIButton *)sender;
- (IBAction)transactionsClicked:(UIButton *)sender;
- (IBAction)sendCoinsClicked:(UIButton *)sender;
- (IBAction)merchantClicked:(UIButton *)sender;
- (IBAction)QRCodebuttonClicked:(id)sender;
- (IBAction)forgetWalletClicked:(id)sender;
- (IBAction)menuClicked:(id)sender;
- (IBAction)scanAccountQRCodeclicked:(id)sender;
- (IBAction)secondPasswordClicked:(id)sender;
- (IBAction)mainPasswordClicked:(id)sender;
- (IBAction)manualPairClicked:(id)sender;

- (IBAction)accountsAndAddressesClicked:(id)sender;
- (IBAction)accountSettingsClicked:(id)sender;
- (IBAction)backupFundsClicked:(id)sender;
- (IBAction)supportClicked:(id)sender;
- (IBAction)logoutClicked:(id)sender;
- (IBAction)buyBitcoinClicked:(id)sender;

- (void)setupTransferAllFunds;

- (void)paymentReceived:(NSDecimalNumber *)amount showBackupReminder:(BOOL)showBackupReminder;

- (void)clearPin;
- (void)showPinModalAsView:(BOOL)asView;
- (BOOL)isPinSet;
- (void)validatePINOptionally;
- (void)changePIN;

- (BOOL)checkInternetConnection;

- (NSString *)checkForTouchIDAvailablility;
- (void)disabledTouchID;

- (AVCaptureDeviceInput *)getCaptureDeviceInput;

- (void)scanPrivateKeyForWatchOnlyAddress:(NSString *)address;
- (void)askUserToAddWatchOnlyAddress:(NSString *)address success:(void (^)(NSString *))success;

- (void)verifyTwoFactorSMS;
- (void)verifyTwoFactorGoogle;
- (void)verifyTwoFactorYubiKey;

- (void)rateApp;
- (void)authorizationRequired;

- (void)endBackgroundUpdateTask;

- (NSString *)getVersionLabelString;
- (void)checkForUnusedAddress:(NSString *)address success:(void (^)(NSString *, BOOL))successBlock error:(void (^)())errorBlock;
@end

extern RootService *app;
