//
//  AppDelegate.h
//  Sample-Objective-C
//
//  Created by NooN on 11/9/23.
//

#import <UIKit/UIKit.h>
#import <UqudoSDK/UQBuilderController.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (nonatomic, strong) UIWindow * window;
@property (strong, nonatomic) UQBuilderController *uqudoBuilder;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *nonce;

@end

