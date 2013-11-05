//
//  PopWebViewController.h
//  CathayLifeB2EPad
//
//  Created by dev1 on 2011/9/15.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PopWebViewController : UIViewController<UIWebViewDelegate> {
    NSURL *targetURL;
    UIWebView *webView;
}
@property (nonatomic, retain) NSURL *targetURL;
@property (nonatomic, retain) NSString *html;
@property (nonatomic, retain) IBOutlet UIWebView *webView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil targetURL:(NSURL *)url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil BodyHTML:(NSString *)bodyHtml;
-(IBAction) dismissModal;
@end
