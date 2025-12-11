//
//  PFDemoBar.m
//
//  Created by mumu on 2021/9/6.
//

#import "PFBeautyEditView.h"
#import "PFFilterView.h"
#import "PFSlider.h"
#import "PFBeautyView.h"
#import "PFBeautyParam.h"
#import "PFDateHandle.h"

static const NSInteger PFBeautyEditViewButtonTagBase = 101;

static NSArray<NSNumber *> *PFBeautyEditViewDefaultModules(void) {
    return @[
        @(PFBeautyEditViewModuleTypeOneKey),
        @(PFBeautyEditViewModuleTypeSkin),
        @(PFBeautyEditViewModuleTypeShape),
        @(PFBeautyEditViewModuleTypeFilter),
        @(PFBeautyEditViewModuleTypeStickers),
        @(PFBeautyEditViewModuleTypeMakeup)
    ];
}

static NSString *PFBeautyEditViewTitleForType(PFBeautyEditViewModuleType type) {
    switch (type) {
        case PFBeautyEditViewModuleTypeOneKey:
            return NSLocalizedString(@"一键美颜", nil);
        case PFBeautyEditViewModuleTypeSkin:
            return NSLocalizedString(@"美肤", nil);
        case PFBeautyEditViewModuleTypeShape:
            return NSLocalizedString(@"美型", nil);
        case PFBeautyEditViewModuleTypeFilter:
            return NSLocalizedString(@"滤镜", nil);
        case PFBeautyEditViewModuleTypeMakeup:
            return NSLocalizedString(@"美妆", nil);
        case PFBeautyEditViewModuleTypeStickers:
            return NSLocalizedString(@"贴纸", nil);
        default:
            return @"";
    }
}

@interface PFBeautyEditView ()<PFFilterViewDelegate, PFBeautyViewDelegate>

@property (nonatomic, strong) UIButton *comparisonButton;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *contentContainer;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UIView *bottomContainer;
@property (nonatomic, strong) UIStackView *bottomStackView;
@property (nonatomic, strong) PFSlider *beautySlider;
@property (nonatomic, strong) PFFilterView *faceTypeView;
@property (nonatomic, strong) PFFilterView *beautyFilterView;
@property (nonatomic, strong) PFFilterView *makeupView;
@property (nonatomic, strong) PFFilterView *stickersView;
@property (nonatomic, strong) PFBeautyView *shapeView;
@property (nonatomic, strong) PFBeautyView *skinView;
@property (nonatomic, strong) NSArray<UIView *> *contentViews;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, UIButton *> *moduleButtonMap;
@property (nonatomic, assign) PFBeautyEditViewModuleType currentModuleType;
@property (strong, nonatomic) PFBeautyParam *seletedParam;

@end

@implementation PFBeautyEditView

@synthesize oneKeyType = _oneKeyType;
@synthesize filterIndex = _filterIndex;
@synthesize stickersIndex = _stickersIndex;

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
    self.moduleButtonMap = [NSMutableDictionary dictionary];
    self.currentModuleType = PFBeautyEditViewModuleTypeNone;
    [self buildBaseLayout];
    [self setupContentViews];
    [self setupDate];
    [self configureInitialDatasets];
    self.moduleTypes = PFBeautyEditViewDefaultModules();
}

