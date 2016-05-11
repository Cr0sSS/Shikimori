//
//  AAServerManager.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAServerManager.h"

@interface AAServerManager()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) AAAnimeProfile *profile;
@property (strong, nonatomic) NSMutableArray *catalog;
@property (strong, nonatomic) NSMutableArray *similar;
@property (strong, nonatomic) NSMutableArray *related;
@property (strong, nonatomic) NSMutableArray *calendar;

@end

NSUInteger maxSimilarAnimeCountInArray = 6;

@implementation AAServerManager

+(AAServerManager*) shareManager {
    
    static AAServerManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AAServerManager alloc] init];
    });
    
    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        NSURL *url = [NSURL URLWithString:@"http://shikimori.org/api/"];
        
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    }
    
    return self;
}

- (void)getAnimeCatalog:(NSInteger) page
                  limit:(NSInteger) batchSize
                  order:(NSString*) order
                 status:(NSString*) status
              onSuccess:(void(^)(NSArray *anime)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(batchSize),       @"limit",
                            @(page),            @"page",
                            order,              @"order",
                            status,             @"status",
                            nil];
    
    [self.sessionManager GET:@"animes"
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        self.catalog = [NSMutableArray array];
                        
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeCatalog *anime = [[AAAnimeCatalog alloc] initWithServerResponce:dict];
                            [self.catalog addObject:anime];
                        }
                        
                        [self.catalog removeLastObject];
                        
                        if (success) {
                            success(self.catalog);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(error, error.code);
                        }
                    }];
}

- (void)getAnimeProfile:(NSString*) idAnime
              onSuccess:(void(^)(AAAnimeProfile *animeProfile)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            idAnime,           @"id",
                            nil];
    
    [self.sessionManager GET:[NSString stringWithFormat:@"animes/%@", idAnime]
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        self.profile = [[AAAnimeProfile alloc] initWithServerResponce:responseObject];
                        
                        if (success) {
                            success(self.profile);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(error, error.code);
                        }
                    }];
}

- (void)getAnimeSimilar:(NSString*) idAnime
              onSuccess:(BOOL(^)(NSArray *animeSimilar)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            idAnime,           @"id",
                            nil];
    [self.sessionManager GET:[NSString stringWithFormat:@"animes/%@/similar", idAnime]
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        self.similar = [NSMutableArray array];
                        
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeSimilar *animeSimilar = [[AAAnimeSimilar alloc] initWithServerResponce:dict];
                            if ([self.similar count] < maxSimilarAnimeCountInArray) {
                                [self.similar addObject:animeSimilar];
                            }
                        }
                        
                        if (success) {
                            success(self.similar);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(error, error.code);
                        }
                    }];
}

- (void)getAnimeRelated:(NSString*) idAnime
              onSuccess:(BOOL(^)(NSArray *animeRelated)) success
              onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            idAnime,           @"id",
                            nil];
    [self.sessionManager GET:[NSString stringWithFormat:@"animes/%@/related", idAnime]
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        self.related = [NSMutableArray array];
                        
                        for (NSDictionary *dict in responseObject) {
                            if (![[dict objectForKey:@"anime"] isEqual:[NSNull null]]) {
                                AAAnimeRelated *animeRelated = [[AAAnimeRelated alloc] initWithServerResponce:dict];
                                
                                [self.related addObject:animeRelated];
                            }
                        }
                        
                        if (success) {
                            success(self.related);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(error, error.code);
                        }
                    }];
}

- (void)getAnimeOngoingCalendar:(void(^)(NSArray *animeCalendar)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    [self.sessionManager GET:@"calendar"
                  parameters:nil
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        self.calendar = [NSMutableArray array];
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeCalendar *animeCalendar = [[AAAnimeCalendar alloc] initWithServerResponce:dict];
                            [self.calendar addObject:animeCalendar];
                        }
                        
                        if (success) {
                            success(self.calendar);
                        }
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            failure(error, error.code);
                        }
                    }];
}

@end
