//
//  SDCoreTextViewController.m
//  SigningDay
//
//  Created by Lukas Kekys on 11/13/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import "SDCoreTextViewController.h"

@interface SDCoreTextViewController () <DTAttributedTextContentViewDelegate>

@property (nonatomic, weak) IBOutlet DTAttributedTextContentView *attributedTextView;

@end

@implementation SDCoreTextViewController

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
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // Assign our delegate, this is required to handle link events
    self.attributedTextView.delegate = self;
    self.attributedTextView.shouldDrawImages = YES;
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"html"];
    NSMutableString *htmlString = [NSMutableString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];

    NSString *result = [self formattedForrumReplyFromString:htmlString];
    
    NSDictionary *builderOptions = @{DTDefaultFontFamily: @"Helvetica",
                           DTDefaultLineHeightMultiplier: @"0.5"};
    
    NSData *htmlData = [result dataUsingEncoding:NSUTF8StringEncoding];
    DTHTMLAttributedStringBuilder *stringBuilder = [[DTHTMLAttributedStringBuilder alloc] initWithHTML:htmlData
                                                                                               options:builderOptions
                                                                                    documentAttributes:nil];
    
    self.attributedTextView.attributedString = [stringBuilder generatedAttributedString];
}

- (NSString *)formattedForrumReplyFromString:(NSString *)reply
{
    NSString *htmlString = [reply stringByReplacingOccurrencesOfString:@"\\n" withString:@"<br>"];
    NSString *string = [htmlString stringByReplacingOccurrencesOfString:@"<blockquote class=\\\"quote\\\">" withString:@"<blockquote class=\"quote\" style=\"background-color:#f0f0f0\"><div style=\"padding:5px 10px 5px 10px;\">"];
    
    NSString *original = @"#f0f0f0";
    NSString *replacementGray = @"#E6E6E6";
    NSString *replacementDarkGray = @"#F2F2F2";
    NSRange r;
    int counter = 0;
    
    while ((r = [string rangeOfString:original options:NSRegularExpressionSearch]).location != NSNotFound) {
        if (counter % 2 == 0)
            string = [string stringByReplacingCharactersInRange:r withString:replacementGray];
        else
            string = [string stringByReplacingCharactersInRange:r withString:replacementDarkGray];
        counter++;
    }
    
    NSString *result = [string stringByReplacingOccurrencesOfString:@"</blockquote>" withString:@"</div></blockquote>"];
    return result;
}

#pragma mark - DTAttributedTextContentViewDelegate

- (UIView *)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView
                          viewForLink:(NSURL *)url
                           identifier:(NSString *)identifier
                                frame:(CGRect)frame
{
    DTLinkButton *linkButton = [[DTLinkButton alloc] initWithFrame:frame];
    linkButton.URL = url;
    [linkButton addTarget:self
                   action:@selector(linkButtonClicked:)
         forControlEvents:UIControlEventTouchUpInside];
    
    return linkButton;
}

//- (BOOL)attributedTextContentView:(DTAttributedTextContentView *)attributedTextContentView shouldDrawBackgroundForTextBlock:(DTTextBlock *)textBlock frame:(CGRect)frame context:(CGContextRef)context forLayoutFrame:(DTCoreTextLayoutFrame *)layoutFrame
//{
//    return YES;
//}

#pragma mark - Events

- (IBAction)linkButtonClicked:(DTLinkButton *)sender
{
    [[UIApplication sharedApplication] openURL:sender.URL];
}

-(NSString *)parseString:(NSString *)string
{
    NSLog (@"Original input: %@", string);
    
    NSArray *stringParts = [string componentsSeparatedByString:@"abc"];
    
    NSLog (@"found %d parts", stringParts.count);
    
    for (NSString *part in stringParts)
    {
        NSLog (@"   '%@'",part);
    }
    
    NSMutableString *mResult = [[NSMutableString alloc] init];
    
    bool toggler = YES;
    bool lastWasEmpty = NO;
    
    for (NSString *part in stringParts)
    {
        if (!lastWasEmpty)
        {
            [mResult appendFormat:@"aaa%d",toggler?1:2];
            
            toggler = !toggler;
        }
        
        [mResult appendString:part];
        
        lastWasEmpty = !(part && (![part isEqualToString:@""]));
    }
    
    NSLog (@"Final result: %@", mResult);
    
    return [NSString stringWithString:mResult];
}

- (void)test
{
    NSString *myString = @"My blue car is bigger then my blue shoes or my blue bicycle";
    NSString *original = @"blue";
    NSString *replacement = @"green";
        NSLog(@"my string = %@",myString);
    
    NSRange r;
    while ((r = [myString rangeOfString:original options:NSRegularExpressionSearch]).location != NSNotFound) {
        myString = [myString stringByReplacingCharactersInRange:r withString:replacement];
    }
    
    NSLog(@"replaced my string = %@",myString);
    
}

@end
