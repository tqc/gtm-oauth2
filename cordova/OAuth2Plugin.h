/*
 Licensed to the Apache Software Foundation (ASF) under one
 or more contributor license agreements.  See the NOTICE file
 distributed with this work for additional information
 regarding copyright ownership.  The ASF licenses this file
 to you under the Apache License, Version 2.0 (the
 "License"); you may not use this file except in compliance
 with the License.  You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing,
 software distributed under the License is distributed on an
 "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 KIND, either express or implied.  See the License for the
 specific language governing permissions and limitations
 under the License.
 */

#import <Cordova/CDVPlugin.h>

#import "GTMOAuth2SignIn.h"
#import "GTMOAuth2Authentication.h"
#import "GTMHTTPFetcher.h"
#import "GTMOAuth2ViewControllerTouch.h"


@interface OAuth2Plugin : CDVPlugin {

@protected    NSString* _customAppKey;
@protected    NSString* _customAppSecret;
  GTMOAuth2Authentication *mAuth;

}


@property (readwrite, copy) NSString* customAppKey;
@property (readwrite, copy) NSString* customAppSecret;

@property (readwrite, copy) NSString* serviceName;
@property (readwrite, copy) NSString* keychainName;
@property (readwrite, copy) NSString* authUrl;
@property (readwrite, copy) NSString* tokenUrl;
@property (readwrite, copy) NSString* redirectUrl;


@property (nonatomic, retain) GTMOAuth2Authentication *auth;


- (void) getStatus:(CDVInvokedUrlCommand*)command;

- (void) signInToCustomService:(CDVInvokedUrlCommand*)command;
- (void) signOut:(CDVInvokedUrlCommand*)command;

@end
