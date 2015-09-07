//
//  MDCalendar.m
//
//
//  Copyright (c) 2014 Michael DiStefano
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "MDCalendar.h"

@interface MDCalendarViewCell : UICollectionViewCell
@property (nonatomic, assign) NSDate  *date;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) UIColor *highlightColor;
@property (nonatomic, assign) UIColor *selectedColor;

@property (nonatomic, assign) CGFloat  borderHeight;
@property (nonatomic, assign) UIColor *borderColor;
@property (nonatomic, assign) UIColor *indicatorColor;
@property (nonatomic, assign) CGFloat  circleWidth;
@property (nonatomic, assign) CGFloat  circleWidthSelected;
@property (nonatomic, assign) UIColor *circleColor;
@property (nonatomic, assign) UIColor *circleColorSelected;

@property (nonatomic, strong) UIImage *circleImage;
@property (nonatomic, strong) UIImage *circleImageSelected;
@property (nonatomic, strong) UIImage *highlightImage;
@property (nonatomic, strong) UIImage *dotImage;

@end

@interface MDCalendarViewCell  ()
@property (nonatomic, strong) UILabel     *label;
@property (nonatomic, strong) UIView      *highlightView;
@property (nonatomic, strong) UIView      *borderView;
@property (nonatomic, strong) UIView      *indicatorView;
@property (nonatomic, strong) UIView      *backgroundCircleView;
@property (nonatomic, strong) UIImageView *circleImageView;
@property (nonatomic, strong) UIImageView *highlightImageView;
@property (nonatomic, strong) UIImageView *dotImageView;

@end

static NSString * const kMDCalendarViewCellIdentifier = @"kMDCalendarViewCellIdentifier";

@implementation MDCalendarViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        self.label = label;
        
        UIView *highlightView = [[UIView alloc] initWithFrame:CGRectZero];
        highlightView.hidden = YES;
        self.highlightView = highlightView;
        
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        bottomBorderView.hidden = YES;
        self.borderView = bottomBorderView;
        
        UIView *indicatorView = [[UIView alloc] initWithFrame:CGRectZero];
        indicatorView.hidden = YES;
        self.indicatorView = indicatorView;
        
        UIImageView *circleImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        circleImageView.hidden = YES;
        self.circleImageView = circleImageView;
        
        UIImageView *highlightImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        highlightImageView.highlighted = YES;
        self.highlightImageView = highlightImageView;
        
        UIImageView *dotImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        dotImageView.hidden = YES;
        self.dotImageView = dotImageView;
        
        UIView *backgroundCircleView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundCircleView.hidden = YES;
        self.backgroundCircleView = backgroundCircleView;
        
        [self.highlightView        addSubview:highlightImageView];
        [self.backgroundCircleView addSubview:circleImageView];
        [self.indicatorView        addSubview:dotImageView];
        
        [self.contentView addSubview:highlightView];
        [self.contentView addSubview:label];
        [self.contentView addSubview:indicatorView];
        [self.contentView addSubview:backgroundCircleView];
        [self.contentView addSubview:bottomBorderView];
        
        self.isAccessibilityElement = YES;
    }
    return self;
}

- (void)setDate:(NSDate *)date {
    _label.text = MDCalendarDayStringFromDate(date);
    
    self.accessibilityLabel = [NSString stringWithFormat:@"%@, %@ of %@ %@", [date weekdayString], [date dayOrdinalityString], [date monthString], @([date year])];
}

- (void)setFont:(UIFont *)font
{
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    _label.textColor = textColor;
}

- (void)setHighlightColor:(UIColor *)highlightColor
{
    _highlightView.backgroundColor = highlightColor;
    _highlightView.hidden = NO;
}

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderView.backgroundColor = borderColor;
    _borderView.hidden = NO;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor
{
    _indicatorView.backgroundColor = indicatorColor;
    _indicatorView.hidden = NO;
}

- (void)setCircleColor:(UIColor *)circleColor
{
    _backgroundCircleView.layer.borderColor = circleColor.CGColor;
    _backgroundCircleView.hidden = NO;
    _backgroundCircleView.layer.borderWidth = _circleWidth;
}

