//
//  AAAnimeSimilar.m
//  Shikimori
//
//  Created by Admin on 08.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeSimilar.h"

@implementation AAAnimeSimilar

- (id)initWithServerResponce:(NSDictionary*) responseObject
{
    self = [super init];
    if (self) {
        
        self.animeID = [responseObject objectForKey:@"id"];
    }
    return self;
}


@end
