//
//  MyAccessToken.m
//  Sample-Objective-C
//
//  Created by NooN on 18/9/23.
//
// Retrieve the authorization token using oauth2 client credentials grant type.
// Note: Don’t perform this operation inside your mobile application but only from your backend
// For detail, please check on document https://docs.uqudo.com/docs/uqudo-api/authorisation

#import "MyAccessToken.h"

#define kMyAccessTokenRequestURL                @"https://auth.uqudo.io/api/oauth/token"
#define kMyAccessTokenRequesMethod              @"POST"

@implementation MyAccessToken


- (instancetype)init {
    self = [super init];
    if (self) {}
    return self;
}

- (void)requestAccessTokenWithCompletion:(void (^)(NSString *accessToken, NSError *error))handler {

    // Create a URL for your request
    NSURL *url = [NSURL URLWithString:kMyAccessTokenRequestURL];
    
    // Create an NSMutableURLRequest with the URL
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // Set the HTTP request method to POST
    [request setHTTPMethod:kMyAccessTokenRequesMethod];
    
    // Create a request parameters
    // You can obtain your client credentials by navigating to the "Credentials" tab located in the "Development" section of our Uqudo Customer Portal
    NSDictionary *parameters = @{@"grant_type": @"client_credentials",
                                 @"client_id":@"Provide your client ID",
                                 @"client_secret":@"Provide your client secret"};
    
    
    // Convert the dictionary to a query string
    NSMutableArray *paramArray = [NSMutableArray array];
    for (NSString *key in parameters) {
        NSString *param = [NSString stringWithFormat:@"%@=%@", key, parameters[key]];
        [paramArray addObject:param];
    }
    NSString *queryString = [paramArray componentsJoinedByString:@"&"];
    
    // Set the HTTP body with the query string
    [request setHTTPBody:[queryString dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Optionally, set HTTP headers
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"Bearer YourAccessToken" forHTTPHeaderField:@"Authorization"];
    
    // Optionally, set a timeout interval (in seconds)
    [request setTimeoutInterval:70.0]; // 30 seconds
    
    // Create a URL session and data task to send the request and handle the response
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
                                                completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
            handler(nil, error);
        } else {
            // Deserialize accessToken string
            NSString *accessToken = [self deserializeAccessTokenData:data];
            handler(accessToken, error);
        }
    }];
    
    // Start the data task to send the request
    [dataTask resume];
}

- (NSString *)deserializeAccessTokenData:(NSData *)data {
    // Deserialize NSData to NSDictionary
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:&error];
    if (error) {
        NSLog(@"Error deserializing JSON data: %@", error);
        return nil;
    } else {
        // Successfully
        return jsonDictionary[@"access_token"];
    }
}



@end