- (void)setCircleImage:(UIImage *)circleImage
{
    _circleImageView.image = circleImage;
    _circleImageView.hidden = NO;
    _backgroundCircleView.hidden = NO;
}

- (void)setCircleImageSelected:(UIImage *)circleImageSelected
{
    _circleImageView.highlightedImage = circleImageSelected;
}

- (void)setHighlightImage:(UIImage *)highlightImage
{
    _highlightImageView.image = highlightImage;
    _highlightImageView.hidden = NO;
    _highlightView.hidden = NO;
}

- (void)setDotImage:(UIImage *)dotImage
{
    _dotImageView.image = dotImage;
    _dotImageView.hidden = NO;
    _indicatorView.hidden = NO;
}

- (void)setSelected:(BOOL)selected
{
    UIView *highlightView        = _highlightView;
    UIView *backgroundCircleView = _backgroundCircleView;
    UIImageView *circleImageView = _circleImageView;
    
//    if (![self.date isEqualToDateSansTime:[NSDate date]]) {
//        highlightView.hidden = YES; //!selected;
//    }else {
//        highlightView.hidden = NO;
//    }
    
//    highlightView.hidden = self.selected;
    
    // We don't need this if selected feature is only displayed on the circle.
//    _label.textColor = selected ? self.backgroundColor : _textColor;
    if (!circleImageView.hidden) {
        circleImageView.highlighted = selected;
        return;
    }
    
    if (backgroundCircleView.hidden) {
        return;
    }
    if (!self.selected && selected) {
        highlightView.hidden = NO;
        highlightView.transform = CGAffineTransformMakeScale(.1f, .1f);
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             highlightView.backgroundColor = _selectedColor;
                             highlightView.transform = CGAffineTransformIdentity;
                             backgroundCircleView.layer.borderWidth = _circleWidthSelected;
                             backgroundCircleView.layer.borderColor = _circleColorSelected.CGColor;
                             
                         }
                         completion:nil];
    }else if (self.selected && !selected) {
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:1.0
              initialSpringVelocity:1.0
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             highlightView.transform = CGAffineTransformMakeScale(.1, .1);
                             highlightView.backgroundColor = [highlightView.backgroundColor colorWithAlphaComponent:0.1f];
                             backgroundCircleView.layer.borderWidth = _circleWidth;
                             backgroundCircleView.layer.borderColor = _circleColor.CGColor;
                             
                         }
                         completion:^(BOOL finished) {
                             if (finished) {
                                 highlightView.backgroundColor = [UIColor clearColor];
                                 highlightView.hidden = YES;
                             }
                         }];
    }
    [super setSelected:selected];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize viewSize = self.contentView.bounds.size;
    _label.frame = CGRectMake(0, _borderHeight, viewSize.width, viewSize.height - _borderHeight);
    
    CGFloat circleSize = MIN(viewSize.width, viewSize.height);
    
// bounds of highlight view smaller than cell
    circleSize = circleSize * .8;
    
//    CGFloat highlightViewInset = viewSize.height * 0.1f;
//    _highlightView.frame = CGRectInset(self.contentView.frame, highlightViewInset, highlightViewInset);
    _highlightView.frame = CGRectMake(0, 0, circleSize, circleSize);
    _highlightView.center = _label.center;
    _highlightView.layer.cornerRadius = CGRectGetHeight(_highlightView.bounds) / 2;
    
    _highlightImageView.frame = _highlightView.bounds;
    
    _borderView.frame = CGRectMake(0, 0, viewSize.width, _borderHeight);
    
    _backgroundCircleView.frame = CGRectMake(0, 0, circleSize, circleSize);
    _backgroundCircleView.center = _label.center;
    if (_circleColor != nil) {
        _backgroundCircleView.layer.cornerRadius = circleSize / 2.;
        _backgroundCircleView.layer.borderWidth = _circleWidth;
    }else {
        _circleImageView.frame = _backgroundCircleView.bounds;
    }
    
    
