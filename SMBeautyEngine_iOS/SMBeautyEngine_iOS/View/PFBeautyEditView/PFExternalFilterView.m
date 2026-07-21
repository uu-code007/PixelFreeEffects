//
//  PFExternalFilterView.m
//  SMBeautyEngine_iOS
//

#import "PFExternalFilterView.h"
#import "UIColor+PFBeautyEditView.h"

@interface PFExternalFilterItem : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *lutPath;
@property (nonatomic, copy, nullable) NSString *previewPath;
@property (nonatomic, assign) float defaultIntensity;
@end

@implementation PFExternalFilterItem
@end

@interface PFExternalFilterCategory : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray<PFExternalFilterItem *> *filters;
@end

@implementation PFExternalFilterCategory
@end

@interface PFExternalFilterCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
- (void)configureWithItem:(PFExternalFilterItem *)item selected:(BOOL)selected;
@end

@implementation PFExternalFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] init];
        self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        self.imageView.layer.cornerRadius = 4.0;
        self.imageView.layer.borderWidth = 0.0;
        [self.contentView addSubview:self.imageView];

        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightRegular];
        self.titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.78];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.72;
        [self.contentView addSubview:self.titleLabel];

        [NSLayoutConstraint activateConstraints:@[
            [self.imageView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
            [self.imageView.centerXAnchor constraintEqualToAnchor:self.contentView.centerXAnchor],
            [self.imageView.widthAnchor constraintEqualToConstant:54],
            [self.imageView.heightAnchor constraintEqualToConstant:54],
            [self.titleLabel.topAnchor constraintEqualToAnchor:self.imageView.bottomAnchor constant:4],
            [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor],
            [self.titleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor],
            [self.titleLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.contentView.bottomAnchor]
        ]];
    }
    return self;
}

- (void)configureWithItem:(PFExternalFilterItem *)item selected:(BOOL)selected {
    self.titleLabel.text = item.name;
    self.titleLabel.textColor = selected ? [UIColor colorWithHexColorString:@"BAACFF"] : [[UIColor whiteColor] colorWithAlphaComponent:0.78];
    self.imageView.layer.borderWidth = selected ? 2.0 : 0.0;
    self.imageView.layer.borderColor = selected ? [UIColor colorWithHexColorString:@"BAACFF"].CGColor : [UIColor clearColor].CGColor;

    if (item.previewPath.length > 0) {
        self.imageView.image = [UIImage imageWithContentsOfFile:item.previewPath];
        self.imageView.backgroundColor = [UIColor clearColor];
    } else {
        self.imageView.image = nil;
        self.imageView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12];
    }
}

@end

@interface PFExternalFilterView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UISlider *slider;
@property (nonatomic, strong) UIScrollView *categoryScrollView;
@property (nonatomic, strong) UIStackView *categoryStackView;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *categoryIndicator;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<PFExternalFilterCategory *> *categories;
@property (nonatomic, strong) NSArray<PFExternalFilterItem *> *currentFilters;
@property (nonatomic, strong, nullable) PFExternalFilterItem *selectedItem;
@property (nonatomic, assign) NSInteger selectedCategoryIndex;
@property (nonatomic, assign) NSInteger selectedFilterIndex;
@property (nonatomic, copy) NSString *lutRootPath;
@property (nonatomic, strong) NSMutableArray<UIButton *> *categoryButtons;
@property (nonatomic, strong) NSLayoutConstraint *indicatorCenterXConstraint;
@property (nonatomic, strong) NSLayoutConstraint *indicatorWidthConstraint;
@end

