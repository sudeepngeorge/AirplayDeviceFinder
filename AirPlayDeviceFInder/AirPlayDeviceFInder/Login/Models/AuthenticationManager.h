//
//  AuthenticationManager.h
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//

#import <Foundation/Foundation.h>
#import "AuthenticationManagerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface AuthenticationManager : NSObject<AuthenticationManagerProtocol>

///Presentation Controller is required for MSAL Library to display Microsoft Authentication Page over it.
- (id)initWithPresentationViewController:(UIViewController *)presentationViewController;

@end

NS_ASSUME_NONNULL_END

