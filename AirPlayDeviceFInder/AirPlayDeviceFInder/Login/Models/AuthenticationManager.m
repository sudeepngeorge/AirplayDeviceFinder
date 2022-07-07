//
//  AuthenticationManager.m
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

@import MSAL;
#import "AuthenticationManager.h"

//Azure AD MSAL Configuration Constants
static NSString * const kClientID = @"6b736640-a8b1-4299-9124-e405fc8ffba0";
static NSString * const kGraphEndpoint = @"https://graph.microsoft.com/" ;
static NSString * const kAuthority = @"https://login.microsoftonline.com/common";
static NSString * const kRedirectUri = @"msauth.com.sudeepg.AirPlayDeviceFinder://auth";
static NSString * const kScopes = @"user.read";


@interface AuthenticationManager()

///MSAL Application Context. Azure AD understand the client application based on this class configuration
@property (strong, nonatomic) MSALPublicClientApplication* applicationContext;

///MSALWebviewParameters used for passing the presentationViewController to MSAL library
@property (strong, nonatomic) MSALWebviewParameters* webViewParameters;

///Logged in user account
@property (strong, nonatomic) MSALAccount* currentAccount;

///View Controller used for presenting azure authentication page
@property (weak, nonatomic) UIViewController* presentationViewController;

@end

@implementation AuthenticationManager

// Initializer for authentication manager
// Accepts a UIViewController as presentationViewController.
// Login UI from Microsoft will be presented over presentationViewController
- (id)initWithPresentationViewController:(UIViewController *)presentationViewController {
    if (self = [super init]) {
        self.presentationViewController = presentationViewController;
        [self initializeAuthenticationManager];
    }
    return self;
}

/// Method to initialize MSAL Library and load current user session if any exists.
- (void)initializeAuthenticationManager {
    [self initMSAL];
    [self loadCurrentAccountWithCompletionHandler:nil];
}

#pragma mark Azure AD Initialization

/// - Create ApplicationContext to connect with Azure AD.
/// - Initializes web-view parameters.
- (void)initMSAL {
    NSURL *authorityURL = [NSURL URLWithString:kAuthority];
    if (authorityURL != nil) {
        MSALAADAuthority *authority = (MSALAADAuthority*)[MSALAADAuthority authorityWithURL:authorityURL error:NULL];
        MSALPublicClientApplicationConfig *msalConfiguration = [[MSALPublicClientApplicationConfig alloc]initWithClientId:kClientID redirectUri:kRedirectUri authority:authority];
        NSError *error = nil;
        self.applicationContext = [[MSALPublicClientApplication alloc] initWithConfiguration:msalConfiguration error:&error];
        NSLog(@"%@", error.debugDescription);
    }
    [self initWebViewParameters];
}

/// Initializes web-view with presentation controller
- (void)initWebViewParameters {
    self.webViewParameters = [[MSALWebviewParameters alloc] initWithAuthPresentationViewController:self.presentationViewController];
}

#pragma mark Account Operations

typedef void (^AccountCompletion)(MSALAccount *);

/// - Method to load current user account details from Azure AD.
/// - It will update the currentAccount field with new value and call completion handler.
/// - AccountCompletion contains the current MSALAccount if found, else return nil
- (void) loadCurrentAccountWithCompletionHandler:(AccountCompletion)completionHandler {
    if (self.applicationContext != nil) {
        MSALParameters *msalParameters = [[MSALParameters alloc] init];
        [msalParameters setCompletionBlockQueue:dispatch_get_main_queue()];
        [self.applicationContext getCurrentAccountWithParameters:msalParameters completionBlock:^(MSALAccount * _Nullable account, MSALAccount * _Nullable previousAccount, NSError * _Nullable error) {
            if (account != nil) {
                [self updateCurrentAccount:account];
                if (completionHandler != nil) {
                    completionHandler(account);
                }
                return;
            }
            [self updateCurrentAccount:nil];
            if (completionHandler != nil) {
                completionHandler(nil);
            }
        }];
        
    }
}

/// - Method to update current account property.
- (void)updateCurrentAccount:(MSALAccount * )account {
    self.currentAccount = account;
}

