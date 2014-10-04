//
//  FriendsViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"

@interface FriendsViewController ()

@end

@implementation FriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.friendsRelation = [[PFUser currentUser]objectForKey:@"friendsRelation"];
}

-(void)viewWillAppear:(BOOL)animated

{
    

    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            //friends listed are a result of the query. Returns all objects that match the key "friendsRelation"
            self.friends = objects;
            //refresh the tableView with the new information
            [self.tableView reloadData];
        }
        
    }];

    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showEditFriends"]) {
        //another example of casting. Sender has a type of id by default. this tells the FriendsViewController to treat the destination view controller as an instance of EditFriendsViewController
        EditFriendsViewController *viewController = (EditFriendsViewController* )segue.destinationViewController;
        viewController.friends = [NSMutableArray arrayWithArray:self.friends];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.friends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    cell.textLabel.text = user.username;
    return cell;
    
}

@end
