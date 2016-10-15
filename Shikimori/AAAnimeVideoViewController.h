//
//  AAVideoViewController.h
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface AAAnimeVideoViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, WKNavigationDelegate>

@property (strong, nonatomic) NSString *animeID;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
