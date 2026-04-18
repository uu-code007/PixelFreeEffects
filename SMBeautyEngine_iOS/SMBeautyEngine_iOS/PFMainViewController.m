//
//  PFMainViewController.m
//  SMBeautyEngine_iOS
//
//  Created by 孙慕 on 2022/12/28.
//

#import "PFMainViewController.h"
#import "PFVideoController.h"
#import "PFImageController.h"

@interface PFMainViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *featuresView;
@property (nonatomic, strong) UIView *buttonsView;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIView *statusView;

@end

@implementation PFMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI {
    // 设置背景渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.bounds;
    gradientLayer.colors = @[
        (id)[UIColor systemBackgroundColor].CGColor,
        (id)[UIColor systemBackgroundColor].CGColor,
        (id)[UIColor secondarySystemBackgroundColor].CGColor
    ];
    gradientLayer.locations = @[@0.0, @0.5, @1.0];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(1, 1);
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
    
    // Header
    [self setupHeader];
    
    // Features
    [self setupFeatures];
    
    // Main Buttons
    [self setupMainButtons];
    
    // Footer
    [self setupFooter];
    
    // Layout
    [self setupConstraints];
}

- (void)setupHeader {
    self.headerView = [[UIView alloc] init];
    self.headerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.headerView];
    
    // Icon Container
    UIView *iconContainer = [[UIView alloc] init];
    iconContainer.translatesAutoresizingMaskIntoConstraints = NO;
    iconContainer.backgroundColor = [UIColor systemBlueColor];
    iconContainer.layer.cornerRadius = 30;
    iconContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    iconContainer.layer.shadowOffset = CGSizeMake(0, 4);
    iconContainer.layer.shadowOpacity = 0.3;
    iconContainer.layer.shadowRadius = 8;
    [self.headerView addSubview:iconContainer];
    
    // Icon (使用 SF Symbols)
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.image = [UIImage systemImageNamed:@"sparkles"];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconContainer addSubview:iconView];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = @"望图美颜 SDK";
    titleLabel.font = [UIFont boldSystemFontOfSize:28];
    titleLabel.textColor = [UIColor labelColor];
    [self.headerView addSubview:titleLabel];
    
    // Subtitle
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = @"专业级美颜处理解决方案";
    subtitleLabel.font = [UIFont systemFontOfSize:16];
    subtitleLabel.textColor = [UIColor secondaryLabelColor];
    [self.headerView addSubview:subtitleLabel];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [iconContainer.widthAnchor constraintEqualToConstant:80],
        [iconContainer.heightAnchor constraintEqualToConstant:80],
        [iconContainer.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
        [iconContainer.topAnchor constraintEqualToAnchor:self.headerView.topAnchor constant:20],
        
        [iconView.widthAnchor constraintEqualToConstant:40],
        [iconView.heightAnchor constraintEqualToConstant:40],
        [iconView.centerXAnchor constraintEqualToAnchor:iconContainer.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconContainer.centerYAnchor],
        
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
        [titleLabel.topAnchor constraintEqualToAnchor:iconContainer.bottomAnchor constant:16],
        
        [subtitleLabel.centerXAnchor constraintEqualToAnchor:self.headerView.centerXAnchor],
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:-16]
    ]];
}


