//
//  ConsoleTextView.m
//  ConsoleTextView
//
//  Created by 张小刚 on 16/3/9.
//  Copyright © 2016年 lyeah company. All rights reserved.
//

#import "ConsoleTextView.h"

static NSString * const kConsoleTextViewToolBarItemTitle = @"title";
static NSString * const kConsoleTextViewToolBarItemAction = @"action";

static CGFloat const kConsoleTextViewToolBarHeight = 30.0f;
static CGFloat const kConsoleTextViewToolBarItemWidth = 60.0f;


@interface ConsoleTextView ()<UIAlertViewDelegate>

@property (nonatomic, strong) NSDateFormatter * prefixFormatter;

@property (nonatomic, strong) NSArray * toolBarItems;
@property (nonatomic, assign) BOOL showToolBar;
@property (nonatomic, strong) UIView * toolBar;
@property (nonatomic, strong) UIScrollView * toolBarScrollView;
@property (nonatomic, strong) NSArray * observedKeyPaths;

@end

@implementation ConsoleTextView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self ctv_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self ctv_commonInit];
    }
    return self;
}

- (void)ctv_commonInit
{
    self.editable = NO;
    self.bounces = YES;
    self.alwaysBounceVertical = YES;
    self.backgroundColor = [UIColor ctv_defaultBackgroundColor];
    self.textContainerInset = UIEdgeInsetsZero;
    self.scrollDirection = CTVScrollDirectionDown;
    self.prefixFormat = @"[MM-dd mm:ss]\t";
    self.showToolBar = NO;
    NSMutableArray * toolBarItems = [NSMutableArray array];
    [toolBarItems addObject:@{
                             kConsoleTextViewToolBarItemTitle : @"Clear",
                             kConsoleTextViewToolBarItemAction : NSStringFromSelector(@selector(clear)),
                             }];
    [toolBarItems addObject:@{
                              kConsoleTextViewToolBarItemTitle : @"Paste",
                              kConsoleTextViewToolBarItemAction : NSStringFromSelector(@selector(paste)),
                              }];
    self.toolBarItems = toolBarItems;
    [self loadToolBar];
    UITapGestureRecognizer * toolbarGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toolbarGestureRecognized:)];
    [self addGestureRecognizer:toolbarGestureRecognizer];
    NSArray * observedKeyPaths = @[
                           @"frame",
                           @"contentSize",
                           @"contentInset",
                           @"textContainerInset",
                           ];
    for (NSString * keyPath in observedKeyPaths) {
        [self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:nil];
    }
    self.observedKeyPaths = observedKeyPaths;
}

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.superview addSubview:self.toolBar];
}

- (void)loadToolBar
{
    CGRect toolBarFrame = self.frame;
    toolBarFrame.size.height = kConsoleTextViewToolBarHeight;
    UIView * toolBar = [[UIView alloc] initWithFrame:toolBarFrame];
    toolBar.backgroundColor = [UIColor clearColor];
    //add skin view
    UIView * skinView = [[UIView alloc] initWithFrame:toolBar.bounds];
    skinView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    skinView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
    [toolBar addSubview:skinView];
    //add item views
    UIScrollView * toolBarScrollView = [[UIScrollView alloc] initWithFrame:toolBar.bounds];
    toolBarScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    for (int i=0;i<self.toolBarItems.count;i++) {
        NSDictionary * itemData = self.toolBarItems[i];
        NSString * title = itemData[kConsoleTextViewToolBarItemTitle];
        NSString * selectorName = itemData[kConsoleTextViewToolBarItemAction];
        SEL action = NSSelectorFromString(selectorName);
        CGRect buttonFrame = CGRectMake(i * kConsoleTextViewToolBarItemWidth * i, 0, kConsoleTextViewToolBarItemWidth, kConsoleTextViewToolBarHeight);
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:title forState:UIControlStateNormal];
        UIFont * font = [UIFont boldSystemFontOfSize:14.0f];
        button.titleLabel.font = font;
        [button setTitleColor:[UIColor ctv_defaultNextTextColor] forState:UIControlStateNormal];
        [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        button.frame = buttonFrame;
        [toolBarScrollView addSubview:button];
    }
    self.toolBarScrollView = toolBarScrollView;
    [toolBar addSubview:toolBarScrollView];
    self.toolBar = toolBar;
    [self updateToolBarState];
}

- (void)updateToolBarState
{
    CGRect toolBarFrame = self.frame;
    toolBarFrame.size.height = kConsoleTextViewToolBarHeight;
    CTVScrollDirection direction = self.scrollDirection;
    if(direction == CTVScrollDirectionDown){
        toolBarFrame.origin.y = self.frame.origin.y + self.frame.size.height - kConsoleTextViewToolBarHeight;
    }else{
        
    }
    self.toolBar.frame = toolBarFrame;
    self.toolBar.hidden = !self.showToolBar;
}