// Let dot view outside the background circle view (90% smaller)
    CGFloat dotInset = viewSize.width * 0.45f; //viewSize.height * 0.45f;
    CGRect baseFrame = self.contentView.frame;
    baseFrame.size.height = baseFrame.size.width;
    CGRect indicatorFrame = CGRectInset(baseFrame, dotInset, dotInset);
    CGFloat lcoatedUnderCircleView = _backgroundCircleView.frame.origin.y + _backgroundCircleView.frame.size.height;
    indicatorFrame.origin.y = lcoatedUnderCircleView + indicatorFrame.size.height * .3;
    
    _indicatorView.frame = indicatorFrame;
    _indicatorView.layer.cornerRadius = CGRectGetHeight(_indicatorView.bounds) / 2;
    
    if (!_dotImageView.hidden) {
        _dotImageView.frame = CGRectMake(0, 0, _indicatorView.frame.size.width, _indicatorView.frame.size.height);
    }
    
    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.contentView.backgroundColor = nil;
    _label.text = @"";
}

#pragma mark - C Helpers

NSString * MDCalendarDayStringFromDate(NSDate *date) {
    return [NSString stringWithFormat:@"%d", (int)[date day]];
}

@end

@interface MDCalendarWeekdaysView : UIView
@property (nonatomic, strong) NSArray *dayLabels;

@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) UIFont  *font;
@end

@implementation MDCalendarWeekdaysView

@synthesize font = pFont;