- (void)buildBaseLayout {
    self.topView = [[UIView alloc] init];
    self.topView.translatesAutoresizingMaskIntoConstraints = NO;
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.50];
    self.topView.layer.cornerRadius = 16.0;
    self.topView.clipsToBounds = YES;
    if (@available(iOS 11.0, *)) {
        self.topView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    self.topView.hidden = YES;
    [self addSubview:self.topView];

    self.bottomContainer = [[UIView alloc] init];
    self.bottomContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.bottomContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.50];
    [self addSubview:self.bottomContainer];

    self.separatorView = [[UIView alloc] init];
    self.separatorView.translatesAutoresizingMaskIntoConstraints = NO;
    self.separatorView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.25];
    [self.topView addSubview:self.separatorView];

    [NSLayoutConstraint activateConstraints:@[
        [self.bottomContainer.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.bottomContainer.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.bottomContainer.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.bottomContainer.heightAnchor constraintGreaterThanOrEqualToConstant:56],
        [self.topView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:0],
        [self.topView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:0],
        [self.topView.topAnchor constraintEqualToAnchor:self.topAnchor constant:70],
    ]];

    self.bottomStackView = [[UIStackView alloc] init];
    self.bottomStackView.axis = UILayoutConstraintAxisHorizontal;
    self.bottomStackView.spacing = 12;
    self.bottomStackView.distribution = UIStackViewDistributionFillEqually;
    self.bottomStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bottomContainer addSubview:self.bottomStackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.bottomStackView.leadingAnchor constraintEqualToAnchor:self.bottomContainer.leadingAnchor constant:16],
        [self.bottomStackView.trailingAnchor constraintEqualToAnchor:self.bottomContainer.trailingAnchor constant:-16],
        [self.bottomStackView.topAnchor constraintEqualToAnchor:self.bottomContainer.topAnchor constant:8],
        [self.bottomStackView.bottomAnchor constraintEqualToAnchor:self.bottomContainer.bottomAnchor constant:-8]
    ]];

    [NSLayoutConstraint activateConstraints:@[
        [self.separatorView.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor constant:8],
        [self.separatorView.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor constant:-8],
        [self.separatorView.bottomAnchor constraintEqualToAnchor:self.topView.bottomAnchor],
        [self.separatorView.heightAnchor constraintEqualToConstant:1],
        [self.bottomContainer.topAnchor constraintEqualToAnchor:self.separatorView.bottomAnchor]
    ]];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleBackgroundTap:)];
    tap.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap];

    self.comparisonButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.comparisonButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.comparisonButton.tag = PFBeautyEditViewButtonTagBase;
    UIImage *comparisonImage = [UIImage imageNamed:@"comparison_icon"];
    [self.comparisonButton setImage:comparisonImage forState:UIControlStateNormal];
    [self.comparisonButton setImage:comparisonImage forState:UIControlStateSelected];
    [self.comparisonButton addTarget:self action:@selector(onBtnCompareTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.comparisonButton addTarget:self action:@selector(onBtnCompareTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.comparisonButton];

    self.beautySlider = [[PFSlider alloc] init];
    self.beautySlider.translatesAutoresizingMaskIntoConstraints = NO;
    self.beautySlider.hidden = YES;
    [self.beautySlider addTarget:self action:@selector(filterSliderValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.topView addSubview:self.beautySlider];

    self.contentContainer = [[UIView alloc] init];
    self.contentContainer.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentContainer.backgroundColor = [UIColor clearColor];
    [self.topView addSubview:self.contentContainer];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.comparisonButton.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor constant:-8],
        [self.comparisonButton.topAnchor constraintEqualToAnchor:self.topView.topAnchor constant:12],
        [self.comparisonButton.widthAnchor constraintEqualToConstant:44],
        [self.comparisonButton.heightAnchor constraintEqualToConstant:44],

        [self.beautySlider.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor constant:56],
        [self.beautySlider.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor constant:-56],
        [self.beautySlider.centerYAnchor constraintEqualToAnchor:self.comparisonButton.centerYAnchor],
        [self.beautySlider.heightAnchor constraintEqualToConstant:34],

        [self.contentContainer.topAnchor constraintEqualToAnchor:self.beautySlider.bottomAnchor constant:8],
        [self.contentContainer.leadingAnchor constraintEqualToAnchor:self.topView.leadingAnchor],
        [self.contentContainer.trailingAnchor constraintEqualToAnchor:self.topView.trailingAnchor],
        [self.contentContainer.bottomAnchor constraintEqualToAnchor:self.topView.bottomAnchor constant:-8]
    ]];
}

- (UICollectionViewFlowLayout *)layoutWithItemSize:(CGSize)size
                                             inset:(UIEdgeInsets)inset
                                       lineSpacing:(CGFloat)lineSpacing
                                    interItemSpace:(CGFloat)interItemSpace {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = lineSpacing;
    layout.minimumInteritemSpacing = interItemSpace;
    layout.itemSize = size;
    layout.sectionInset = inset;
    return layout;
}

- (void)addContentView:(UIView *)view toCollection:(NSMutableArray<UIView *> *)collection horizontalInset:(CGFloat)inset {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.hidden = YES;
    [self.contentContainer addSubview:view];
    [NSLayoutConstraint activateConstraints:@[
        [view.topAnchor constraintEqualToAnchor:self.contentContainer.topAnchor],
        [view.bottomAnchor constraintEqualToAnchor:self.contentContainer.bottomAnchor],
        [view.leadingAnchor constraintEqualToAnchor:self.contentContainer.leadingAnchor constant:inset],
        [view.trailingAnchor constraintEqualToAnchor:self.contentContainer.trailingAnchor constant:-inset]
    ]];
    [collection addObject:view];
}

