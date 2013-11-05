//
//  CathayWebModalViewController.h
//  CathayEZGO
//
//  Created by dev1 on 2012/3/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CathayWebModalViewController : UIViewController

@property (retain, nonatomic) NSURL *requestURL;
@property (retain, nonatomic) IBOutlet UIWebView *myWebView;

-(IBAction)dismiss:(id)sender;

@end
