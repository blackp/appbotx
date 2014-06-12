//
//  ABXFAQsViewController.m
//
//  Created by Stuart Hall on 21/05/2014.
//  Copyright (c) 2014 Appbot. All rights reserved.
//

#import "ABXFAQsViewController.h"

#import "ABXFaq.h"
#import "ABXFAQViewController.h"
#import "ABXFeedbackViewController.h"

@interface ABXFAQsViewController ()<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *faqs;
@property (nonatomic, strong) NSArray *filteredFaqs;

@property (nonatomic, strong) UISearchBar *searchBar;

@end

@implementation ABXFAQsViewController

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource= nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Title
    self.title = NSLocalizedString(@"FAQs", nil);
    
    // Setup our UI components
    [self setupFaqUI];
    
    // Fetch
    [self fetchFAQs];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI

- (void)setupFaqUI
{
    // Search bar
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search...", nil);
    self.tableView.tableHeaderView = self.searchBar;
    
    // Nav buttons
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"Contact", nil)
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:@selector(onContact)];
}

#pragma mark - Fetching

- (void)fetchFAQs
{
    self.tableView.hidden = YES;
    [self.activityView startAnimating];
    [ABXFaq fetch:^(NSArray *faqs, ABXResponseCode responseCode, NSInteger httpCode, NSError *error) {
        [self.activityView stopAnimating];
        if (responseCode == ABXResponseCodeSuccess) {
            self.faqs = faqs;
            self.filteredFaqs = faqs;
            [self.tableView reloadData];
            
            if (faqs.count == 0) {
                [self showError:NSLocalizedString(@"No FAQs found.", nil)];
            }
            else {
                self.tableView.hidden = NO;
            }
        }
        else {
            [self showError:NSLocalizedString(@"Unable to fetch FAQs.\r\nplease try again later", nil)];
        }
    }];
}

#pragma mark - Buttons

- (void)onContact
{
    [ABXFeedbackViewController showFromController:self
                                      placeholder:NSLocalizedString(@"How can we help?", nil)];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.filteredFaqs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FAQCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    
    if (indexPath.row < self.filteredFaqs.count) {
        cell.textLabel.text = [[self.filteredFaqs objectAtIndex:indexPath.row] question];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ABXFAQViewController* controller = [[ABXFAQViewController alloc] init];
    controller.faq = self.faqs[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Search Bar

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
    
    self.errorLabel.hidden = YES;
    self.filteredFaqs = self.faqs;
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if (searchText.length > 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.question contains[cd] %@ OR SELF.answer contains[cd] %@", searchText, searchText];
        self.filteredFaqs = [self.faqs filteredArrayUsingPredicate:predicate];
        
        if (self.filteredFaqs.count > 0) {
            self.errorLabel.hidden = YES;
        }
        else {
            [self showError:NSLocalizedString(@"No matches found", nil)];
        }
    }
    else {
        self.filteredFaqs = self.faqs;
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    searchBar.text = @"";
}

@end
