//
//  AAVideoViewController.m
//  Shikimori
//
//  Created by Admin on 30.03.16.
//  Copyright © 2016 Arsen Avanesyan. All rights reserved.
//

#import "AAAnimeVideoViewController.h"
#import "TFHpple.h"
#import "AAAnimeVideo.h"
#import "SVProgressHUD.h"

@interface AAAnimeVideoViewController ()

@property (strong, nonatomic) AAAnimeVideo *videoURL;

@end

@implementation AAAnimeVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.scrollView.bounces = NO;
    self.videoVariantArray = [NSMutableArray array];
    self.videoResourceURLArray = [NSMutableArray array];
    self.sourceURL = [NSString stringWithFormat:@"http://play.shikimori.org/animes/%@/video_online", self.animeID];
    
    [self parseVideoEpisode];
    [self parseVideoURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    
//    NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"http:%@\" width=\"%f\" height=\"160\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , self.webView.frame.size.width - 16.0];
//    [self.webView loadHTMLString:htmlString baseURL:nil];
//}

#pragma mark - Parse Methods

- (void) parseVideoEpisode {
    
    [SVProgressHUD show];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    [blurEffectView setFrame:self.view.frame];
    [self.view addSubview:blurEffectView];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        [self.activityIndicator startAnimating];
        
        self.sourceURL = [NSString stringWithFormat:@"http://play.shikimori.org/animes/%@/video_online", self.animeID];
        
        NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
        
        NSString *videoURLXpathQueryString1 = @"//div[@class='c-episodes']/div[@class='video-variant']/a";
        NSString *videoURLXpathQueryString2 = @"//div[@class='c-episodes']/div/div[@class='video-variant']/a";
        
        
        NSArray *videoURLNodes1 = [parser searchWithXPathQuery:videoURLXpathQueryString1];
        NSArray *videoURLNodes2 = [parser searchWithXPathQuery:videoURLXpathQueryString2];
        
        for (TFHppleElement *element in videoURLNodes1) {
            AAAnimeVideo *videoVariant = [[AAAnimeVideo alloc] init];
            [self.videoVariantArray addObject:videoVariant];
            videoVariant.videoVariant = [element objectForKey:@"href"];
        }
        
        for (TFHppleElement *element in videoURLNodes2) {
            AAAnimeVideo *videoVariant = [[AAAnimeVideo alloc] init];
            [self.videoVariantArray addObject:videoVariant];
            videoVariant.videoVariant = [element objectForKey:@"href"];
        }
        
        if ([self.videoVariantArray count] == 0) {
            
            self.sourceURL = [NSString stringWithFormat:@"http://play.shikimori.org/animes/z%@/video_online", self.animeID];
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoURLXpathQueryString1 = @"//div[@class='c-episodes']/div[@class='video-variant']/a";
            NSString *videoURLXpathQueryString2 = @"//div[@class='c-episodes']/div/div[@class='video-variant']/a";
            
            
            NSArray *videoURLNodes1 = [parser searchWithXPathQuery:videoURLXpathQueryString1];
            NSArray *videoURLNodes2 = [parser searchWithXPathQuery:videoURLXpathQueryString2];
            
            for (TFHppleElement *element in videoURLNodes1) {
                AAAnimeVideo *videoVariant = [[AAAnimeVideo alloc] init];
                [self.videoVariantArray addObject:videoVariant];
                videoVariant.videoVariant = [element objectForKey:@"href"];
            }
            
            for (TFHppleElement *element in videoURLNodes2) {
                AAAnimeVideo *videoVariant = [[AAAnimeVideo alloc] init];
                [self.videoVariantArray addObject:videoVariant];
                videoVariant.videoVariant = [element objectForKey:@"href"];
            }
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [SVProgressHUD dismiss];
            [blurEffectView removeFromSuperview];
        });
    });
}


- (void) parseVideoURL {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(queue, ^{
        
        NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
        
        TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
        
        NSString *videoResourceURLXpathQueryString = @"//iframe";
        
        NSArray *videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
        
        for (TFHppleElement *element in videoResourceURLNodes) {
            self.videoURL = [[AAAnimeVideo alloc] init];
            [self.videoResourceURLArray addObject:self.videoURL];
            self.videoURL.videoResourceURL = [element objectForKey:@"src"];
            
            NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"http:%@\" width=\"%f\" height=\"253\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , self.webView.frame.size.width - 16.0];
            [self.webView loadHTMLString:htmlString baseURL:nil];
        }
        
        
        if ([videoResourceURLNodes count] == 0) {
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoResourceURLXpathQueryString = @"//embed";
            
            videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
            
            for (TFHppleElement *element in videoResourceURLNodes) {
                self.videoURL = [[AAAnimeVideo alloc] init];
                [self.videoResourceURLArray addObject:self.videoURL];
                self.videoURL.videoResourceURL = [element objectForKey:@"src"];
                NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"http:%@\" width=\"%f\" height=\"253\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , self.webView.frame.size.width - 16.0];
                [self.webView loadHTMLString:htmlString baseURL:nil];
            }
        }
        
        if ([videoResourceURLNodes count] == 0) {
            
            NSData *sourceHTMLData = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.sourceURL]];
            
            TFHpple *parser = [TFHpple hppleWithHTMLData:sourceHTMLData];
            
            NSString *videoResourceURLXpathQueryString = @"//iframe";
            
            NSArray *videoResourceURLNodes = [parser searchWithXPathQuery:videoResourceURLXpathQueryString];
            
            for (TFHppleElement *element in videoResourceURLNodes) {
                self.videoURL = [[AAAnimeVideo alloc] init];
                [self.videoResourceURLArray addObject:self.videoURL];
                self.videoURL.videoResourceURL = [element objectForKey:@"src"];
                
                NSString* htmlString = [NSString stringWithFormat:@"<iframe src=\"http:%@\" width=\"%f\" height=\"253\" frameborder=\"0\"></iframe>", self.videoURL.videoResourceURL , self.webView.frame.size.width - 16.0];
                [self.webView loadHTMLString:htmlString baseURL:nil];
            }
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [self.activityIndicator stopAnimating];
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(nullable NSError *)error {
    
    [self.activityIndicator stopAnimating];
}

#pragma mark - UITableViewDataSource

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.videoVariantArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * const reuseIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d серия", indexPath.row + 1];
    UIFont *myFont =  [UIFont fontWithName:@"Copperplate" size:14.0];
    cell.textLabel.font  = myFont;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return @"   Эпизоды";
}

#pragma mark UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.activityIndicator startAnimating];
    AAAnimeVideo *videoVariant = [self.videoVariantArray objectAtIndex:indexPath.row];
    self.sourceURL = videoVariant.videoVariant;
    [self.videoResourceURLArray removeAllObjects];
    [self parseVideoURL];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(0, 0, self.view.bounds.size.width, 20);
    myLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin);
    myLabel.font = [UIFont fontWithName:@"Copperplate" size:16.0];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    myLabel.backgroundColor = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1.0f];
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    return headerView;
}

@end
