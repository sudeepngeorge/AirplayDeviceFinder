//
//  LoginViewController.h
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//


#import <UIKit/UIKit.h>

#import "AuthenticationManagerProtocol.h"

@interface LoginViewController : UIViewController

//Dependency Injection of authentication manager
@property (nonatomic ,strong) id<AuthenticationManagerProtocol> authenticationManager;

@end
