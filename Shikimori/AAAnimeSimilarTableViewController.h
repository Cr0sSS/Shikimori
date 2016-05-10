//
//  AASimilarPopUpTableViewController.h
//  Shikimori
//
//  Created by Admin on 08.04.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAnimeSimilarTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSString *animeID;
@property (strong, nonatomic) NSMutableArray *similar;
@property (strong, nonatomic) NSMutableArray *similarProfile;
@property (strong, nonatomic) NSMutableArray *genres;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