- (void)setupFeatures {
    self.featuresView = [[UIView alloc] init];
    self.featuresView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.featuresView];
    
    NSArray *features = @[
        @{@"icon": @"sparkles", @"text": @"智能美颜"},
        @{@"icon": @"wand.and.stars", @"text": @"一键美化"},
        @{@"icon": @"paintbrush.fill", @"text": @"滤镜特效"},
        @{@"icon": @"star.fill", @"text": @"美妆"}
    ];
    
    NSMutableArray *featureViews = [NSMutableArray array];
    for (NSDictionary *feature in features) {
        UIView *featureView = [self createFeatureView:feature];
        [self.featuresView addSubview:featureView];
        [featureViews addObject:featureView];
    }
    
    // Layout features in grid
    CGFloat spacing = 12;
    CGFloat screenWidth = UIScreen.mainScreen.bounds.size.width;
    CGFloat itemWidth = (screenWidth - 48 - spacing * 3) / 4;
    
    for (NSInteger i = 0; i < featureViews.count; i++) {
        UIView *view = featureViews[i];
        [NSLayoutConstraint activateConstraints:@[
            [view.widthAnchor constraintEqualToConstant:itemWidth],
            [view.heightAnchor constraintEqualToConstant:itemWidth],
            [view.leadingAnchor constraintEqualToAnchor:self.featuresView.leadingAnchor constant:24 + i * (itemWidth + spacing)],
            [view.topAnchor constraintEqualToAnchor:self.featuresView.topAnchor]
        ]];
    }
    
    // Add labels
    for (NSInteger i = 0; i < features.count; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.text = features[i][@"text"];
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor secondaryLabelColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self.featuresView addSubview:label];
        
        UIView *featureView = featureViews[i];
        [NSLayoutConstraint activateConstraints:@[
            [label.centerXAnchor constraintEqualToAnchor:featureView.centerXAnchor],
            [label.topAnchor constraintEqualToAnchor:featureView.bottomAnchor constant:8],
            [label.widthAnchor constraintEqualToAnchor:featureView.widthAnchor],
            [label.bottomAnchor constraintEqualToAnchor:self.featuresView.bottomAnchor]
        ]];
    }
}

- (UIView *)createFeatureView:(NSDictionary *)feature {
    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    container.backgroundColor = [UIColor secondarySystemBackgroundColor];
    container.layer.cornerRadius = 16;
    container.layer.shadowColor = [UIColor blackColor].CGColor;
    container.layer.shadowOffset = CGSizeMake(0, 2);
    container.layer.shadowOpacity = 0.1;
    container.layer.shadowRadius = 4;
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.image = [UIImage systemImageNamed:feature[@"icon"]];
    iconView.tintColor = [UIColor systemBlueColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [container addSubview:iconView];
    
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:24],
        [iconView.heightAnchor constraintEqualToConstant:24],
        [iconView.centerXAnchor constraintEqualToAnchor:container.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:container.centerYAnchor]
    ]];
    
    return container;
}

- (void)setupMainButtons {
    self.buttonsView = [[UIView alloc] init];
    self.buttonsView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonsView];
    
    // Camera Button
    UIButton *cameraButton = [self createMainButtonWithTitle:@"相机预览" 
                                                   subtitle:@"实时美颜拍摄" 
                                                       icon:@"camera.fill" 
                                                  gradientColors:@[
                                                      (id)[UIColor systemBlueColor].CGColor,
                                                      (id)[UIColor systemPinkColor].CGColor
                                                  ]];
    [cameraButton addTarget:self action:@selector(cameraButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:cameraButton];
    
    // Image Process Button
    UIButton *imageButton = [self createMainButtonWithTitle:@"图片处理" 
                                                  subtitle:@"照片美化编辑" 
                                                      icon:@"photo.fill" 
                                                 gradientColors:@[
                                                     (id)[UIColor systemPurpleColor].CGColor,
                                                     (id)[UIColor systemBlueColor].CGColor
                                                 ]];
    [imageButton addTarget:self action:@selector(imageButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.buttonsView addSubview:imageButton];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [cameraButton.topAnchor constraintEqualToAnchor:self.buttonsView.topAnchor],
        [cameraButton.leadingAnchor constraintEqualToAnchor:self.buttonsView.leadingAnchor constant:24],
        [cameraButton.trailingAnchor constraintEqualToAnchor:self.buttonsView.trailingAnchor constant:-24],
        [cameraButton.heightAnchor constraintEqualToConstant:88],
        
        [imageButton.topAnchor constraintEqualToAnchor:cameraButton.bottomAnchor constant:16],
        [imageButton.leadingAnchor constraintEqualToAnchor:self.buttonsView.leadingAnchor constant:24],
        [imageButton.trailingAnchor constraintEqualToAnchor:self.buttonsView.trailingAnchor constant:-24],
        [imageButton.heightAnchor constraintEqualToConstant:88],
        [imageButton.bottomAnchor constraintEqualToAnchor:self.buttonsView.bottomAnchor]
    ]];
}