- (void)setupContentViews {
    NSMutableArray<UIView *> *contentViews = [NSMutableArray array];
    
    UIEdgeInsets filterInset = UIEdgeInsetsMake(16, 18, 10, 18);
    UIEdgeInsets beautyInset = UIEdgeInsetsMake(16, 16, 6, 16);
    CGSize filterItemSize = CGSizeMake(54, 70);
    CGSize beautyItemSize = CGSizeMake(44, 74);

    UICollectionViewFlowLayout *oneKeyLayout = [self layoutWithItemSize:filterItemSize
                                                                  inset:filterInset
                                                            lineSpacing:16
                                                         interItemSpace:50];
    self.faceTypeView = [[PFFilterView alloc] initWithFrame:CGRectZero collectionViewLayout:oneKeyLayout];
    self.faceTypeView.showsHorizontalScrollIndicator = NO;
    self.faceTypeView.backgroundColor = [UIColor clearColor];
    self.faceTypeView.mDelegate = self;
    [self addContentView:self.faceTypeView toCollection:contentViews horizontalInset:0];

    UICollectionViewFlowLayout *skinLayout = [self layoutWithItemSize:beautyItemSize
                                                                inset:beautyInset
                                                          lineSpacing:22
                                                       interItemSpace:22];
    self.skinView = [[PFBeautyView alloc] initWithFrame:CGRectZero collectionViewLayout:skinLayout];
    self.skinView.showsHorizontalScrollIndicator = NO;
    self.skinView.alwaysBounceHorizontal = YES;
    self.skinView.mDelegate = self;
    [self addContentView:self.skinView toCollection:contentViews horizontalInset:0];

    UICollectionViewFlowLayout *shapeLayout = [self layoutWithItemSize:beautyItemSize
                                                                 inset:beautyInset
                                                           lineSpacing:22
                                                        interItemSpace:22];
    self.shapeView = [[PFBeautyView alloc] initWithFrame:CGRectZero collectionViewLayout:shapeLayout];
    self.shapeView.showsHorizontalScrollIndicator = NO;
    self.shapeView.alwaysBounceHorizontal = YES;
    self.shapeView.mDelegate = self;
    [self addContentView:self.shapeView toCollection:contentViews horizontalInset:0];

    UICollectionViewFlowLayout *filterLayout = [self layoutWithItemSize:filterItemSize
                                                                  inset:filterInset
                                                            lineSpacing:16
                                                         interItemSpace:16];
    self.beautyFilterView = [[PFFilterView alloc] initWithFrame:CGRectZero collectionViewLayout:filterLayout];
    self.beautyFilterView.showsHorizontalScrollIndicator = NO;
    self.beautyFilterView.mDelegate = self;
    [self addContentView:self.beautyFilterView toCollection:contentViews horizontalInset:0];

    UICollectionViewFlowLayout *stickersLayout = [self layoutWithItemSize:beautyItemSize
                                                                    inset:beautyInset
                                                              lineSpacing:22
                                                           interItemSpace:22];
    self.stickersView = [[PFFilterView alloc] initWithFrame:CGRectZero collectionViewLayout:stickersLayout];
    self.stickersView.showsHorizontalScrollIndicator = NO;
    self.stickersView.mDelegate = self;
    [self addContentView:self.stickersView toCollection:contentViews horizontalInset:0];

    UICollectionViewFlowLayout *makeupLayout = [self layoutWithItemSize:filterItemSize
                                                                  inset:filterInset
                                                            lineSpacing:16
                                                         interItemSpace:16];
    self.makeupView = [[PFFilterView alloc] initWithFrame:CGRectZero collectionViewLayout:makeupLayout];
    self.makeupView.showsHorizontalScrollIndicator = NO;
    self.makeupView.mDelegate = self;
    [self addContentView:self.makeupView toCollection:contentViews horizontalInset:0];

    self.contentViews = contentViews;
}