+ (CGFloat)preferredHeightWithFont:(UIFont *)font {
    static CGFloat height;
    static dispatch_once_t onceTokenForWeekdayViewHeight;
    dispatch_once(&onceTokenForWeekdayViewHeight, ^{
        NSString *day = [[NSDate weekdayAbbreviations] firstObject];
        UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        dayLabel.text = day;
        dayLabel.font = font;
        dayLabel.textAlignment = NSTextAlignmentCenter;
        dayLabel.adjustsFontSizeToFitWidth = YES;
        height = [dayLabel sizeThatFits:CGSizeZero].height;
    });
    return height;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // We don't need to show week days at the top of each month.
        NSArray *weekdays = [NSDate weekdayAbbreviations];
        NSMutableArray *dayLabels = [NSMutableArray new];
        for (NSString *day in weekdays) {
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            dayLabel.text = day;
            dayLabel.font = self.font;
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.adjustsFontSizeToFitWidth = YES;
            [dayLabels addObject:dayLabel];
            
            [self addSubview:dayLabel];
            
//            self.isAccessibilityElement = YES;
        }
        self.isAccessibilityElement = YES;
//        self.dayLabels = dayLabels;
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat viewWidth = CGRectGetWidth(self.bounds);
    return CGSizeMake(viewWidth, [MDCalendarWeekdaysView preferredHeightWithFont:self.font]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat labelWidth = CGRectGetWidth(self.bounds) / [_dayLabels count];
    CGRect labelFrame = CGRectMake(0, 0, labelWidth, [MDCalendarWeekdaysView preferredHeightWithFont:self.font]);
    for (UILabel *label in _dayLabels) {
        label.frame = labelFrame;
        labelFrame = CGRectOffset(labelFrame, labelWidth, 0);
    }
}

- (void)setTextColor:(UIColor *)textColor {
    for (UILabel *label in _dayLabels) {
        label.textColor = textColor;
    }
}

- (void)setFont:(UIFont *)font {
    for (UILabel *label in _dayLabels) {
        label.font = font;
    }
}

#pragma mark - UIAccessibility

- (NSString *)accessibilityLabel {
    return [NSString stringWithFormat:@"Weekdays, %@ through %@", [NSDate weekdays].firstObject, [NSDate weekdays].lastObject];
}

@end

@interface MDCalendarHeaderView : UICollectionReusableView
@property (nonatomic, assign) NSDate *firstDayOfMonth;
@property (nonatomic, assign) BOOL    shouldShowYear;
@property (nonatomic, assign) BOOL    showWeekDaysView;

@property (nonatomic, assign) UIFont  *font;
@property (nonatomic, assign) UIColor *textColor;

@property (nonatomic, assign) UIFont  *weekdayFont;
@property (nonatomic, assign) UIColor *weekdayTextColor;
@end

@interface MDCalendarHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MDCalendarWeekdaysView *weekdaysView;
@end

static NSString * const kMDCalendarHeaderViewIdentifier = @"kMDCalendarHeaderViewIdentifier";
static NSString * const kMDCalendarFooterViewIdentifier = @"kMDCalendarFooterViewIdentifier";
static CGFloat const kMDCalendarHeaderViewMonthBottomMargin     = 10.f;
static CGFloat const kMDCalendarHeaderViewWeekdayBottomMargin  = 5.f;


@implementation MDCalendarHeaderView

+ (CGFloat)preferredHeightWithMonthLabelFont:(UIFont *)monthFont
                              andWeekdayFont:(UIFont *)weekdayFont{
    static CGFloat headerMonthWeekdayHeight;
    static dispatch_once_t onceTokenForHeaderViewMonthWeekdayHeight;
    dispatch_once(&onceTokenForHeaderViewMonthWeekdayHeight, ^{
        
        CGFloat monthLabelHeight = [self heightForMonthLabelWithFont:monthFont];
        CGFloat marginHeights = kMDCalendarHeaderViewMonthBottomMargin;
        if (weekdayFont != nil) {
            marginHeights += kMDCalendarHeaderViewWeekdayBottomMargin;
        }
        headerMonthWeekdayHeight = monthLabelHeight + marginHeights;
    });
    return headerMonthWeekdayHeight;
}

+ (CGFloat)heightForMonthLabelWithFont:(UIFont *)font {
    static CGFloat monthLabelHeight;
    static dispatch_once_t onceTokenForMonthLabelHeight;
    
    dispatch_once(&onceTokenForMonthLabelHeight, ^{
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.font = font;
        monthLabel.text = [[NSDate date] monthString];  // using current month as an example string
        monthLabelHeight = [monthLabel sizeThatFits:CGSizeZero].height;
    });
    
    return monthLabelHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.textAlignment = NSTextAlignmentLeft;
        
        if (_showWeekDaysView) {
            MDCalendarWeekdaysView *weekdaysView = [[MDCalendarWeekdaysView alloc] initWithFrame:CGRectZero];
            [self addSubview:weekdaysView];
            self.weekdaysView = weekdaysView;
        }
        
        
        [self addSubview:label];
        self.label = label;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize viewSize = self.bounds.size;
    _label.frame = CGRectMake(0, 0, viewSize.width, (viewSize.height / 3 * 2) - kMDCalendarHeaderViewMonthBottomMargin);
    if (_showWeekDaysView) {
        _weekdaysView.frame = CGRectMake(0, CGRectGetMaxY(_label.frame) + kMDCalendarHeaderViewMonthBottomMargin, viewSize.width, viewSize.height - CGRectGetHeight(_label.bounds) - kMDCalendarHeaderViewWeekdayBottomMargin);
    }
    
}

- (CGSize)sizeThatFits:(CGSize)size {
    static BOOL firstTime = YES;
    static CGSize calendarHeaderViewSize;
    if (firstTime) {
        UIFont *weekFont = _showWeekDaysView ? self.weekdayFont : nil;
        
        calendarHeaderViewSize = CGSizeMake([super sizeThatFits:size].width, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:self.font andWeekdayFont:weekFont]);
    }
    NSLog(@"the firstTime var is : %d", firstTime);
    return calendarHeaderViewSize;
}

- (void)setFirstDayOfMonth:(NSDate *)firstDayOfMonth {
    _firstDayOfMonth = firstDayOfMonth;
    NSString *monthString = [firstDayOfMonth monthString];
    NSString *yearString = [NSString stringWithFormat:@" %d", (int)[firstDayOfMonth year]];
    _label.text = _shouldShowYear ? [monthString stringByAppendingString:yearString] : monthString;
}

- (void)setFont:(UIFont *)font {
    _label.font = font;
}

- (void)setTextColor:(UIColor *)textColor {
    _label.textColor = textColor;
}

- (void)setWeekdayFont:(UIFont *)weekdayFont {
    _weekdaysView.font = weekdayFont;
}

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor {
    _weekdaysView.textColor = weekdayTextColor;
}


@end

