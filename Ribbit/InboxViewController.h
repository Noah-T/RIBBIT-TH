//
//  InboxViewController.h
//  Ribbit
//
//  Created by Noah Teshu on 10/1/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface InboxViewController : UITableViewController

@property (strong, nonatomic) NSArray *messages;

@property (strong, nonatomic) PFObject *selectedMessage;

- (IBAction)logout:(id)sender;

@end