@implementation PFExternalFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    self.selectedCategoryIndex = 0;
    self.selectedFilterIndex = 0;
    self.categoryButtons = [NSMutableArray array];

    self.slider = [[UISlider alloc] init];
    self.slider.translatesAutoresizingMaskIntoConstraints = NO;
    self.slider.minimumValue = 0.0f;
    self.slider.maximumValue = 1.0f;
    self.slider.value = 1.0f;
    self.slider.minimumTrackTintColor = [UIColor colorWithHexColorString:@"BAACFF"];
    self.slider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.20];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];

    self.categoryScrollView = [[UIScrollView alloc] init];
    self.categoryScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryScrollView.showsHorizontalScrollIndicator = NO;
    self.categoryScrollView.alwaysBounceHorizontal = YES;
    [self addSubview:self.categoryScrollView];

    self.categoryStackView = [[UIStackView alloc] init];
    self.categoryStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryStackView.axis = UILayoutConstraintAxisHorizontal;
    self.categoryStackView.spacing = 18;
    self.categoryStackView.alignment = UIStackViewAlignmentCenter;
    [self.categoryScrollView addSubview:self.categoryStackView];

    self.separatorView = [[UIView alloc] init];
    self.separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.separatorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18];
    [self addSubview:self.separatorView];

    self.categoryIndicator = [[UIView alloc] init];
    self.categoryIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    self.categoryIndicator.backgroundColor = [UIColor colorWithHexColorString:@"BAACFF"];
    self.categoryIndicator.layer.cornerRadius = 1.5;
    [self addSubview:self.categoryIndicator];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 18;
    layout.minimumInteritemSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(10, 18, 6, 18);

    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:PFExternalFilterCell.class forCellWithReuseIdentifier:@"PFExternalFilterCell"];
    [self addSubview:self.collectionView];

    self.indicatorCenterXConstraint = [self.categoryIndicator.centerXAnchor constraintEqualToAnchor:self.leadingAnchor constant:30];
    self.indicatorWidthConstraint = [self.categoryIndicator.widthAnchor constraintEqualToConstant:24];

    [NSLayoutConstraint activateConstraints:@[
        [self.slider.topAnchor constraintEqualToAnchor:self.topAnchor constant:2],
        [self.slider.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:56],
        [self.slider.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-56],
        [self.slider.heightAnchor constraintEqualToConstant:30],

        [self.categoryScrollView.topAnchor constraintEqualToAnchor:self.slider.bottomAnchor constant:4],
        [self.categoryScrollView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.categoryScrollView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.categoryScrollView.heightAnchor constraintEqualToConstant:34],

        [self.categoryStackView.topAnchor constraintEqualToAnchor:self.categoryScrollView.topAnchor],
        [self.categoryStackView.bottomAnchor constraintEqualToAnchor:self.categoryScrollView.bottomAnchor],
        [self.categoryStackView.leadingAnchor constraintEqualToAnchor:self.categoryScrollView.leadingAnchor constant:18],
        [self.categoryStackView.trailingAnchor constraintEqualToAnchor:self.categoryScrollView.trailingAnchor constant:-18],
        [self.categoryStackView.heightAnchor constraintEqualToAnchor:self.categoryScrollView.heightAnchor],

        [self.separatorView.topAnchor constraintEqualToAnchor:self.categoryScrollView.bottomAnchor],
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:8],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-8],
        [self.separatorView.heightAnchor constraintEqualToConstant:1],

        [self.categoryIndicator.topAnchor constraintEqualToAnchor:self.separatorView.bottomAnchor constant:-2],
        self.indicatorWidthConstraint,
        [self.categoryIndicator.heightAnchor constraintEqualToConstant:3],
        self.indicatorCenterXConstraint,

        [self.collectionView.topAnchor constraintEqualToAnchor:self.separatorView.bottomAnchor constant:4],
        [self.collectionView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.collectionView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.collectionView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
}

- (void)loadFiltersIfNeeded {
    if (self.categories.count > 0) {
        return;
    }
    NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"json" inDirectory:@"256x256Lut"];
    if (!jsonPath) {
        return;
    }
    self.lutRootPath = [jsonPath stringByDeletingLastPathComponent];
    NSData *data = [NSData dataWithContentsOfFile:jsonPath];
    if (!data) {
        return;
    }
    NSDictionary *root = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSArray *categoryDictionaries = [root[@"categories"] isKindOfClass:NSArray.class] ? root[@"categories"] : @[];
    NSMutableArray<PFExternalFilterCategory *> *parsedCategories = [NSMutableArray array];

    for (NSDictionary *categoryDict in categoryDictionaries) {
        PFExternalFilterCategory *category = [[PFExternalFilterCategory alloc] init];
        category.name = [categoryDict[@"name"] isKindOfClass:NSString.class] ? categoryDict[@"name"] : @"";
        NSMutableArray<PFExternalFilterItem *> *filters = [NSMutableArray array];
        PFExternalFilterItem *origin = [[PFExternalFilterItem alloc] init];
        origin.name = @"原图";
        origin.defaultIntensity = 0.0f;
        [filters addObject:origin];

        NSArray *groups = [categoryDict[@"groups"] isKindOfClass:NSArray.class] ? categoryDict[@"groups"] : @[];
        for (NSDictionary *groupDict in groups) {
            NSArray *filterDicts = [groupDict[@"filters"] isKindOfClass:NSArray.class] ? groupDict[@"filters"] : @[];
            for (NSDictionary *filterDict in filterDicts) {
                PFExternalFilterItem *item = [[PFExternalFilterItem alloc] init];
                item.name = [filterDict[@"name"] isKindOfClass:NSString.class] ? filterDict[@"name"] : @"";
                NSString *lutPath = [filterDict[@"lutPath"] isKindOfClass:NSString.class] ? filterDict[@"lutPath"] : nil;
                NSString *previewPath = [filterDict[@"previewPath"] isKindOfClass:NSString.class] ? filterDict[@"previewPath"] : nil;
                item.lutPath = lutPath.length > 0 ? [self.lutRootPath stringByAppendingPathComponent:lutPath] : nil;
                item.previewPath = previewPath.length > 0 ? [self.lutRootPath stringByAppendingPathComponent:previewPath] : nil;
                item.defaultIntensity = [filterDict[@"defaultIntensity"] respondsToSelector:@selector(floatValue)] ? [filterDict[@"defaultIntensity"] floatValue] : 1.0f;
                [filters addObject:item];
            }
        }
        category.filters = filters;
        if (category.name.length > 0 && filters.count > 1) {
            [parsedCategories addObject:category];
        }
    }
    self.categories = parsedCategories;
    [self rebuildCategoryButtons];
    [self selectCategoryAtIndex:0 notify:NO];
}

