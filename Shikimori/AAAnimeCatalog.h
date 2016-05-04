//
//  AAAnimeList.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAnimeCatalog : NSObject

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *russian;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSString *imageURL;
@property (strong, nonatomic) NSString *kind;
@property (strong, nonatomic) NSString *ongoing;
@property (strong, nonatomic) NSString *anons;
@property (strong, nonatomic) NSString *status;
@property (assign, nonatomic) NSString *episodes;
@property (assign, nonatomic) NSString *episodesAired;

- (id)initWithServerResponce:(NSDictionary*) responseObject;

@end
