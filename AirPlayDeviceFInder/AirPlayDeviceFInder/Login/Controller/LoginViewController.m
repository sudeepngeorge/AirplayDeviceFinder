//
//  LoginViewController.m
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

#import "LoginViewController.h"
#import "AirPlayDeviceFInder-Swift.h"
#import <SystemConfiguration/SystemConfiguration.h>
@import MSAL;

@interface LoginViewController ()
//IBOutlets
@property (weak, nonatomic) IBOutlet UIView *accountInfoView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation LoginViewController

#pragma mark LifeCycle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeLoginView];
}

#pragma mark IBActions

//When user clicks on sign in button on loginviewcontroller we need to interactly login user
- (IBAction)signInButtonPressed:(id)sender {
    [self.authenticationManager loginUserWithCompletionHandler:^(BOOL isLoginSuccessFull) {
        dispatch_async(dispatch_get_main_queue(),^{
            if (isLoginSuccessFull) {
                [self loadHomeViewController];
            }
            else {
                //show alert
                [self showAlertWithTitle:@"Failed To Login"
                                 message:@"Sorry, We couldnt login you. Please try again later."
                            buttonTitles:@[@"OK"]
                              completion:NULL];
            }
        });
    }];
}


#pragma mark Helper Methods

- (void)initializeLoginView {
    if ([[InternetRechabilityManager shared] isConnected]) {
        [self loginUserIfSessionExists];
    }
    else {
        [self logoutUser];
    }
    //We dont need to monitor network anymore unitll next app launch
    [[InternetRechabilityManager shared] stopMonitoring];
}

- (void)loginUserIfSessionExists {
    [self startAnimating];
    [self.authenticationManager loginExistingInUser:^(BOOL isLoggedIn) {
        [self stopAnimating];
        if (isLoggedIn) {
            [self loadHomeViewController];
        }
        else {
            [self.loginView setHidden:false];
        }
    }];
}

- (void)logoutUser {
    [self startAnimating];
    [self.authenticationManager logoutUserWithCompletionHandler:^(BOOL isLoggedIn){}];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self stopAnimating];
        [self.loginView setHidden:false];
    });
}

- (void)startAnimating {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator startAnimating];
    });
}

- (void)stopAnimating {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.activityIndicator stopAnimating];
    });
}

- (void)loadHomeViewController {
    NSLog(@"Go to Landing Page");
}

@end
