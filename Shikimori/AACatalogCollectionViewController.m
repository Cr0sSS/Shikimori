//
//  AACollectionViewController.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AACatalogCollectionViewController.h"
#import "AAServerManager.h"
#import "AACatalogCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "AAAnimeProfileViewController.h"
#import "SVProgressHUD.h"
#import "SWRevealViewController.h"
#import "RWDropdownMenu.h"

@interface AACatalogCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *animes;
@property (strong, nonatomic) NSMutableArray *addCell;
@property (strong, nonatomic) UIImage *placeholder;
@property (assign, nonatomic) BOOL loadingCell;
@property (strong, nonatomic) UIButton *titleButton;

@end

@implementation AACatalogCollectionViewController

static NSInteger batchSize = 30;
static NSInteger pageInRequest = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pageInRequest = 0;
    self.animes = [NSMutableArray array];
    self.loadingCell = YES;
    
    [self getAnimeCatalogFromServer];
    
    SWRevealViewController *revealController = [self revealViewController];
    
    [revealController panGestureRecognizer];
    [revealController tapGestureRecognizer];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:25/255.0 green:181/255.0 blue:254/255.0 alpha:1];
    
    UIBarButtonItem *revealButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nav_menu"] style:UIBarButtonItemStylePlain target:revealController action:@selector(revealToggle:)];
    [self.navigationController.navigationBar.topItem setLeftBarButtonItem:revealButtonItem];
    [revealButtonItem setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *searchButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchController)];
    [self.navigationController.navigationBar.topItem setRightBarButtonItem:searchButtonItem];
    [searchButtonItem setTintColor:[UIColor whiteColor]];
    
    self.titleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.titleButton.frame = CGRectMake(0, 0, self.navigationController.navigationBar.bounds.size.width / 1.5, 28);
    [self.titleButton setTitle:@"По рейтингу" forState:UIControlStateNormal];
    [self.titleButton setImage:[[UIImage imageNamed:@"arrow_down_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.titleButton addTarget:self action:@selector(showMenu:) forControlEvents:UIControlEventTouchUpInside];
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, self.titleButton.imageView.bounds.size.width / 2, 0, 0);
    
    UIView *titleView = [[UIView alloc] init];
    titleView.frame = CGRectMake(0, 0, self.navigationController.navigationBar.bounds.size.width / 1.5, 28);
    [titleView addSubview:self.titleButton];
    self.navigationItem.titleView = titleView;
    
    self.titleButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.titleButton.titleLabel.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    self.titleButton.imageView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    
    if (IS_IPAD) {
        self.titleButton.titleLabel.font =  [UIFont fontWithName:@"Copperplate" size:24.0];
    } else {
        self.titleButton.titleLabel.font =  [UIFont fontWithName:@"Copperplate" size:18.0];
    }
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background.jpg"]];
    self.collectionView.backgroundView = tempImageView;
    
    UIBlurEffect *backgroundblurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundBlurEffectView = [[UIVisualEffectView alloc] initWithEffect:backgroundblurEffect];
    backgroundBlurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [backgroundBlurEffectView setFrame:self.collectionView.frame];
    [tempImageView addSubview:backgroundBlurEffectView];
    
    self.placeholder = [UIImage imageNamed:@"imageholder"];
    
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.minimumLineSpacing = 8;
    layout.minimumInteritemSpacing = 0;
    layout.sectionInset = UIEdgeInsetsMake(8, 8, 8, 8);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.collectionView reloadData];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.collectionView reloadData];
}

#pragma mark - API Methods

- (void) getAnimeCatalogFromServer {
    
    [SVProgressHUD show];
    
    [[AAServerManager shareManager] getAnimeCatalog:pageInRequest = pageInRequest + 1
                                              limit:batchSize
                                              order:self.order
                                             status:self.status
                                          onSuccess:^(NSArray *anime) {
                                              [self.animes addObjectsFromArray:anime];
                                              self.addCell = [NSMutableArray array];
                                              
                                              for (int i = (int)[self.animes count] - (int)[anime count]; i < [self.animes count]; i++) {
                                                  [self.addCell addObject:[NSIndexPath indexPathForRow:i inSection:0]];
                                              }
                                              
                                              self.loadingCell = NO;
                                              [self.collectionView reloadData];
                                              [SVProgressHUD dismiss];
                                          }
                                          onFailure:^(NSError *error, NSInteger statusCode) {
                                              [SVProgressHUD dismiss];
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                                              message:@"Не удалось получить данные. Попробовать еще раз?"
                                                                                             delegate:self
                                                                                    cancelButtonTitle:@"Нет"
                                                                                    otherButtonTitles:@"Да", nil];
                                              [alert show];
                                          }];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.animes count];
}