- (UIButton *)createMainButtonWithTitle:(NSString *)title 
                                subtitle:(NSString *)subtitle 
                                    icon:(NSString *)iconName 
                         gradientColors:(NSArray *)colors {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.layer.cornerRadius = 24;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOffset = CGSizeMake(0, 8);
    button.layer.shadowOpacity = 0.3;
    button.layer.shadowRadius = 16;
    
    // Gradient Background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.colors = colors;
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 0);
    gradient.cornerRadius = 24;
    [button.layer insertSublayer:gradient atIndex:0];
    
    // Update gradient frame when layout changes
    dispatch_async(dispatch_get_main_queue(), ^{
        gradient.frame = button.bounds;
    });
    
    // Content Stack
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    contentView.userInteractionEnabled = NO;
    [button addSubview:contentView];
    
    // Icon Container
    UIView *iconContainer = [[UIView alloc] init];
    iconContainer.translatesAutoresizingMaskIntoConstraints = NO;
    iconContainer.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
    iconContainer.layer.cornerRadius = 16;
    [contentView addSubview:iconContainer];
    
    UIImageView *iconView = [[UIImageView alloc] init];
    iconView.translatesAutoresizingMaskIntoConstraints = NO;
    iconView.image = [UIImage systemImageNamed:iconName];
    iconView.tintColor = [UIColor whiteColor];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    [iconContainer addSubview:iconView];
    
    // Text Container
    UIView *textContainer = [[UIView alloc] init];
    textContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:textContainer];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.text = title;
    titleLabel.font = [UIFont boldSystemFontOfSize:20];
    titleLabel.textColor = [UIColor whiteColor];
    [textContainer addSubview:titleLabel];
    
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    subtitleLabel.text = subtitle;
    subtitleLabel.font = [UIFont systemFontOfSize:14];
    subtitleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    [textContainer addSubview:subtitleLabel];
    
    // Arrow
    UILabel *arrowLabel = [[UILabel alloc] init];
    arrowLabel.translatesAutoresizingMaskIntoConstraints = NO;
    arrowLabel.text = @"→";
    arrowLabel.font = [UIFont systemFontOfSize:24];
    arrowLabel.textColor = [UIColor whiteColor];
    [contentView addSubview:arrowLabel];
    
    // Constraints
    [NSLayoutConstraint activateConstraints:@[
        [contentView.topAnchor constraintEqualToAnchor:button.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:button.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:button.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:button.bottomAnchor],
        [contentView.heightAnchor constraintEqualToConstant:88],
        
        [iconContainer.widthAnchor constraintEqualToConstant:56],
        [iconContainer.heightAnchor constraintEqualToConstant:56],
        [iconContainer.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:32],
        [iconContainer.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor],
        
        [iconView.widthAnchor constraintEqualToConstant:28],
        [iconView.heightAnchor constraintEqualToConstant:28],
        [iconView.centerXAnchor constraintEqualToAnchor:iconContainer.centerXAnchor],
        [iconView.centerYAnchor constraintEqualToAnchor:iconContainer.centerYAnchor],
        
        [textContainer.leadingAnchor constraintEqualToAnchor:iconContainer.trailingAnchor constant:16],
        [textContainer.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor],
        
        [titleLabel.topAnchor constraintEqualToAnchor:textContainer.topAnchor],
        [titleLabel.leadingAnchor constraintEqualToAnchor:textContainer.leadingAnchor],
        [titleLabel.trailingAnchor constraintEqualToAnchor:textContainer.trailingAnchor],
        
        [subtitleLabel.topAnchor constraintEqualToAnchor:titleLabel.bottomAnchor constant:4],
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:textContainer.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:textContainer.trailingAnchor],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:textContainer.bottomAnchor],
        
        [arrowLabel.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-32],
        [arrowLabel.centerYAnchor constraintEqualToAnchor:contentView.centerYAnchor]
    ]];
    
    return button;
}