@interface MDCalendarFooterView : UICollectionReusableView
@property (nonatomic, assign) CGFloat  borderHeight;
@property (nonatomic, assign) UIColor *borderColor;
@end

@interface MDCalendarFooterView ()
@property (nonatomic, strong) UIView *bottomBorder;
@end

@implementation MDCalendarFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *bottomBorderView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:bottomBorderView];
        self.bottomBorder = bottomBorderView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _bottomBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), _borderHeight);
}

- (void)setBorderColor:(UIColor *)borderColor {
    _bottomBorder.backgroundColor = borderColor;
}

@end

@interface MDCalendar () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, assign) NSDate *currentDate;
@end

#define DAYS_IN_WEEK 7
#define MONTHS_IN_YEAR 12
#define NUMBER_OF_ROW 8

// Default spacing
static CGFloat const kMDCalendarViewItemSpacing    = 0.f;
static CGFloat const kMDCalendarViewLineSpacing    = 1.f;
static CGFloat const kMDCalendarViewSectionSpacing = 0.f;

@implementation MDCalendar

- (instancetype)init {
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing  = kMDCalendarViewItemSpacing;
        layout.minimumLineSpacing       = kMDCalendarViewLineSpacing;
        
        self.layout = layout;
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate   = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.allowsMultipleSelection = NO;
        
        [_collectionView registerClass:[MDCalendarViewCell class] forCellWithReuseIdentifier:kMDCalendarViewCellIdentifier];
        [_collectionView registerClass:[MDCalendarHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier];
        [_collectionView registerClass:[MDCalendarFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier];
        
        
        // Default Configuration
        self.startDate      = _currentDate;
        self.selectedDate   = _currentDate;
        self.endDate        = [[_startDate dateByAddingMonths:3] lastDayOfMonth];
        
        self.dayFont        = [UIFont systemFontOfSize:17];
        self.weekdayFont    = [UIFont systemFontOfSize:12];
        
        self.cellBackgroundColor    = nil;
        self.highlightColor         = self.tintColor;
        self.selectedColor          = [[UIColor lightGrayColor] colorWithAlphaComponent:0.4f];
        self.indicatorColor         = [UIColor lightGrayColor];
        self.circleColor            = nil;
        self.circleColorSelected    = nil;
        
        self.headerBackgroundColor  = nil;
        self.headerFont             = [UIFont systemFontOfSize:20];
        
        self.textColor          = [UIColor darkGrayColor];
        self.textHighlightColor = [UIColor darkTextColor];
        self.headerTextColor    = _textColor;
        self.weekdayTextColor   = _textColor;
        
        self.backgroundCircleImage         = nil;
        self.backgroundCircleImageSelected = nil;
        self.highlightImage                = nil;
        self.dotImage                      = nil;
        
        self.showsWeekDaysOnEachMonth = YES;
        
        self.canSelectDaysBeforeStartDate = YES;
        
        [self addSubview:_collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _collectionView.frame = self.bounds;
    [self scrollCalendarToDate:_selectedDate animated:NO];
}

#pragma mark - Custom Accessors

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _collectionView.backgroundColor = backgroundColor;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _collectionView.contentInset = contentInset;
}

- (void)setItemSpacing:(CGFloat)itemSpacing {
    _layout.minimumInteritemSpacing = itemSpacing;
}

- (void)setLineSpacing:(CGFloat)lineSpacing {
    _layout.minimumLineSpacing = lineSpacing;
}

- (CGFloat)lineSpacing {
    return _layout.minimumLineSpacing;
}

- (void)setBorderHeight:(CGFloat)borderHeight {
    _borderHeight = borderHeight;
    if (borderHeight) {
        self.lineSpacing = 0.f;
    }
}

- (NSDate *)currentDate {
    return [NSDate date];
}

#pragma mark - Public Methods

- (void)scrollCalendarToDate:(NSDate *)date animated:(BOOL)animated {
    UICollectionView *collectionView = _collectionView;
    NSIndexPath *indexPath = [self indexPathForDate:date];
    NSSet *visibleIndexPaths = [NSSet setWithArray:[collectionView indexPathsForVisibleItems]];
    if (indexPath && [visibleIndexPaths count] && ![visibleIndexPaths containsObject:indexPath]) {
        [self scrollCalendarToTopOfSection:indexPath.section animated:animated];
    }
}

- (void)scrollCalendarSelectedDateToTop:(BOOL)animated
{
    CGPoint originalOffsetPoint = [_collectionView contentOffset];
    self.offsetPoint = originalOffsetPoint;
    [_collectionView scrollToItemAtIndexPath:_selectedDateIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:animated];
}

- (void)scrollCalendarToToday:(BOOL)animated
{
    [self scrollCalendarToDate:[NSDate date] animated:animated];
    CGPoint currentOffsetPoint = [_collectionView contentOffset];
    self.offsetPoint = currentOffsetPoint;
}

- (void)scrollBackToOriginal
{
    [_collectionView setContentOffset:self.offsetPoint animated:YES];
}


#pragma mark - Private Methods & Helper Functions

- (NSInteger)monthForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [[_startDate firstDayOfMonth] dateByAddingMonths:section];
    return [firstDayOfMonth month];
}

- (NSDate *)dateForFirstDayOfSection:(NSInteger)section {
    return [[_startDate firstDayOfMonth] dateByAddingMonths:section];
}

- (NSDate *)dateForLastDayOfSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth lastDayOfMonth];
}