- (void)configureInitialDatasets {
    [self reloadShapView:_shapeParams];
    [self reloadSkinView:_skinParams];
    [self reloadFilterView:_filtersParams];

    if (!_makeupParams || _makeupParams.count == 0) {
        self.makeupParams = [self buildDefaultMakeupParams];
    } else {
        self.makeupParams = _makeupParams;
    }

    self.faceTypeView.filters = _faceTypeParams;
    if (_faceTypeParams.count > 0) {
        [self.faceTypeView setDefaultFilter:_faceTypeParams[0]];
    }
    [self.faceTypeView reloadData];

    self.stickersView.filters = _stickersParams;
    if (_stickersParams.count > 0) {
        [self.stickersView setDefaultFilter:_stickersParams[0]];
    }
    [self.stickersView reloadData];
}

- (void)setupDate{
    _filtersParams = [PFDateHandle setupFilterData];
    _shapeParams  = [PFDateHandle setupShapData];
    _skinParams = [PFDateHandle setupSkinData];
    _faceTypeParams = [PFDateHandle setupFaceType];
    self.makeupParams = [self buildDefaultMakeupParams];
    _stickersParams = [PFDateHandle setupStickers];
}

- (void)setMakeupParams:(NSArray<PFBeautyParam *> *)makeupParams {
    _makeupParams = makeupParams;
    if (!self.makeupView) {
        return;
    }
    self.makeupView.filters = makeupParams;
    if (makeupParams.count > 0) {
        if (self.makeupView.selectedIndex < 0 || self.makeupView.selectedIndex >= makeupParams.count) {
            self.makeupView.selectedIndex = 0;
        }
        [self.makeupView setDefaultFilter:makeupParams[0]];
    }
    [self.makeupView reloadData];
}

- (NSArray<PFBeautyParam *> *)buildDefaultMakeupParams {
    NSArray *names = @[@"origin", @"大气", @"撩人", @"清新", @"唯美", @"温柔", @"氧气", @"妖媚", @"夜魅", @"御姐", @"知性"];
    NSArray *folders = @[@"origin", @"大气", @"撩人", @"清新", @"唯美", @"温柔", @"氧气", @"妖媚", @"夜魅", @"御姐", @"知性"];
    NSMutableArray *array = [NSMutableArray array];
    for (NSInteger i = 0; i < names.count; i++) {
        PFBeautyParam *param = [[PFBeautyParam alloc] init];
        param.mTitle = names[i];
        param.mParam = folders[i];
        param.type = FUDataTypeMakeup;
        param.mValue = i == 0 ? 0.0f : 1.0f;
        param.defaultValue = param.mValue;
        [array addObject:param];
    }
    return [array copy];
}

- (NSArray<NSNumber *> *)sanitizedModuleTypes:(NSArray<NSNumber *> *)moduleTypes {
    NSArray<NSNumber *> *fallback = moduleTypes.count ? moduleTypes : PFBeautyEditViewDefaultModules();
    NSMutableOrderedSet<NSNumber *> *ordered = [[NSMutableOrderedSet alloc] init];
    for (NSNumber *number in fallback) {
        PFBeautyEditViewModuleType type = (PFBeautyEditViewModuleType)number.integerValue;
        if (type == PFBeautyEditViewModuleTypeNone) {
            continue;
        }
        if (![self contentViewForType:type]) {
            continue;
        }
        [ordered addObject:@(type)];
    }
    return ordered.array;
}

- (void)setModuleTypes:(NSArray<NSNumber *> *)moduleTypes {
    NSArray<NSNumber *> *resolved = [self sanitizedModuleTypes:moduleTypes];
    if ([_moduleTypes isEqualToArray:resolved]) {
        return;
    }
    _moduleTypes = [resolved copy];
    [self rebuildModuleButtons];
}

- (void)rebuildModuleButtons {
    for (UIView *view in self.bottomStackView.arrangedSubviews) {
        [self.bottomStackView removeArrangedSubview:view];
        [view removeFromSuperview];
    }
    [self.moduleButtonMap removeAllObjects];
    [self hiddenTopViewWithAnimation:NO];

    for (NSNumber *number in self.moduleTypes) {
        PFBeautyEditViewModuleType type = (PFBeautyEditViewModuleType)number.integerValue;
        UIButton *button = [self buildModuleButtonForType:type];
        [self.bottomStackView addArrangedSubview:button];
        self.moduleButtonMap[@(type)] = button;
    }

    self.bottomContainer.hidden = self.moduleButtonMap.count == 0;

    NSNumber *preferred = nil;
    for (NSNumber *number in self.moduleTypes) {
        if (number.integerValue == PFBeautyEditViewModuleTypeSkin) {
            preferred = number;
            break;
        }
    }
    NSNumber *target = preferred ?: self.moduleTypes.firstObject;
    if (target) {
        [self selectModuleType:(PFBeautyEditViewModuleType)target.integerValue userInitiated:NO];
    }
}

