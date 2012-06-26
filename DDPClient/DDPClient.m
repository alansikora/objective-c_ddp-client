//
//  DDPClient.m
//  DDPClient v0.5.0
//
//  Created by Alan Sikora on 6/25/12.
//  Copyright (c) 2012 Bojo. All rights reserved.
//

#import "DDPClient.h"
#import "SBJson.h"

@implementation DDPClient

@synthesize delegate;
@synthesize current_id;
@synthesize identifiers;
@synthesize socket;
@synthesize socket_url;

-(id)initWithHostnameAndPortAndUrl: (NSString*)hostname andPort:(int)port andUrl:(NSString*)url
{
    if (self = [super init])
    {
        socket_url = [NSString stringWithFormat:@"ws://%@:%i/%@", hostname, port, url];
    }
    return self;
}

-(id)initWithHostnameAndPort: (NSString*)hostname andPort:(int)port
{
    return [self initWithHostnameAndPortAndUrl:hostname andPort:port andUrl:@"websocket"];
}

-(void)connect
{
    socket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:socket_url]]];
    socket.delegate = self;
    
    [socket open];
}

-(void)send: (NSDictionary*)message_dictionary
{
    NSString* message_string = message_dictionary.JSONRepresentation;
    
    [socket send:message_string];
}

-(void)call: (NSString*)identifier withMethodName:(NSString*)method andParams:(NSArray*)params_array
{
    [self send: [NSDictionary dictionaryWithObjectsAndKeys: 
                 @"method", @"msg", 
                 method, @"method", 
                 identifier, @"id", 
                 params_array, @"params", 
                 nil]];
}

-(void)call: (NSString*)identifier withMethodName:(NSString*)name
{
    [self call:name withMethodName:name andParams:nil];
}

-(void)subscribe: (NSString*)identifier withSubscriptionName:(NSString*)name andParams:(NSArray*)params_array
{
    [self send: [NSDictionary dictionaryWithObjectsAndKeys: 
                 @"sub", @"msg", 
                 name, @"name", 
                 identifier, @"id", 
                 params_array, @"params", 
                 nil]];
}

-(void)subscribe: (NSString*)identifier withSubscriptionName:(NSString*)name
{
    [self subscribe:name withSubscriptionName:name andParams:nil];
}

#pragma mark - SRWebSocketDelegate

- (void)webSocketDidOpen: (SRWebSocket *)webSocket;
{
    [self send: [NSDictionary dictionaryWithObjectsAndKeys: @"connect", @"msg", nil]];
}

- (void)webSocket: (SRWebSocket *)webSocket didFailWithError:(NSError *)error;
{
//    Handle webSocket error
}

-(void)webSocket: (SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSString* message_string = (NSString*)message;
    
    NSDictionary* message_dictionary = (NSDictionary*)message_string.JSONValue;
    
    if([[message_dictionary valueForKey:@"server_id"] length] > 0) {
        [delegate onOpen: message_dictionary];
    }
    
    if([[message_dictionary valueForKey:@"msg"] isEqualToString:@"connected"]) {
        [delegate onConnect: message_dictionary];
    }
    
    if([[message_dictionary valueForKey:@"msg"] isEqualToString:@"data"]) {
        [delegate onData: message_dictionary];
    }
    
    if([[message_dictionary valueForKey:@"msg"] isEqualToString:@"result"]) {
        [delegate onResult: message_dictionary];
    }
    
    if([[message_dictionary valueForKey:@"msg"] isEqualToString:@"nosub"]) {
        [delegate onNoSub: message_dictionary];
    }
    
    if([[message_dictionary valueForKey:@"msg"] isEqualToString:@"error"]) {
        [delegate onError: message_dictionary];
    }
}

- (void)webSocket: (SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean;
{
//    Handle webSocket closed
}

@end
