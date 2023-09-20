//
//  MyAccessToken.h
//  Sample-Objective-C
//
//  Created by NooN on 18/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyAccessToken : NSObject

- (void)requestAccessTokenWithCompletion:(void (^)(NSString *accessToken, NSError *error))handler;

@end

NS_ASSUME_NONNULL_END