- (NSInteger)offsetForSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    return [firstDayOfMonth weekday] - 1;
}

- (NSInteger)remainderForSection:(NSInteger)section {
    NSDate *lastDayOfMonth = [self dateForLastDayOfSection:section];
    NSInteger weekday = [lastDayOfMonth weekday];
    return DAYS_IN_WEEK - weekday;
}

// Fix : 0 and multiple of 8 is not included in it.
/*
 * This method will return correct date for item．
 */
- (NSDate *)dateForIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [_startDate dateByAddingMonths:indexPath.section];
    NSDateComponents *components = [date components];
    components.day = indexPath.item - (indexPath.item / 8);
    date = [NSDate dateFromComponents:components];
    
    NSInteger offset = [self offsetForSection:indexPath.section];
    if (offset) {
        date = [date dateByAddingDays:-offset];
    }
    
    return date;
}

- (NSIndexPath *)indexPathForDate:(NSDate *)date {
    NSIndexPath *indexPath = nil;
    if (date) {
        NSDate *firstDayOfCalendar = [_startDate firstDayOfMonth];
        NSInteger section = [firstDayOfCalendar numberOfMonthsUntilEndDate:date];
        NSInteger dayOffset = [self offsetForSection:section];
        NSInteger dayIndex = [date day] + dayOffset - 1;
        indexPath = [NSIndexPath indexPathForItem:dayIndex inSection:section];
    }
    return indexPath;
}

- (CGRect)frameForHeaderForSection:(NSInteger)section {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:1 inSection:section];
    UICollectionViewLayoutAttributes *attributes = [_collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect frameForFirstCell = attributes.frame;
    CGFloat headerHeight = [self collectionView:_collectionView layout:_layout referenceSizeForHeaderInSection:section].height;
    return CGRectOffset(frameForFirstCell, 0, -headerHeight);
}

- (void)scrollCalendarToTopOfSection:(NSInteger)section animated:(BOOL)animated {
    CGRect headerRect = [self frameForHeaderForSection:section];
    CGPoint topOfHeader = CGPointMake(0, headerRect.origin.y - _collectionView.contentInset.top);
    [_collectionView setContentOffset:topOfHeader animated:animated];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > 20) {
        self.offsetPoint = [scrollView contentOffset];
    }
}

