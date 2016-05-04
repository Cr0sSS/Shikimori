//
//  AAServerManager.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AAAnimeCatalog.h"
#import "AAAnimeProfile.h"
#import "AAAnimeSimilar.h"
#import "AAAnimeRelated.h"
#import "AAAnimeCalendar.h"

@interface AAServerManager : NSObject <UIAlertViewDelegate>

+(AAServerManager*) shareManager;

- (void)getAnimeList:(NSInteger) page
                count:(NSInteger) limit
                order:(NSString*) order
               status:(NSString*) status
            onSuccess:(void(^)(NSArray *anime)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getAnimeProfile:(NSString*) idAnime
            onSuccess:(void(^)(AAAnimeProfile *animeProfile)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getAnimeSimilar:(NSString*) idAnime
            onSuccess:(void(^)(NSArray *animeSimilar)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getAnimeRelated:(NSString*) idAnime
               onSuccess:(void(^)(NSArray *animeRelated)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;

- (void)getAnimeOngoingCalendar:(void(^)(NSArray *animeCalendar)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure;


@end