- (void)log: (NSString *)message
{
    if(message.length == 0) return;
    NSString * formattedMessage = [self formattedLog:message];
    NSAttributedString * formattedContent = [[NSAttributedString alloc] initWithString:formattedMessage attributes:[self nextTextAttributes]];
    NSString * oldMessage = self.text;
    NSAttributedString * oldContent = nil;
    if(oldMessage.length > 0){
        oldContent = [[NSAttributedString alloc] initWithString:oldMessage attributes:[self defaultTextAttributes]];
    }
    NSMutableAttributedString * content = [[NSMutableAttributedString alloc] init];
    CTVScrollDirection direction = self.scrollDirection;
    if(direction == CTVScrollDirectionUp){
        if(oldContent){
            [content appendAttributedString:oldContent];
            [content appendAttributedString:[self _newlineString]];
        }
        [content appendAttributedString:formattedContent];
    }else{
        [content appendAttributedString:formattedContent];
        if(oldContent){
            [content appendAttributedString:[self _newlineString]];
            [content appendAttributedString:oldContent];
        }
    }
    self.attributedText = content;
}

- (void)setPrefixFormat:(NSString *)prefixFormat
{
    if(_prefixFormat == prefixFormat) return;
    _prefixFormat = prefixFormat;
    if(_prefixFormat){
        self.prefixFormatter = [[NSDateFormatter alloc] init];
        self.prefixFormatter.dateFormat = _prefixFormat;
    }
}

- (NSString *)formattedLog: (NSString *)log
{
    NSString * formattedLog = nil;
    if(self.prefixFormatter){
        NSDate * date = [NSDate date];
        NSString * prefix = [self.prefixFormatter stringFromDate:date];
        formattedLog = [NSString stringWithFormat:@"%@%@",prefix,log];
    }else{
        formattedLog = log;
    }
    return formattedLog;
}

- (void)updateVisibleArea
{
    NSString * content = self.text;
    if(content == 0) return;
    CTVScrollDirection direction = self.scrollDirection;
    if(direction == CTVScrollDirectionUp){
        CGFloat frameHeight = self.frame.size.height;
        CGFloat contentHeight = self.contentSize.height;
        CGFloat offsetY = self.contentOffset.y;
        if(contentHeight < frameHeight) return;
        CGFloat targetOffset = contentHeight - frameHeight;
        if(ABS(targetOffset - offsetY) > 40.0f){
            return;
        }
        [self scrollRangeToVisible:NSMakeRange([content length], 0)];
    }else{
        
    }
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    BOOL isObservedKeyPath = NO;
    for (NSString * observedKeyPath in self.observedKeyPaths) {
        if([observedKeyPath isEqualToString:keyPath]){
            isObservedKeyPath = YES;
            break;
        }
    }
    if(isObservedKeyPath){
        [self updateVisibleArea];
    }
}

- (NSDictionary *)defaultTextAttributes
{
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor ctv_defaultTextColor];
    attributes[NSFontAttributeName] = [UIFont ctv_defaultFont];
    return attributes;
}

- (NSDictionary *)nextTextAttributes
{
    NSMutableDictionary * attributes = [NSMutableDictionary dictionary];
    attributes[NSForegroundColorAttributeName] = [UIColor ctv_defaultNextTextColor];
    attributes[NSFontAttributeName] = [UIFont ctv_defaultFont];
    return attributes;
}

- (NSAttributedString *)_newlineString
{
    NSAttributedString * _newlineStr = [[NSAttributedString alloc] initWithString:@"\n" attributes:[self defaultTextAttributes]];
    return _newlineStr;
}

#pragma mark -----------------   tool kit   ----------------

- (void)clear
{
    self.text = nil;
}

- (void)paste
{
    NSString * content = self.text;
    [[UIPasteboard generalPasteboard] setString:content];
}

- (void)toolbarGestureRecognized:(UITapGestureRecognizer *)recognizer
{
    if(recognizer.state != UIGestureRecognizerStateEnded){
        return;
    }
    self.showToolBar = !self.showToolBar;
    [self updateToolBarState];
}

- (void)dealloc
{
    for (NSString * observedKeyPath in self.observedKeyPaths) {
        [self removeObserver:self forKeyPath:observedKeyPath];
    }
}

@end

@implementation UIColor (ConsoleTextView)

+ (UIColor *)ctv_defaultBackgroundColor
{
    return [[UIColor blackColor] colorWithAlphaComponent:1.0];
}

+ (UIColor *)ctv_defaultTextColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.8];
}

+ (UIColor *)ctv_defaultNextTextColor
{
    return [UIColor greenColor];
}

@end

@implementation UIFont (ConsoleTextView)

+ (UIFont *)ctv_defaultFont
{
    return [UIFont systemFontOfSize:13.0f];
}

@end







