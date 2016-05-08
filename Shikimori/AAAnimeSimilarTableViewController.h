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
@property (strong, nonatomic) NSMutableArray *animeSimilarArray;
@property (strong, nonatomic) NSMutableArray *animeSimilarProfileArray;
@property (strong, nonatomic) NSMutableArray *genresStringArray;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
