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
#import "AppDelegate.h"
#import <Cordova/CDVAvailability.h>
#import <Foundation/NSJSONSerialization.h>
#import "KeyValue.h"
#import<Cordova/CDVJson.h>

#import "OAuth2Plugin.h"


@interface OAuth2Plugin ()

@end

@implementation OAuth2Plugin

@synthesize customAppKey, customAppSecret, serviceName, keychainName, authUrl, tokenUrl, redirectUrl;
@synthesize auth = mAuth;



- (NSString*)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}



- (void)pluginInitialize
{
    // SETTINGS ////////////////////////

    NSString* setting = nil;

    setting = @"CustomAppKey";
    if ([self settingForKey:setting]) {
        self.customAppKey = [self settingForKey:setting];
    }
    
    setting = @"CustomAppSecret";
    if ([self settingForKey:setting]) {
        self.customAppSecret = [self settingForKey:setting];
    }

    setting = @"serviceName";
    if ([self settingForKey:setting]) {
        self.serviceName = [self settingForKey:setting];
    }

    setting = @"keychainName";
    if ([self settingForKey:setting]) {
        self.keychainName = [self settingForKey:setting];
    }

    setting = @"authUrl";
    if ([self settingForKey:setting]) {
        self.authUrl = [self settingForKey:setting];
    }

    setting = @"tokenUrl";
    if ([self settingForKey:setting]) {
        self.tokenUrl = [self settingForKey:setting];
    }

    setting = @"redirectUrl";
    if ([self settingForKey:setting]) {
        self.redirectUrl = [self settingForKey:setting];
    }

    
    
    
    

    // Get the saved authentication, if any, from the keychain.
    
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:@"Writing App Online"
                                                             tokenURL:[NSURL URLWithString:self.tokenUrl]
                                                          redirectURI:self.redirectUrl
                                                             clientID:customAppKey
                                                         clientSecret:customAppSecret];
   
    BOOL didAuth = [GTMOAuth2ViewControllerTouch authorizeFromKeychainForName:self.keychainName
                                                                   authentication:auth
                                                                            error:NULL];
    

    // Retain the authentication object, which holds the auth tokens
    //
    // We can determine later if the auth object contains an access token
    // by calling its -canAuthorize method
    self.auth= auth;
    
    
}

- (GTMOAuth2Authentication *)authForCustomService {
    
    NSURL *tokenURL = [NSURL URLWithString:self.tokenUrl];
    
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2Authentication authenticationWithServiceProvider:self.serviceName
                                                             tokenURL:tokenURL
                                                          redirectURI:self.redirectUrl
                                                             clientID:customAppKey
                                                         clientSecret:customAppSecret];
    return auth;
}





- (void)signInToCustomService:(CDVInvokedUrlCommand*)command {
    [self signOut: command];
    
    GTMOAuth2Authentication *auth = [self authForCustomService];
    
    // Specify the appropriate scope string, if any, according to the service's API documentation
    auth.scope = @"read";
    
    NSURL *authURL = [NSURL URLWithString:self.authUrl];
    
    // Display the authentication view
    GTMOAuth2ViewControllerTouch *viewController;
    
    SEL sel = @selector(viewController:finishedWithAuth:error:);

    viewController = [GTMOAuth2ViewControllerTouch controllerWithAuthentication:auth
                                                               authorizationURL:authURL
                                                               keychainItemName:self.keychainName
                                                                       delegate:self
                                                               finishedSelector:sel];

    viewController.webView.backgroundColor = [UIColor greenColor];
    // Now push our sign-in view
    
    viewController.popViewBlock=^{
        [self.viewController dismissViewControllerAnimated:viewController completion:nil];
    };
    
    viewController.modalPresentationStyle = UIModalPresentationFormSheet;
    [self.viewController presentViewController:viewController animated:YES completion:nil];
    
    
}


- (void)signOut:(CDVInvokedUrlCommand*)command {
    
    // remove the stored DailyMotion authentication from the keychain, if any
    [GTMOAuth2ViewControllerTouch removeAuthFromKeychainForName:self.keychainName];
    
    // Discard our retained authentication object.
    self.auth = nil;
}


- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString *str = [[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding];
            NSLog(@"%@", str);
        }
        
        self.auth = nil;
    } else {
        NSLog(@"Authentication succeeded");
        
        NSLog(@"Access token is %@", auth.accessToken);
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //  [auth authorizeRequest:myNSURLMutableRequest
        //       completionHandler:^(NSError *error) {
        //         if (error == nil) {
        //           // request here has been authorized
        //         }
        //       }];
        //
        // or store the authentication object into a fetcher or a Google API service
        // object like
        //
        //   [fetcher setAuthorizer:auth];
        
        // save the authentication object
        self.auth = auth;
    }
    
  //  [self updateUI];
}

// //////////////////////////////////////////////////

- (void)dealloc
{

}

// //////////////////////////////////////////////////

#pragma Plugin interface

- (void) getStatus:(CDVInvokedUrlCommand*)command
{
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"OK"] callbackId:command.callbackId];
}



@end
