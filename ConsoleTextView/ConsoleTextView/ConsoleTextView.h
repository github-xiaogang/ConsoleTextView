//
//  ConsoleTextView.h
//  ConsoleTextView
//
//  Created by 张小刚 on 16/3/9.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    CTVScrollDirectionDown,
    CTVScrollDirectionUp,
}CTVScrollDirection;

@interface ConsoleTextView : UITextView

@property (nonatomic, assign) CTVScrollDirection scrollDirection;

//MM-dd mm:ss
@property (nonatomic, strong) NSString * prefixFormat;

- (void)log: (NSString *)message;
- (void)clear;


@end


@interface UIColor (ConsoleTextView)

+ (UIColor *)ctv_defaultBackgroundColor;
+ (UIColor *)ctv_defaultTextColor;
+ (UIColor *)ctv_defaultNextTextColor;

@end

@interface UIFont (ConsoleTextView)

+ (UIFont *)ctv_defaultFont;

@end