- (UIButton *)buildModuleButtonForType:(PFBeautyEditViewModuleType)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = PFBeautyEditViewButtonTagBase + type;
    [button setTitle:PFBeautyEditViewTitleForType(type) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.65] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    button.layer.cornerRadius = 16;
    button.layer.masksToBounds = YES;
    [[button.heightAnchor constraintGreaterThanOrEqualToConstant:44] setActive:YES];
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(moduleButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)moduleButtonTapped:(UIButton *)sender {
    PFBeautyEditViewModuleType type = (PFBeautyEditViewModuleType)(sender.tag - PFBeautyEditViewButtonTagBase);
    if (self.currentModuleType == type && !self.topView.hidden) {
        [self hiddenTopViewWithAnimation:YES];
        return;
    }
    [self selectModuleType:type userInitiated:YES];
}

- (void)selectModuleType:(PFBeautyEditViewModuleType)type userInitiated:(BOOL)userInitiated {
    if (![self.moduleTypes containsObject:@(type)]) {
        return;
    }

    self.currentModuleType = type;

    [self.moduleButtonMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIButton * _Nonnull obj, BOOL * _Nonnull stop) {
        BOOL selected = key.integerValue == type;
        obj.selected = selected;
        obj.backgroundColor = selected ? [[UIColor whiteColor] colorWithAlphaComponent:0.18] : [UIColor clearColor];
    }];

    [self hideAllContentViews];
    UIView *target = [self contentViewForType:type];
    target.hidden = NO;

    [self refreshSliderForCurrentModule];
    [self showTopViewWithAnimation:self.topView.isHidden];

    if (userInitiated && [self.mDelegate respondsToSelector:@selector(bottomDidChange:)]) {
        [self.mDelegate bottomDidChange:(int)type];
    }
}

- (void)refreshSliderForCurrentModule {
    self.beautySlider.hidden = YES;
    self.seletedParam = nil;

    switch (self.currentModuleType) {
        case PFBeautyEditViewModuleTypeSkin: {
            NSInteger index = self.skinView.selectedIndex;
            if (index >= 0 && index < self.skinView.dataArray.count) {
                PFBeautyParam *modle = self.skinView.dataArray[index];
                self.seletedParam = modle;
                self.beautySlider.hidden = NO;
                self.beautySlider.type = modle.iSStyle101 ? FUFilterSliderType101 : FUFilterSliderType01;
                self.beautySlider.value = modle.mValue;
            }
        } break;
        case PFBeautyEditViewModuleTypeShape: {
            NSInteger index = self.shapeView.selectedIndex;
            if (index >= 0 && index < self.shapeView.dataArray.count) {
                PFBeautyParam *modle = self.shapeView.dataArray[index];
                self.seletedParam = modle;
                self.beautySlider.hidden = NO;
                self.beautySlider.type = modle.iSStyle101 ? FUFilterSliderType101 : FUFilterSliderType01;
                self.beautySlider.value = modle.mValue;
            }
        } break;
        case PFBeautyEditViewModuleTypeFilter: {
            NSInteger index = self.beautyFilterView.selectedIndex;
            self.beautySlider.type = FUFilterSliderType01;
            self.beautySlider.hidden = index <= 0;
            if (index >= 0 && index < self.beautyFilterView.filters.count) {
                PFBeautyParam *modle = self.beautyFilterView.filters[index];
                self.seletedParam = modle;
                self.beautySlider.value = modle.mValue;
            }
        } break;
        case PFBeautyEditViewModuleTypeMakeup: {
            NSInteger index = self.makeupView.selectedIndex;
            self.beautySlider.hidden = index <= 0;
            if (index >= 0 && index < self.makeupView.filters.count) {
                PFBeautyParam *modle = self.makeupView.filters[index];
                self.seletedParam = modle;
                if (index > 0) {
                    self.beautySlider.type = FUFilterSliderType01;
                    self.beautySlider.value = modle.mValue;
                }
            }
        } break;
        case PFBeautyEditViewModuleTypeOneKey: {
            NSInteger index = self.faceTypeView.selectedIndex;
            if (index >= 0 && index < self.faceTypeView.filters.count) {
                self.seletedParam = self.faceTypeView.filters[index];
            }
        } break;
        case PFBeautyEditViewModuleTypeStickers: {
            NSInteger index = self.stickersView.selectedIndex;
            if (index >= 0 && index < self.stickersView.filters.count) {
                self.seletedParam = self.stickersView.filters[index];
            }
        } break;
        default:
            break;
    }

    [self setSliderTyep:self.seletedParam];
}

