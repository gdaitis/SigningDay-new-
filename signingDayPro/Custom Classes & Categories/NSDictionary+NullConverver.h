//
//  NSDictionary+NullConverver.h
//  signingDayPro
//
//  Created by Vytautas Gudaitis on 8/14/13.
//  Copyright (c) 2013 Seriously inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NullConverver)

- (NSDictionary *) dictionaryByReplacingNullsWithStrings;

@end
