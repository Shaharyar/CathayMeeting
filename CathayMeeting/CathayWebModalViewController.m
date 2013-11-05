//
//  CathayWebModalViewController.m
//  CathayEZGO
//
//  Created by dev1 on 2012/3/23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CathayWebModalViewController.h"

@implementation CathayWebModalViewController
@synthesize myWebView;
@synthesize requestURL;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //load HTML
    NSError* error = nil;
    NSString *path = [[NSBundle mainBundle] bundlePath];
//    NSURL *baseURL = [NSURL fileURLWithPath:path];

    NSString *htmlString = [NSString stringWithContentsOfFile: requestURL.path encoding:NSUTF8StringEncoding error: &error];
    //NSLog(@"html:%@", htmlString);
    [myWebView loadHTMLString:htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    
    //NSURLRequest *newURLRequest = [NSURLRequest requestWithURL: requestURL];
    //[myWebView loadRequest: newURLRequest];
    
}

- (void)viewDidUnload
{
    [self setRequestURL:nil];
    [self setMyWebView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)dealloc {
    [myWebView release];
    [requestURL release];
    [super dealloc];
}

#pragma mark -
#pragma mark UI Action

-(IBAction)dismiss:(id)sender {
    
    //iOS5
    [self dismissModalViewControllerAnimated: YES];
}


@end