- (void)hideAllContentViews {
    for (UIView *view in self.contentViews) {
        view.hidden = YES;
    }
}

- (UIView *)contentViewForType:(PFBeautyEditViewModuleType)type {
    switch (type) {
        case PFBeautyEditViewModuleTypeOneKey:
            return self.faceTypeView;
        case PFBeautyEditViewModuleTypeSkin:
            return self.skinView;
        case PFBeautyEditViewModuleTypeShape:
            return self.shapeView;
        case PFBeautyEditViewModuleTypeFilter:
            return self.beautyFilterView;
        case PFBeautyEditViewModuleTypeMakeup:
            return self.makeupView;
        case PFBeautyEditViewModuleTypeStickers:
            return self.stickersView;
        default:
            return nil;
    }
}

- (void)updateDemoBar{
    self.faceTypeView.filters = _faceTypeParams;
    [self.faceTypeView reloadData];
    self.beautyFilterView.filters = _filtersParams;
    [self.beautyFilterView reloadData];
    self.makeupView.filters = _makeupParams;
    [self.makeupView reloadData];
    self.stickersView.filters = _stickersParams;
    [self.stickersView reloadData];
    self.shapeView.dataArray = _shapeParams;
    [self.shapeView reloadData];
    self.skinView.dataArray = _skinParams;
    [self.skinView reloadData];
}

- (void)setSliderTyep:(PFBeautyParam *)param{
    if (!param) {
        return;
    }
    if (param.iSStyle101) {
        self.beautySlider.type = FUFilterSliderType101;
    }else{
        self.beautySlider.type = FUFilterSliderType01 ;
    }
}

// 开启上半部分
- (void)showTopViewWithAnimation:(BOOL)animation {
    if (!animation) {
        self.topView.hidden = NO;
        self.topView.alpha = 1.0;
        self.topView.transform = CGAffineTransformIdentity ;
        return;
    }

    self.topView.alpha = 0.0 ;
    self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
    self.topView.hidden = NO ;
    [UIView animateWithDuration:0.35 animations:^{
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.alpha = 1.0 ;
    }];

    if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
        [self.mDelegate showTopView:YES];
    }
}

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation {
    if (self.topView.hidden) {
        return ;
    }
    void (^resetState)(void) = ^{
        self.topView.hidden = YES ;
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
        [self hideAllContentViews];
        self.beautySlider.hidden = YES;
        self.currentModuleType = PFBeautyEditViewModuleTypeNone;
        [self.moduleButtonMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIButton * _Nonnull obj, BOOL * _Nonnull stop) {
            obj.selected = NO;
            obj.backgroundColor = [UIColor clearColor];
        }];
    };

    if (animation) {
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
            self.topView.alpha = 0.0 ;
        }completion:^(BOOL finished) {
            resetState();
        }];

        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:NO];
        }
    }else {
        resetState();
    }
}

-(BOOL)isTopViewShow {
    return !self.topView.hidden ;
}

-(void)setDefaultFilter:(PFBeautyParam *)filter{
    [self.beautyFilterView setDefaultFilter:filter];
}

- (void)handleBackgroundTap:(UITapGestureRecognizer *)gesture {
    if (self.topView.hidden) {
        return;
    }
    CGPoint location = [gesture locationInView:self];
    BOOL insideTop = CGRectContainsPoint(self.topView.frame, location);
    BOOL insideBottom = CGRectContainsPoint(self.bottomContainer.frame, location);
    if (!insideTop && !insideBottom) {
        [self hiddenTopViewWithAnimation:YES];
    }
}

-(void)setFaceType:(PFBeautyParam *)paramm {
    int indexValue = (int)[_faceTypeParams indexOfObject:paramm];
    NSDictionary *dic = [PFDateHandle setFaceType:indexValue];

    for (PFBeautyParam *param in _shapeParams) {
        if([dic.allKeys containsObject:param.mParam]) {
            param.mValue = [dic[param.mParam] floatValue];
        }else {
            param.mValue = 0.0f;
        }

        if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
            [_mDelegate filterValueChange:param];
        }

    }

    for (PFBeautyParam *param in _skinParams) {
        if([dic.allKeys containsObject:param.mParam]) {
            param.mValue = [dic[param.mParam] floatValue];
        } else {
            param.mValue = 0.0f;
        }
        if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
            [_mDelegate filterValueChange:param];
        }
    }


    [_skinView reloadData];
    [_shapeView reloadData];
}

