//
//  AAServerManager.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAServerManager.h"
#import "AACatalogCollectionViewController.h"
#import "SVProgressHUD.h"

@interface AAServerManager()

@property (strong, nonatomic) AFHTTPSessionManager *sessionManager;
@property (strong, nonatomic) AAAnimeProfile *animeProfile;
@property (strong, nonatomic) NSMutableArray *animeListArray;
@property (strong, nonatomic) NSMutableArray *animeSimilarArray;
@property (strong, nonatomic) NSMutableArray *animeRelatedArray;
@property (strong, nonatomic) NSMutableArray *animeCalendarArray;
@property (strong, nonatomic) AACatalogCollectionViewController *catalogCollectionController;


@end

NSUInteger maxSimilarAnimeCountInArray = 10;

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

- (void)getAnimeList:(NSInteger) page
                count:(NSInteger) limit
                order:(NSString*) order
               status:(NSString*) status
            onSuccess:(void(^)(NSArray *anime)) success
            onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @(limit),           @"limit",
                            @(page),            @"page",
                            order,              @"order",
                            status,             @"status",
                            nil];
    
    [self.sessionManager GET:@"animes"
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        self.animeListArray = [NSMutableArray array];
                       
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeCatalog *animeList = [[AAAnimeCatalog alloc] initWithServerResponce:dict];
                            [self.animeListArray addObject:animeList];
                            
                        }
                        
                        [self.animeListArray removeLastObject];
                        
                        if (success) {
                            success(self.animeListArray);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                            message:@"Не удалось подключиться к серверу. Попробовать еще раз?"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"Нет"
                                                                  otherButtonTitles:@"Да", nil];
                            [alert show];
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
 
                        self.animeProfile = [[AAAnimeProfile alloc] initWithServerResponce:responseObject];
                        
                        if (success) {
                            success(self.animeProfile);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                            message:@"Не удалось подключиться к серверу"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
}

- (void)getAnimeSimilar:(NSString*) idAnime
               onSuccess:(void(^)(NSArray *animeSimilar)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            idAnime,           @"id",
                            nil];
    [self.sessionManager GET:[NSString stringWithFormat:@"animes/%@/similar", idAnime]
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        self.animeSimilarArray = [NSMutableArray array];
                        
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeSimilar *animeSimilar = [[AAAnimeSimilar alloc] initWithServerResponce:dict];
                            if ([self.animeSimilarArray count] < maxSimilarAnimeCountInArray) {
                                [self.animeSimilarArray addObject:animeSimilar];
                            }
                        }
                        
                        if (success) {
                            success(self.animeSimilarArray);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                            message:@"Не удалось подключиться к серверу"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                        
                    }];
}

- (void)getAnimeRelated:(NSString*) idAnime
               onSuccess:(void(^)(NSArray *animeRelated)) success
               onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                            idAnime,           @"id",
                            nil];
    [self.sessionManager GET:[NSString stringWithFormat:@"animes/%@/related", idAnime]
                  parameters:params
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        self.animeRelatedArray = [NSMutableArray array];
                        
                        for (NSDictionary *dict in responseObject) {
                            if (![[dict objectForKey:@"anime"] isEqual:[NSNull null]]) {
                                AAAnimeRelated *animeRelated = [[AAAnimeRelated alloc] initWithServerResponce:dict];
                                
                                [self.animeRelatedArray addObject:animeRelated];
                            }
                        }
                        
                        if (success) {
                            success(self.animeRelatedArray);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                            message:@"Не удалось подключиться к серверу"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
}

- (void)getAnimeOngoingCalendar:(void(^)(NSArray *animeCalendar)) success
                      onFailure:(void(^)(NSError* error, NSInteger statusCode)) failure {
    
    [self.sessionManager GET:@"calendar"
                  parameters:nil
                    progress:^(NSProgress * _Nonnull downloadProgress) {
                        
                    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        self.animeCalendarArray = [NSMutableArray array];
                        NSLog(@"%@", responseObject);
                        for (NSDictionary *dict in responseObject) {
                            AAAnimeCalendar *animeCalendar = [[AAAnimeCalendar alloc] initWithServerResponce:dict];
                            [self.animeCalendarArray addObject:animeCalendar];
                        }
                        
                        if (success) {
                            success(self.animeCalendarArray);
                        }
                        
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                        if (failure) {
                            NSLog(@"Error: %@", error);
                            [SVProgressHUD dismiss];
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                            message:@"Не удалось подключиться к серверу"
                                                                           delegate:self
                                                                  cancelButtonTitle:@"OK"
                                                                  otherButtonTitles:nil];
                            [alert show];
                        }
                    }];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Да"]) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setItemSize:CGSizeMake(139, 200)];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
        self.catalogCollectionController = [[AACatalogCollectionViewController alloc] initWithCollectionViewLayout:flowLayout];
        [self.catalogCollectionController getAnimeListFromServer];
    }
}

@end
