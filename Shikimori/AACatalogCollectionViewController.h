//
//  AACollectionViewController.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AACatalogCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) NSString* order;
@property (strong, nonatomic) NSString* status;

- (void) getAnimeCatalogFromServer;

@end