- (void)rebuildCategoryButtons {
    for (UIView *view in self.categoryStackView.arrangedSubviews) {
        [self.categoryStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    [self.categoryButtons removeAllObjects];

    [self.categories enumerateObjectsUsingBlock:^(PFExternalFilterCategory *category, NSUInteger idx, BOOL *stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = idx;
        [button setTitle:category.name forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.48] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        button.contentEdgeInsets = UIEdgeInsetsMake(6, 0, 6, 0);
        [button addTarget:self action:@selector(categoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.categoryStackView addArrangedSubview:button];
        [self.categoryButtons addObject:button];
    }];
}

- (void)categoryButtonTapped:(UIButton *)sender {
    [self selectCategoryAtIndex:sender.tag notify:YES];
}

- (void)selectCategoryAtIndex:(NSInteger)index notify:(BOOL)notify {
    if (index < 0 || index >= self.categories.count) {
        return;
    }
    self.selectedCategoryIndex = index;
    PFExternalFilterCategory *category = self.categories[index];
    self.currentFilters = category.filters;
    self.selectedFilterIndex = 0;
    self.selectedItem = self.currentFilters.firstObject;
    self.slider.value = 1.0f;

    [self.categoryButtons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.selected = (idx == index);
    }];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self.collectionView reloadData];
    [self updateCategoryIndicatorAnimated:YES];
    if (notify) {
        [self notifySelectedItem];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(70, 74);
    layout.minimumLineSpacing = 18;
    layout.minimumInteritemSpacing = 10;
    [layout invalidateLayout];
    [self updateCategoryIndicatorAnimated:NO];
}

- (void)updateCategoryIndicatorAnimated:(BOOL)animated {
    if (self.selectedCategoryIndex < 0 || self.selectedCategoryIndex >= self.categoryButtons.count) {
        return;
    }
    UIButton *button = self.categoryButtons[self.selectedCategoryIndex];
    CGRect frame = [button.superview convertRect:button.frame toView:self];
    CGFloat centerX = CGRectGetMidX(frame);
    void (^changes)(void) = ^{
        self.indicatorCenterXConstraint.constant = centerX;
        self.indicatorWidthConstraint.constant = MIN(MAX(CGRectGetWidth(frame), 24.0), 56.0);
        [self layoutIfNeeded];
    };
    if (animated) {
        [UIView animateWithDuration:0.22 animations:changes];
    } else {
        changes();
    }
    [self.categoryScrollView scrollRectToVisible:CGRectInset(button.frame, -24, 0) animated:animated];
}

- (void)sliderValueChanged:(UISlider *)sender {
    if (!self.selectedItem) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(externalFilterView:intensityDidChange:lutPath:)]) {
        [self.delegate externalFilterView:self intensityDidChange:sender.value lutPath:self.selectedItem.lutPath];
    }
}

- (void)notifySelectedItem {
    if (!self.selectedItem) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(externalFilterView:didSelectLutPath:intensity:)]) {
        [self.delegate externalFilterView:self didSelectLutPath:self.selectedItem.lutPath intensity:self.slider.value];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentFilters.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFExternalFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PFExternalFilterCell" forIndexPath:indexPath];
    PFExternalFilterItem *item = self.currentFilters[indexPath.item];
    [cell configureWithItem:item selected:indexPath.item == self.selectedFilterIndex];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < 0 || indexPath.item >= self.currentFilters.count) {
        return;
    }
    self.selectedFilterIndex = indexPath.item;
    self.selectedItem = self.currentFilters[indexPath.item];
    self.slider.value = self.selectedItem.lutPath.length > 0 ? self.selectedItem.defaultIntensity : 0.0f;
    [self.collectionView reloadData];
    [self notifySelectedItem];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(70, 74);
}

@end
