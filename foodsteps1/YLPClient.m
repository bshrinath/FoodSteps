//
//  YLPClient.m
//  Pods
//
//

#import <Foundation/Foundation.h>
#import "YLPClient.h"

NSString *const kYLPAPIHost = @"api.yelp.com";
NSString *const kYLPErrorDomain = @"com.yelp.YelpAPI.ErrorDomain";

@implementation YLPClient

- (instancetype)initWithConsumerKey:(NSString *)consumerKey
                     consumerSecret:(NSString *)consumerSecret
                              token:(NSString *)token
                        tokenSecret:(NSString *)tokenSecret {
    
    if (self = [super init]) {
        consumerKey = @"8vMNobOnV6aZiz4LhAdYrQ";;
        consumerSecret = @"ZwtTjJnqrKwmTvZqvKDOf27dtM4";
        token = @"hszNPzEQRDijCFZFpfmKOGtdnXDBZAs8";;
        tokenSecret = @"cy3O5inOg5419sfnszTkuoXWCG0";
    }
    return self;
}

- (void)queryWithRequest:(NSURLRequest *)request
       completionHandler:(void (^)(NSDictionary *jsonResponse, NSError *error))completionHandler {
    
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSDictionary *responseJSON;
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        // This case handles cases where the request was processed by the API, thus
        // resulting in a JSON object being passed back into `data`.
        if (!error) {
            responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        
        if (!error && httpResponse.statusCode == 200) {
            completionHandler(responseJSON, nil);
        } else {
            // If a request fails due to systematic errors with the API then an NSError will be returned.
            error = error ? error : [NSError errorWithDomain:kYLPErrorDomain code:httpResponse.statusCode userInfo:responseJSON];
            completionHandler(nil, error);
        }
    }] resume];
}

@end
