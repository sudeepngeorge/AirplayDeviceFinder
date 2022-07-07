//
//  AuthenticationManagerInterface.h
//  AirPlayDeviceFInder
//
//  Created by Sudeep George on 07/07/22.
//


typedef void (^CompletionHandler)(BOOL);

/*
- AuthenticationManagerProtocol provides a weak dependecy to the Login VC
- It will help in avoiding the direct depenedency in viewControllers
- It also help to make view controller unit testable by mocking the Authentication Module
 */
@protocol AuthenticationManagerProtocol
@required

/// Auto login user if previous session token exists.
/// CompletionHandler -
///     true : if login is successfull
///     false : if login is failed. User should be provided with login options.
- (void)loginExistingInUser:(nonnull CompletionHandler) completionHandler;

///  Logins user with authentication mechanism and returns callback.
/// CompletionHandler
///     true : if login is successfull
///     false : if login is failed
- (void)loginUserWithCompletionHandler:(nonnull CompletionHandler) completionHandler;

/// Clear user session and returns callback.
/// CompletionHandler
///      true : if logout is successfull
///      false : if logout is failed
- (void)logoutUserWithCompletionHandler:(nonnull CompletionHandler) completionHandler;



@end
