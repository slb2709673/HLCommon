//
//  AFAppDotNetAPIClient.m
//
//  Created by hoolink on 19/3/12.
//  Copyright (c) 2019年 hoolink. All rights reserved.
//

#import "AFAppDotNetAPIClient.h"



@interface AFAppDotNetAPIClient ()

+ (instancetype)sharedClient;

@end

@implementation AFAppDotNetAPIClient

+ (instancetype)sharedClient {
    
    static dispatch_once_t once;
    static AFAppDotNetAPIClient *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[self alloc] initWithBaseURL:nil];
    });
    return sharedView;
}

- (instancetype)initWithBaseURL:(NSURL *)url {
    
    self = [super initWithBaseURL:url];
    if (self) {
        self.requestSerializer.timeoutInterval = 30.0;
//        [self.requestSerializer setValue:@"iOS" forHTTPHeaderField:@"teminalType"];
//        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"osType"];//ios version
//        [self.requestSerializer setValue:@"iPhone" forHTTPHeaderField:@"deviceModel"];//
//        [self.requestSerializer setValue:@"" forHTTPHeaderField:@"deviceSerial"];//uuid
    }
    return self;
}

+ (void)getAsynchronous:(NSString *)path
              parameter:(NSDictionary *)dic
           successBlock:(HTTPRequestFinishingHandler)successBlock
             errorBlock:(HTTPRequestFailedHandler)errorBlock {
    
    [[self sharedClient] GET:path parameters:dic progress:nil
                     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                         
                         NSDictionary *dict = [[self sharedClient]
                                               dataOrStringToDictionary:responseObject];
                         
                         if (dict) {
                             
                             successBlock(dict,nil);
                         }
                         
                     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                         
                         errorBlock(error);
                     }];
}

+ (void)postAsynchronous:(NSString *)path
               parameter:(id)dic
            successBlock:(HTTPRequestFinishingHandler)successBlock
              errorBlock:(HTTPRequestFailedHandler)errorBlock {
    
    [[self sharedClient] POST:path parameters:dic progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                          
                          NSDictionary *dict = [[self sharedClient]
                                                dataOrStringToDictionary:responseObject];
                          
                          if (dict) {
                              
                              successBlock(dict,nil);
                              
                          }else {
                              errorBlock(nil);
                          }
                          
                      } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                          
                          errorBlock(error);
                      }];
}

- (NSDictionary *)dataOrStringToDictionary:(id)object {
    
    if ([object isKindOfClass:[NSData class]]) {
        
        return [self dataToDictionary:object];
        
    }else if ([object isKindOfClass:[NSString class]]) {
        
        NSData *data = [object dataUsingEncoding:NSUTF8StringEncoding];
        
        return [self dataToDictionary:data];
        
    }else if ([object isKindOfClass:[NSDictionary class]]) {
        
        return (NSDictionary *)object;
    }
    
    return nil;
}

- (NSDictionary *)dataToDictionary:(NSData *)date {
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:date
                                                         options:NSJSONReadingMutableContainers
                                                           error:&error];
    return dict;
}

- (NSString *)dataTOjsonString:(id)object {
    
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if ( !jsonData ) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


- (void) postImage:(NSString *)path image:(UIImage *) picture successBlock:(HTTPRequestFinishingHandler)successBlock
        errorBlock:(HTTPRequestFailedHandler) errorBlock {
    NSData *imageData = UIImageJPEGRepresentation(picture, 0.0001);
    NSString *url = [NSString stringWithFormat:@"%@%@",@"", path];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString: url parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"fileName.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    [self uploadTaskWithRequest:request fromData:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        NSLog(@"%f",uploadProgress.fractionCompleted);
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error: %@", error);
            if (errorBlock) {
                errorBlock(nil);
            }
        } else {
            NSLog(@"%@ %@", response, responseObject);
            if (successBlock) {
                successBlock(responseObject, nil);
            }
        }
    }];
}


@end