/// Remove LoggedIn user account from MSAL Cache.
/// It will also update currentAccount property to nil
- (void) logoutUserFromAccount:(MSALAccount *)account CompletionHandler:(nonnull void(^)(BOOL isSuccess)) completionHandler {
    MSALSignoutParameters *signoutParameters = [[MSALSignoutParameters alloc] initWithWebviewParameters: self.webViewParameters];
    signoutParameters.signoutFromBrowser = true;
    signoutParameters.wipeAccount = true;
    
    NSError *error = nil;
    [self.applicationContext removeAccount:account error: &error];
    if (error != nil) {
        completionHandler(false);
    }
    else {
        [self updateCurrentAccount:nil];
        completionHandler(true);
    }
}

#pragma mark Acquiring Token

/// It will present a Microsoft login UI to enter the credentials
/// completionHandler return true when user logged in successfully.
/// if user couldn't login for any reason it will return false.
- (void)acquireTokenInteractivelyWithCompletionHandler : (nonnull void (^)(BOOL))completionHandler {
    if (self.applicationContext != nil &&  self.webViewParameters != nil) {
        MSALInteractiveTokenParameters *parameters = [[MSALInteractiveTokenParameters alloc]initWithScopes:@[kScopes] webviewParameters:self.webViewParameters];
        [parameters setPromptType:MSALPromptTypeLogin];
        [self.applicationContext acquireTokenWithParameters:parameters completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                completionHandler(false);
                return;
            }
            if (result == nil) {
                completionHandler(false);
                return;
            }
            [self updateCurrentAccount:result.account];
            completionHandler(true);
        }];
    }
}

/// It will login an existing user using the existing token / refresh token in the cache
/// If token is not present or if user session tokens expired, user will be asked to login interactively
/// completionHandler return true when user logged in successfully.
/// if user couldn't login for any reason it will return false.
- (void)acquireTokenSilentlyForAccount:(MSALAccount *)account completionHandler : (nonnull void (^)(BOOL))completionHandler  {
    if (self.applicationContext != nil) {
        MSALSilentTokenParameters *parameters = [[MSALSilentTokenParameters alloc] initWithScopes:@[kScopes] account:account];
        [self.applicationContext acquireTokenSilentWithParameters:parameters completionBlock:^(MSALResult * _Nullable result, NSError * _Nullable error) {
            if (error != nil) {
                if (error.code == MSALErrorInteractionRequired) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self acquireTokenInteractivelyWithCompletionHandler:completionHandler];
                    });
                    return;
                }
                completionHandler(false);
                return;
            }
            
            if (result == nil) {
                completionHandler(false);
                return;
            }
            
            completionHandler(true);
        }];
    }
}

#pragma mark : AuthenticationManagerProtocol

///  Logins user with Microsoft Azure AD and returns callback.
- (void)loginUserWithCompletionHandler:(nonnull void (^)(BOOL))completionHandler {
    [self loadCurrentAccountWithCompletionHandler:^(MSALAccount *account) {
        if (account != nil) {
            [self acquireTokenSilentlyForAccount:account completionHandler:completionHandler];
        }
        else {
            [self acquireTokenInteractivelyWithCompletionHandler:completionHandler];
        }
    }];
}

/// Clear user session and returns callback.
- (void)logoutUserWithCompletionHandler:(nonnull void(^)(BOOL isSuccess)) completionHandler {
    if (self.applicationContext != nil) {
        if (self.currentAccount == nil) {
            [self loadCurrentAccountWithCompletionHandler:^(MSALAccount * account) {
                if (account != nil) {
                    [self logoutUserFromAccount:account CompletionHandler:completionHandler];
                }
                else {
                    completionHandler(true);
                }
            }];
        }
        else {
            [self logoutUserFromAccount:self.currentAccount CompletionHandler:completionHandler];
        }
    }
    else{
        completionHandler(false);
    }
}

/// Auto login user if previous session token exists. 
- (void)loginExistingInUser:(nonnull CompletionHandler)completionHandler {
    [self loadCurrentAccountWithCompletionHandler:^(MSALAccount *account) {
        if (account != nil) {
            [self acquireTokenSilentlyForAccount:account completionHandler:completionHandler];
        }
        else {
            completionHandler(false);
        }
    }];
}

@end