- (void)setupFooter {
    self.footerView = [[UIView alloc] init];
    self.footerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.footerView.backgroundColor = [UIColor secondarySystemBackgroundColor];
    self.footerView.layer.cornerRadius = 16;
    self.footerView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.footerView.layer.shadowOffset = CGSizeMake(0, 2);
    self.footerView.layer.shadowOpacity = 0.1;
    self.footerView.layer.shadowRadius = 4;
    [self.view addSubview:self.footerView];
    
    self.statusView = [[UIView alloc] init];
    self.statusView.translatesAutoresizingMaskIntoConstraints = NO;
    self.statusView.backgroundColor = [UIColor systemGreenColor];
    self.statusView.layer.cornerRadius = 4;
    [self.footerView addSubview:self.statusView];
    
    UILabel *statusLabel = [[UILabel alloc] init];
    statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    statusLabel.text = @"SDK 已就绪";
    statusLabel.font = [UIFont systemFontOfSize:14];
    statusLabel.textColor = [UIColor secondaryLabelColor];
    [self.footerView addSubview:statusLabel];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    versionLabel.text = @"v2.5.05";
    versionLabel.font = [UIFont systemFontOfSize:14];
    versionLabel.textColor = [UIColor secondaryLabelColor];
    [self.footerView addSubview:versionLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.footerView.heightAnchor constraintEqualToConstant:56],
        
        [self.statusView.widthAnchor constraintEqualToConstant:8],
        [self.statusView.heightAnchor constraintEqualToConstant:8],
        [self.statusView.leadingAnchor constraintEqualToAnchor:self.footerView.leadingAnchor constant:16],
        [self.statusView.centerYAnchor constraintEqualToAnchor:self.footerView.centerYAnchor],
        
        [statusLabel.leadingAnchor constraintEqualToAnchor:self.statusView.trailingAnchor constant:8],
        [statusLabel.centerYAnchor constraintEqualToAnchor:self.footerView.centerYAnchor],
        
        [versionLabel.trailingAnchor constraintEqualToAnchor:self.footerView.trailingAnchor constant:-16],
        [versionLabel.centerYAnchor constraintEqualToAnchor:self.footerView.centerYAnchor]
    ]];
}

- (void)setupConstraints {
    // Arrange all views vertically without scrolling
    [NSLayoutConstraint activateConstraints:@[
        // Header
        [self.headerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.headerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.headerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // Features
        [self.featuresView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:24],
        [self.featuresView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.featuresView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // Buttons
        [self.buttonsView.topAnchor constraintEqualToAnchor:self.featuresView.bottomAnchor constant:24],
        [self.buttonsView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.buttonsView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        
        // Footer
        [self.footerView.topAnchor constraintEqualToAnchor:self.buttonsView.bottomAnchor constant:24],
        [self.footerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:24],
        [self.footerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-24],
        [self.footerView.bottomAnchor constraintLessThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-16]
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // Update gradient layers
    for (CALayer *layer in self.view.layer.sublayers) {
        if ([layer isKindOfClass:[CAGradientLayer class]]) {
            layer.frame = self.view.bounds;
        }
    }
    
    for (UIView *subview in self.view.subviews) {
        for (CALayer *layer in subview.layer.sublayers) {
            if ([layer isKindOfClass:[CAGradientLayer class]]) {
                layer.frame = subview.bounds;
            }
        }
    }
}

#pragma mark - Actions

- (IBAction)cameraBtn:(id)sender {
    [self cameraButtonTapped:sender];
}

- (IBAction)cameraButton:(UIButton *)sender {
    [self cameraButtonTapped:sender];
}

- (void)cameraButtonTapped:(id)sender {
    NSLog(@"打开相机预览");
    PFVideoController *videoController = [[PFVideoController alloc] init];
    [self.navigationController pushViewController:videoController animated:YES];
}

- (void)imageButtonTapped:(id)sender {
    NSLog(@"打开图片处理");
    PFImageController *imageController = [[PFImageController alloc] init];
    [self.navigationController pushViewController:imageController animated:YES];
}

@end
