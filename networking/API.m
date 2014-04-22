//
//  API.m
//  networking
//
//  Created by Rodney Degracia on 4/21/14.
//  Copyright (c) 2014 Venture Intellectual LLC. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


#import "API.h"

@implementation API


+ (void)basicAuthorizationWithEmail:(NSString*)email andPassword:(NSString*)password version:(NSString*)version urlString:(NSString*)urlString completion:(APICompletionBlock)completion {
    
    NSString *cookedVersion = [NSString stringWithFormat:@"version=%@", version];
    NSData *requestData = [NSData dataWithBytes:[cookedVersion UTF8String] length:[cookedVersion length]];
    
    NSString *authString = [[[NSString stringWithFormat:@"%@:%@", email, password] dataUsingEncoding:NSUTF8StringEncoding] base64Encoding];
    authString = [NSString stringWithFormat: @"Basic %@", authString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        completion(data, response, error);

    }] resume];
    
}


+ (void)deleteResource:(NSString *)urlString completion:(APICompletionBlock)completion
{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[API timeOutInterval]];
    [request setHTTPMethod:@"DELETE"];
    
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        completion(data, response, error);
        
    }] resume];
    
}

+ (void)requestGET:(NSString *)urlString completion:(APICompletionBlock)completion
{
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[API timeOutInterval]];
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        completion(data, response, error);
        
    }] resume];
}


+ (void)postResource:(NSString*)urlString postbody:(NSMutableData*)postBody completion:(APICompletionBlock)completion {
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[API headerBoundary] forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postBody];
    [request setTimeoutInterval:[API timeOutInterval]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        completion(data, response, error);
        
    }] resume];
}

+ (NSInteger)timeOutInterval {
    return 90;
}

+ (NSString*)stringBoundary {
    return  @"0xUIwSUBnxXsYsP---syw";
}

+ (NSString*)headerBoundary {
    
    return [NSString stringWithFormat:@"multipart/form-data; boundary=%@", [API stringBoundary]];
}

+ (NSData*)postBodyFromDictionary:(NSDictionary*)parameterDictionary withImage:(NSData*)imageData {
    
    NSMutableData* postBody = [NSMutableData data];
    
    // form
    for (NSString* aKey in parameterDictionary) {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", [API stringBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", aKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[[parameterDictionary objectForKey:aKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if ([imageData length] > 0)
    {
        [postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", [API stringBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Disposition: form-data; name=\"media\"; filename=\"snap.png\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Type: image/png\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:[@"Content-Transfer-Encoding: binary\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [postBody appendData:imageData];
        [postBody appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", [API stringBoundary]] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return postBody;
    
}


@end
