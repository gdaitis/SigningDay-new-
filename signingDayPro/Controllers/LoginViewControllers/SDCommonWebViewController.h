//
//  SDCommonWebViewController.h
//  SigningDay
//
//  Created by Vytautas Gudaitis on 8/29/12.
//
//

#import <UIKit/UIKit.h>
#import "GAI.h"

@interface SDCommonWebViewController : GAITrackedViewController <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end
