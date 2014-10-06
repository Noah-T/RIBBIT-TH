//
//  ImageViewController.m
//  Ribbit
//
//  Created by Noah Teshu on 10/5/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import "ImageViewController.h"



@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //this returns a url string
    PFFile *imageFile = [self.message objectForKey:@"file"];
    
    NSURL *imageFileUrl = [[NSURL alloc]initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
    
     self.imageView.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"];
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName];
    self.navigationItem.title = title;

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");
    if ([self respondsToSelector:@selector(timeOut)]) {
        NSLog(@"does respond");
        [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeOut) userInfo:nil repeats:NO];

    }
    
 

}


#pragma mark - Helper Methods

-(void)timeOut {
    [self.navigationController popViewControllerAnimated:YES];
    NSLog(@"pop");
    
}
    
    



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
