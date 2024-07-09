//
//  AppDelegate.m
//  Sample-Objective-C
//
//  Created by NooN on 11/9/23.
//

#import "AppDelegate.h"

#import <UqudoSDK/UQTrace.h>
#import "MyAccessToken.h"

@interface AppDelegate ()

@property (strong, nonatomic) MyAccessToken *myAccessToken;

@end

@implementation AppDelegate

@synthesize accessToken;
@synthesize nonce;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary<UIApplicationLaunchOptionsKey,id> *)launchOptions {
    [self requestAccesToken];
    [self initUqudoBuilder];
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark - Access Token Helper

- (void)requestAccesToken {
    self.myAccessToken = [[MyAccessToken alloc] init];
    [self.myAccessToken requestAccessTokenWithCompletion:^(NSString * _Nonnull accessToken, NSError * _Nonnull error) {
        self.accessToken = accessToken;
        NSLog(@"accessToken: %@", accessToken);
    }];
}


#pragma mark - Init Builder
- (void)initUqudoBuilder {
    // Config Tracer object for analytic porpose
    UQTracer *tracer = [[UQTracer alloc] init];
    self.uqudoBuilder = [[UQBuilderController alloc] initWithTracer:tracer];
}

@end
