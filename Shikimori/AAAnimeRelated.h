//
//  AAAnimeRelated.h
//  Shikimori
//
//  Created by Admin on 09.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAnimeRelated : NSObject

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSString *relationRussian;
@property (strong, nonatomic) NSDictionary *anime;

- (id)initWithServerResponce:(NSDictionary*) responseObject;

@end
