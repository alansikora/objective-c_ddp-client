//
//  DDPClient.h
//  DDPClient v0.5.0
//
//  Created by Alan Sikora on 6/25/12.
//  Copyright (c) 2012 Bojo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SRWebSocket.h"

@protocol DDPClientDelegate <NSObject>

@optional
- (void)onOpen: (NSDictionary*)message_dictionary;

@optional
- (void)onConnect: (NSDictionary*)message_dictionary;

@optional
- (void)onData: (NSDictionary*)message_dictionary;

@optional
- (void)onResult: (NSDictionary*)message_dictionary;

@optional
- (void)onNoSub: (NSDictionary*)message_dictionary;

@optional
- (void)onError: (NSDictionary*)message_dictionary;

@end

@interface DDPClient : NSObject <SRWebSocketDelegate> {
    id <DDPClientDelegate>delegate;
    int* current_id;
    NSDictionary* identifiers;
    NSString* socket_url;
    SRWebSocket* socket;
}

@property (nonatomic, retain) id <DDPClientDelegate>delegate;
@property int* current_id;
@property (retain) NSDictionary* identifiers;
@property (retain) NSString* socket_url;
@property (retain) SRWebSocket* socket;

-(id)initWithHostnameAndPortAndUrl: (NSString*)hostname andPort:(int)port andUrl:(NSString*)url;
-(id)initWithHostnameAndPort: (NSString*)hostname andPort:(int)port;

-(void)connect;
-(void)send: (NSDictionary*)message_dictionary;
-(void)call: (NSString*)identifier withMethodName:(NSString*)method andParams:(NSArray*)params_array;
-(void)call: (NSString*)identifier withMethodName:(NSString*)name;
-(void)subscribe: (NSString*)identifier withSubscriptionName:(NSString*)name andParams:(NSArray*)params_array;
-(void)subscribe: (NSString*)identifier withSubscriptionName:(NSString*)name;

@end
