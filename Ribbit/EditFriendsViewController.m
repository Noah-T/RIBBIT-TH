//
//  EditFriendsViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "MSCellAccessory.h"


@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController


//declared up here to make it easier to share
//this is a global variable
//doesn't have setters and getters synthesized, just accessible throughout this particular implementation file
UIColor *disclosureColor;

- (void)viewDidLoad {
    [super viewDidLoad];
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error){
            NSLog(@"Error: %@ %@", error, error.userInfo);
        } else {
            
            //objects represents the return from the query
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
    self.currentUser = [PFUser currentUser];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1.0];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    return self.allUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self isFriend:user]) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    } else {
        //this is necessary because of the way iOS reuses cells
        //it sounds like a checkmark from a reused stay could carry over, if this wasn't implemented
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //
    //when selected, a row will add a checkmark on the righthand side
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"];
    
    
    if ([self isFriend:user]) {
        //1. remove checkmark
        cell.accessoryView = nil;
        //2. remove from the array of friends
        for (PFUser *friend in self.friends) {
            if([friend.objectId isEqualToString:user.objectId]){
                [self.friends removeObject:friend];
                break;
            }
        }
        [friendsRelation removeObject:user];
    } else {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
        //locally add the user to the friends array
        [self.friends addObject:user];
        
        //add the user to the friendsRelation backend
        [friendsRelation addObject:user];
        //save the currentUser instance in the backend (to sync the newly added relationship)
        
    }
    
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, error.userInfo);
        }
    }];
    
    
}

- (BOOL)isFriend:(PFUser *)user{
    for (PFUser *friend in self.friends) {
        if([friend.objectId isEqualToString:user.objectId]){
            return YES;
        }
    }
    return NO;
    
}


@end
