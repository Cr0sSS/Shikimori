//
//  AAAnimeSimilar.h
//  Shikimori
//
//  Created by Admin on 08.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAnimeSimilar : NSObject

@property (strong, nonatomic) NSString *animeID;

- (id)initWithServerResponce:(NSDictionary*) responseObject;

@end
