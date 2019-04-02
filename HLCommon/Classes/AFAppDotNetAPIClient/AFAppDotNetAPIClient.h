//
//  AFAppDotNetAPIClient.h
//
//  Created by hoolink on 19/3/12.
//  Copyright (c) 2019年 hoolink. All rights reserved.
//

#import "AFHTTPSessionManager.h"

typedef void (^HTTPRequestFinishingHandler)(NSDictionary *result, NSError *error);

typedef void (^HTTPRequestFailedHandler)(NSError *error);

@interface AFAppDotNetAPIClient : AFHTTPSessionManager

+ (void)getAsynchronous:(NSString *)path
              parameter:(NSDictionary *)dic
           successBlock:(HTTPRequestFinishingHandler)successBlock
             errorBlock:(HTTPRequestFailedHandler) errorBlock;


+ (void)postAsynchronous:(NSString *)path
               parameter:(id)dic
            successBlock:(HTTPRequestFinishingHandler)successBlock
              errorBlock:(HTTPRequestFailedHandler) errorBlock;

- (void) postImage:(NSString *)path image:(UIImage *) picture
      successBlock:(HTTPRequestFinishingHandler)successBlock
        errorBlock:(HTTPRequestFailedHandler) errorBlock;

@end