-(void)setOneKeyType:(int)oneKeyType {
    _oneKeyType = oneKeyType;
    self.faceTypeView.selectedIndex = oneKeyType;
}

- (int)oneKeyType{
    return (int)self.faceTypeView.selectedIndex;
}

-(void)setFilterIndex:(int)filterIndex{
    _filterIndex = filterIndex;
    self.beautyFilterView.selectedIndex = filterIndex;
}

- (int)filterIndex{
    return (int)self.beautyFilterView.selectedIndex;
}

-(void)setStickersIndex:(int)stickersIndex {
    _stickersIndex = stickersIndex;
    self.stickersView.selectedIndex = stickersIndex;
}

-(int)stickersIndex {
    return (int)self.stickersView.selectedIndex;
}

#pragma mark - Action
- (void)onBtnCompareTouchDown:(UIButton *)sender{
    sender.selected = YES;
    if ([self.mDelegate respondsToSelector:@selector(comparisonButtonDidClick:)]) {
        [self.mDelegate comparisonButtonDidClick:sender.selected];
    }
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender{
    sender.selected = NO;
    if ([self.mDelegate respondsToSelector:@selector(comparisonButtonDidClick:)]) {
        [self.mDelegate comparisonButtonDidClick:sender.selected];
    }
}

#pragma mark ---- PFFilterViewDelegate
// 开启滤镜
-(void)filterViewDidSelectedFilter:(PFBeautyParam *)param{
    _seletedParam = param;
    self.beautySlider.hidden = YES;

    if(param.type == FUDataTypeFilter&& _beautyFilterView.selectedIndex > 0){
        self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
    }
    if (param.type == FUDataTypeMakeup) {
        NSInteger index = self.makeupView.selectedIndex;
        self.beautySlider.hidden = index <= 0;
        if (index > 0) {
            self.beautySlider.type = FUFilterSliderType01;
            self.beautySlider.value = param.mValue;
        }
    }

    [self setSliderTyep:_seletedParam];

    if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
        [_mDelegate filterValueChange:_seletedParam];
    }
}

-(void)beautyCollectionView:(PFBeautyView *)beautyView didSelectedParam:(PFBeautyParam *)param{
    _seletedParam = param;
    self.beautySlider.value = param.mValue;
    self.beautySlider.hidden = NO;

    [self setSliderTyep:_seletedParam];
}

// 滑条滑动
- (IBAction)filterSliderValueChange:(PFSlider *)sender {
    _seletedParam.mValue = sender.value;
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(filterValueChange:)]) {
        [_mDelegate filterValueChange:_seletedParam];
    }
    [_shapeView reloadData];
    [_skinView reloadData];
}

- (IBAction)isOpenFURender:(UISwitch *)sender {

    if (_mDelegate && [_mDelegate respondsToSelector:@selector(switchRenderState:)]) {
        [_mDelegate switchRenderState:sender.on];
    }
}

-(void)reloadSkinView:(NSArray<PFBeautyParam *> *)skinParams{
    _skinView.dataArray = skinParams;
    if (skinParams.count > 0) {
        _skinView.selectedIndex = 0;
        PFBeautyParam *modle = skinParams[0];
        if (modle) {
            _beautySlider.hidden = NO;
            _beautySlider.value = modle.mValue;
        }
    } else {
        _skinView.selectedIndex = -1;
        _beautySlider.hidden = YES;
    }
    [_skinView reloadData];
}

-(void)reloadShapView:(NSArray<PFBeautyParam *> *)shapParams{
    _shapeView.dataArray = shapParams;
    if (shapParams.count > 0) {
        NSInteger defaultIndex = MIN(1, (NSInteger)shapParams.count - 1);
        _shapeView.selectedIndex = defaultIndex;
    } else {
        _shapeView.selectedIndex = -1;
    }
    [_shapeView reloadData];
}

-(void)reloadFilterView:(NSArray<PFBeautyParam *> *)filterParams{
    _beautyFilterView.filters = filterParams;
    [_beautyFilterView reloadData];
}

@end
