//
//  PopWebViewController.m
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/9/15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "PopWebViewController.h"


@implementation PopWebViewController
@synthesize targetURL, html;
@synthesize webView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil targetURL:(NSURL *)url
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.targetURL = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil BodyHTML:(NSString *)bodyHtml
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
        self.html = bodyHtml;
    }
    return self;
}


- (void)dealloc
{
    [webView release];
    [html release];
    [targetURL release];
    [super dealloc];
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
    
    if (targetURL) {
      	[webView loadRequest:[NSURLRequest requestWithURL:targetURL]];
    }else if (html) {
        [webView loadHTMLString:self.html baseURL:nil];
    }
    
}

- (void)viewDidUnload
{
    [self setWebView:nil];
    [self setHtml:nil];
    [self setTargetURL:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - UIAction

-(IBAction) dismissModal {
    
    [self dismissModalViewControllerAnimated:YES];
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    
    
	//NSString *flag = [webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('$MobiAppLoginFlag').value;"]; 
	NSString *flag = [webView stringByEvaluatingJavaScriptFromString:@"document.title"]; 
    #ifdef IS_DEBUG
    NSLog(@"flag=%@",flag);
    #endif
	
	//if loading page is 國泰金控員工入口網站首頁，dismiss modal
	if ([flag rangeOfString:@"國泰金控員工入口網站"].location != NSNotFound) {
        //if ([flag isEqualToString:@"國泰人壽會員登入"]) {	
        
        [self dismissModalViewControllerAnimated:YES];
	}
	
}


@end