- (void)reloadCalendarView
{
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [_startDate numberOfMonthsUntilEndDate:_endDate] + 1;    // Adding 1 necessary to show month of end date
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSDate *firstDayOfMonth = [self dateForFirstDayOfSection:section];
    NSInteger month = [firstDayOfMonth month];
    NSInteger year  = [firstDayOfMonth year];
    NSInteger totalCells = [NSDate numberOfDaysInMonth:month forYear:year] + [self offsetForSection:section] + [self remainderForSection:section];
    totalCells += totalCells / 7.; // One more left column for showing month labels
    return totalCells;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    /*-----------------------*/
    /*----- New feature -----
     *-----------------------*
     * We have 4 types of cell in a section:
     * Left side: 1. Month label        : Only label (and bottom/line biew)
     *            2. Blank              : Invisible
     * Days     : 3. Day of this month  : Normal Format (5 types: before, today(selected), future(selected))
     *            4. Day of other month : Invisible or lighter format
     *-----------------------*/

    BOOL isLeftSideCell = (indexPath.item % NUMBER_OF_ROW == 0);
    BOOL isLeftSideBlankCell = (isLeftSideCell && indexPath.item != 0);
    NSInteger sectionMonth = [self monthForSection:indexPath.section];
    
    MDCalendarViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMDCalendarViewCellIdentifier forIndexPath:indexPath];
    
    cell.userInteractionEnabled = !isLeftSideCell;
    cell.hidden = isLeftSideBlankCell;
    
    /*-------------------------------*/
    /*---- Handle Left side cell ----*/
    /*-------------------------------*/
    if (isLeftSideBlankCell) {
        cell.accessibilityElementsHidden = YES;
    }else if (indexPath.item == 0) { /*----- Item for Month label -----*/
        cell.label.text = [NSString stringWithFormat:@"%tu月", sectionMonth];
        cell.label.font = _headerFont;
        cell.label.textColor = _headerTextColor;
        cell.backgroundCircleView.hidden = YES;
        cell.indicatorColor = [UIColor clearColor];
        cell.highlightView.hidden = YES;
        cell.accessibilityElementsHidden = NO;
    }
    
    if (isLeftSideCell) return cell;
    
    /*-------------------------------*/
    /*------- Handle Day cell -------*/
    /*-------------------------------*/
    NSDate *date = [self dateForIndexPath:indexPath];
    
    /*------- Basic setup -------*/
    BOOL isToday = [date isEqualToDateSansTime:[self currentDate]];
    BOOL isTomorrow = [date isAfterDate:[self currentDate]];
    
    cell.backgroundColor       = _cellBackgroundColor;
    cell.font                  = _dayFont;
    cell.textColor             = isToday ? _textHighlightColor : _textColor;
    cell.date                  = date;
    cell.borderHeight          = _borderHeight;
    cell.borderColor           = _borderColor;
    
    cell.highlightColor        = _highlightColor;
    cell.selectedColor         = _selectedColor;
    if (_highlightImage) cell.highlightImage = _highlightImage;
    
    // Draw circle
    cell.circleWidth           = _circleWidth;
    cell.circleWidthSelected   = _circleWidthSelected;
    cell.circleColor           = isTomorrow ? _circleColor : [_circleColor colorWithAlphaComponent:0.3];
    cell.circleColorSelected   = _circleColorSelected;
    // Circle Image
    if (_backgroundCircleImage) {
        cell.circleImage         = _backgroundCircleImage;
        cell.circleImageSelected = _backgroundCircleImageSelected;
    }
    
    // Show indicator dot under the day. You need to implement method shouldShowIndicatorForDate:
    BOOL showIndicator = NO;
    if ([_delegate respondsToSelector:@selector(calendarView:shouldShowIndicatorForDate:)]) {
        showIndicator = [_delegate calendarView:self shouldShowIndicatorForDate:date];
    }
    
    // Today and other days
    cell.backgroundCircleView.hidden = isToday;
    cell.highlightView.hidden        = !isToday;
    
    // Cell interaction enable/disable
    BOOL shouldSelectedThisItem = [self collectionView:collectionView shouldSelectItemAtIndexPath:indexPath];
    cell.userInteractionEnabled = shouldSelectedThisItem;
    
    // Disable non-selectable cells
    if (!shouldSelectedThisItem) {
//        cell.textColor = [date isEqualToDateSansTime:[self currentDate]] ? cell.textColor : [cell.textColor colorWithAlphaComponent:0.2];
        
        // If the cell is outside the selectable range, and it is not today, tell the user
        // that it is an invalid date ("dimmed" is what Apple uses for disabled buttons).
        if (![date isEqualToDateSansTime:_selectedDate]) {
            cell.accessibilityLabel = [cell.accessibilityLabel stringByAppendingString:@", dimmed"];
        }
    }
    
    cell.accessibilityElementsHidden = NO;
    
    // Handle showing cells outside of current month
    if ([date month] != sectionMonth) {
        if (_showsDaysOutsideCurrentMonth) {
            cell.backgroundColor = [cell.backgroundColor colorWithAlphaComponent:0.2];
            
            CGFloat outerAlpha = 0.3f;
            cell.textColor = [cell.textColor colorWithAlphaComponent:outerAlpha];
            cell.circleImageView.alpha = outerAlpha;
            cell.indicatorView.alpha = outerAlpha;
        } else {
            cell.label.text = @"";
            showIndicator = NO;
            cell.accessibilityElementsHidden = YES;
        }
        cell.label.hidden = !_showsDaysOutsideCurrentMonth;
        cell.backgroundCircleView.hidden = !_showsDaysOutsideCurrentMonth;
        cell.userInteractionEnabled = NO;
    } else if ([date isEqualToDateSansTime:_selectedDate]) {
        // Handle cell selection
        cell.selected = YES;
        [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
    
    /*------- Day cell dot -------*/
    if (_dotImage) {
        cell.dotImage = showIndicator ? _dotImage : nil;
    }else {
        cell.indicatorColor = showIndicator ? _indicatorColor : [UIColor clearColor];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *view;
    
    if (kind == UICollectionElementKindSectionHeader) {
        MDCalendarHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMDCalendarHeaderViewIdentifier forIndexPath:indexPath];
        
        headerView.backgroundColor = _headerBackgroundColor;
        headerView.font = _headerFont;
        headerView.weekdayFont = _weekdayFont;
        headerView.textColor = _headerTextColor;
        headerView.weekdayTextColor = _weekdayTextColor;
        headerView.showWeekDaysView = _showsWeekDaysOnEachMonth;
        
        NSDate *date = [self dateForFirstDayOfSection:indexPath.section];
        headerView.shouldShowYear = [date year] != [_startDate year];
        headerView.firstDayOfMonth = date;
        headerView.label.hidden = YES;
        
        view = headerView;
    } else if (kind == UICollectionElementKindSectionFooter) {
        MDCalendarFooterView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kMDCalendarFooterViewIdentifier forIndexPath:indexPath];
        footerView.borderHeight = _showsBottomSectionBorder ? _borderHeight : 0.f;
        footerView.borderColor  = _borderColor;
        view = footerView;
    }
    
    return view;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];
    self.selectedDate = date;
    self.selectedDateIndexPath = indexPath;
    
    if ([_delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
        [_delegate calendarView:self didSelectDate:date];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDate *date = [self dateForIndexPath:indexPath];
    
    if ([date isBeforeDate:_startDate] && !_canSelectDaysBeforeStartDate) {
        return NO;
    }
    
    if ([_delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
        return [_delegate calendarView:self shouldSelectDate:date];
    }
    
    return YES;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat cellWidth = [self cellWidth];
    CGFloat cellHeight = cellWidth * 1.4;
    return CGSizeMake(cellWidth, cellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    CGFloat boundsWidth = collectionView.bounds.size.width;
    return CGSizeMake(boundsWidth, [MDCalendarHeaderView preferredHeightWithMonthLabelFont:_headerFont andWeekdayFont:_showsWeekDaysOnEachMonth ? _weekdayFont : nil]);
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(CGRectGetWidth(self.bounds), kMDCalendarViewSectionSpacing);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat boundsWidth = collectionView.bounds.size.width;
    CGFloat remainingPoints = boundsWidth - ([self cellWidth] * (DAYS_IN_WEEK+1));
    return UIEdgeInsetsMake(0, remainingPoints / 2, 0, remainingPoints / 2);
}

// Helpers
- (CGFloat)cellWidth {
    CGFloat boundsWidth = _collectionView.bounds.size.width;
    return floor(boundsWidth / (DAYS_IN_WEEK+1)) - kMDCalendarViewItemSpacing;
}

@end
