//
//  AAAnimeRelated.m
//  Shikimori
//
//  Created by Admin on 09.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeRelated.h"

@implementation AAAnimeRelated

- (id)initWithServerResponce:(NSDictionary*) responseObject {
    if (self) {
        self.relationRussian = [responseObject objectForKey:@"relation_russian"];
        self.anime = [responseObject objectForKey:@"anime"];
        self.animeID = [self.anime objectForKey:@"id"];
    }
    return self;
}

@end
