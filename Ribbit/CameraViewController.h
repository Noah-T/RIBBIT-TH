//
//  CameraViewController.h
//  Ribbit
//
//  Created by Noah Teshu on 10/2/14.
//  Copyright (c) 2014 Noah Teshu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <MBProgressHUD/MBProgressHUD.h>
@interface CameraViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *imagePicker;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) NSString *videoFilePath;
@property (strong, nonatomic) NSArray *friends;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) NSMutableArray *recipients;

-(void)uploadMessage;
-(UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;

- (IBAction)cancel:(id)sender;

- (IBAction)send:(id)sender;


@end