- (AACatalogCollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const reuseIdentifier = @"Cell";
    AACatalogCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[AACatalogCollectionViewCell alloc] init];
    }
    
    AAAnimeCatalog *anime = [self.animes objectAtIndex:indexPath.row];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://shikimori.org%@", anime.imageURL]]];
    __weak AACatalogCollectionViewCell* weakCell = cell;
    
    [cell.imageView
     setImageWithURLRequest:request
     placeholderImage:self.placeholder
     success:^(NSURLRequest * request, NSHTTPURLResponse *response, UIImage *image) {
         weakCell.imageView.image = image;
         [weakCell layoutSubviews];
     } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
         NSLog(@"%@", error);
     }];
    
    cell.textLabel.text = anime.russian;
    
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderWidth = 1.0f;
    cell.layer.borderColor = [UIColor grayColor].CGColor;
    cell.layer.cornerRadius = 6.0f;
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float column = 0.0f;
    float section = 0.0f;
    
    if (IS_IPAD) {
        if (IS_IPAD_PRO) {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                column = 5.0f;
                section = 2.4f;
            } else {
                column = 4.0f;
                section = 3.6f;
            }
        } else {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                column = 4.0f;
                section = 2.1f;
            } else {
                column = 3.0f;
                section = 2.8f;
            }
        }
    } else {
        if (IS_IPHONE_6P) {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                column = 4.0f;
                section = 1.5f;
            } else {
                column = 2.0f;
                section = 2.5f;
            }
        } else if (IS_IPHONE_4_OR_LESS) {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                column = 3.0f;
                section = 1.4f;
            } else {
                column = 2.0f;
                section = 2.1f;
            }
        } else {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeRight) {
                column = 4.0f;
                section = 1.5f;
            } else {
                column = 2.0f;
                section = 2.5f;
            }
        }
    }
    
    CGFloat width = (CGRectGetWidth(collectionView.bounds)-8*(column+1))/column;
    CGFloat height = (CGRectGetHeight(collectionView.bounds)-8*(section+1))/section;
    CGSize size = CGSizeMake (width, height);
    return size;
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ((scrollView.contentOffset.y + scrollView.frame.size.height) >= scrollView.contentSize.height - 20) {
        if (!self.loadingCell) {
            [self getAnimeCatalogFromServer];
            self.loadingCell = YES;
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if([title isEqualToString:@"Да"]) {
        pageInRequest = pageInRequest - 1;
        [self getAnimeCatalogFromServer];
    }
}

#pragma mark - Navigation Methods

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
    
    if ([[segue identifier] isEqualToString:@"profile"]) {
        
        AAAnimeCatalog *anime = [self.animes objectAtIndex:indexPath.row];
        AAAnimeProfileViewController *destination1 = [segue destinationViewController];
        destination1.animeID = anime.animeID;
    }
}

- (void)showSearchController {
    UIViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)showMenu:(id)sender {
    NSAttributedString *(^attributedTitle)(NSString *title) = ^NSAttributedString *(NSString *title) {
        UIColor *textColor = [UIColor lightTextColor];
        
        if (IS_IPAD) {
            return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"Copperplate" size:24.0f]}];
            
        } else {
            return [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont fontWithName:@"Copperplate" size:18.0f]}];
        }
    };
    NSArray *styleItems =
    @[
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По рейтингу") image:nil action:^{
          
          [self.titleButton setTitle:@"По рейтингу" forState:UIControlStateNormal];
          
          self.order = @"ranked";
          [self.animes removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По популярности") image:nil action:^{
          
          [self.titleButton setTitle:@"По популярности" forState:UIControlStateNormal];
          
          self.order = @"popularity";
          [self.animes removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      [RWDropdownMenuItem itemWithAttributedText:attributedTitle(@"По дате выхода") image:nil action:^{
          
          [self.titleButton setTitle:@"По дате выхода" forState:UIControlStateNormal];
          
          self.order = @"aired_on";
          [self.animes removeAllObjects];
          pageInRequest = 0;
          [self getAnimeCatalogFromServer];
      }],
      ];
    
    [RWDropdownMenu presentFromViewController:self withItems:styleItems align:RWDropdownMenuCellAlignmentCenter style:0 navBarImage:nil completion:nil];
}

@end
