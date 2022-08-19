//
//  PFDemoBar.m
//
//  Created by mumu on 2021/9/6.
//

#import "PFAPIDemoBar.h"
#import "PFFilterView.h"
#import "PFSlider.h"
#import "PFBeautyView.h"
#import "PFBeautyParam.h"
#import "PFDateHandle.h"


@interface PFAPIDemoBar ()<PFFilterViewDelegate, PFBeautyViewDelegate>


@property (weak, nonatomic) IBOutlet UIButton *skinBtn;
@property (weak, nonatomic) IBOutlet UIButton *shapeBtn;
@property (weak, nonatomic) IBOutlet UIButton *beautyFilterBtn;
@property (weak, nonatomic) IBOutlet UIButton *stickerBtn;
@property (weak, nonatomic) IBOutlet UIButton *makeupBtn;
@property (weak, nonatomic) IBOutlet UIButton *bodyBtn;

// 上半部分
@property (weak, nonatomic) IBOutlet UIView *topView;
// 滤镜页
@property (weak, nonatomic) IBOutlet PFFilterView *stickerView;
// 美颜滤镜页
@property (weak, nonatomic) IBOutlet PFFilterView *beautyFilterView;
@property (weak, nonatomic) IBOutlet PFFilterView *makeupView;

@property (weak, nonatomic) IBOutlet PFSlider *beautySlider;
@property (weak, nonatomic) IBOutlet PFBeautyView *bodyView;
// 美型页
@property (weak, nonatomic) IBOutlet PFBeautyView *shapeView;
// 美肤页
@property (weak, nonatomic) IBOutlet PFBeautyView *skinView;

/* 当前选中参数 */
@property (strong, nonatomic) PFBeautyParam *seletedParam;


/* 滤镜参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *filtersParams;
/* 美肤参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *skinParams;
/* 美型参数 */
@property (nonatomic, strong) NSArray<PFBeautyParam *> *shapeParams;

@property (nonatomic, strong) NSArray<PFBeautyParam *> *stickerParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *makeupParams;
@property (nonatomic, strong) NSArray<PFBeautyParam *> *bodyParams;
@end

@implementation PFAPIDemoBar

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {self.backgroundColor = [UIColor clearColor];
        
        self.backgroundColor = [UIColor clearColor];
        NSBundle *bundle = [NSBundle bundleForClass:[PFAPIDemoBar class]];
        self = (PFAPIDemoBar *)[bundle loadNibNamed:@"PFAPIDemoBar" owner:self options:nil].firstObject;
        self.frame = frame;
    }
    return self ;
}


-(void)awakeFromNib {
    [super awakeFromNib];
    [self setupDate];
    
    [self reloadShapView:_shapeParams];
    [self reloadSkinView:_skinParams];
    [self reloadFilterView:_filtersParams];
    
    _makeupView.filters = _makeupParams;
    [_makeupView setDefaultFilter:_makeupParams[0]];
    [_makeupView reloadData];
    
    _stickerView.filters = _stickerParams;
    [_makeupView setDefaultFilter:_stickerParams[0]];
    [_stickerView reloadData];
    
    _bodyView.dataArray = _bodyParams;
    [_makeupView setDefaultFilter:_bodyParams[0]];
    _bodyView.selectedIndex = 1;
    [_bodyView reloadData];
    
    self.stickerView.mDelegate = self ;
    self.makeupView.mDelegate = self;
    self.beautyFilterView.mDelegate = self ;
    
    self.bodyView.mDelegate = self;
    self.shapeView.mDelegate = self ;
    self.skinView.mDelegate = self;
    
    [self.skinBtn setTitle:NSLocalizedString(@"美肤", nil) forState:UIControlStateNormal];
    [self.shapeBtn setTitle:NSLocalizedString(@"美型", nil) forState:UIControlStateNormal];
    [self.beautyFilterBtn setTitle:NSLocalizedString(@"滤镜", nil) forState:UIControlStateNormal];
    
    self.skinBtn.tag = 101;
    self.shapeBtn.tag = 102;
    self.beautyFilterBtn.tag = 103 ;
    self.stickerBtn.tag = 104;
    self.makeupBtn.tag = 105;
    self.bodyBtn.tag = 106;
    
}

-(void)setupDate{
    _filtersParams = [PFDateHandle setupFilterData];
    _shapeParams  = [PFDateHandle setupShapData];
     _skinParams = [PFDateHandle setupSkinData];
     _stickerParams = [PFDateHandle setupSticker];
     _makeupParams = [PFDateHandle setupMakeupData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

-(void)updateUI:(UIButton *)sender{
    self.skinBtn.selected = NO;
    self.shapeBtn.selected = NO;
    self.beautyFilterBtn.selected = NO;
    
    self.stickerBtn.selected = NO;
    self.makeupBtn.selected = NO;
    self.bodyBtn.selected = NO;
    
    
    self.skinView.hidden = YES;
    self.shapeView.hidden = YES ;
    self.beautyFilterView.hidden = YES;
    
    self.makeupView.hidden = YES;
    self.stickerView.hidden = YES;
    self.bodyView.hidden = YES;
    
    sender.selected = YES;
    
    if (sender == self.skinBtn) {
        self.skinView.hidden = NO;
    }
    if (sender == self.stickerBtn) {
        self.stickerView.hidden = NO;

    }
    if (sender == self.makeupBtn) {
        self.makeupView.hidden = NO;
    }
    if (sender == self.beautyFilterBtn) {
        self.beautyFilterView.hidden = NO;
    }
    if (sender == self.shapeBtn) {
        self.shapeView.hidden = NO;
    }
    if (sender == self.bodyBtn) {
        self.bodyView.hidden = NO;
    }
}


- (IBAction)bottomBtnsSelected:(UIButton *)sender {
    if (sender.selected) {
        sender.selected = NO ;
        [self hiddenTopViewWithAnimation:YES];
        return ;
    }
    [self updateUI:sender];
    
    if (self.shapeBtn.selected) {
        /* 修改当前UI */
        NSInteger selectedIndex = self.shapeView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.shapeView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    if (self.skinBtn.selected) {
        NSInteger selectedIndex = self.skinView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.skinView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    // slider 是否显示
    if (self.beautyFilterBtn.selected) {
        NSInteger selectedIndex = self.beautyFilterView.selectedIndex ;
        self.beautySlider.type = FUFilterSliderType01 ;
        self.beautySlider.hidden = selectedIndex <= 0;
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.beautyFilterView.filters[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    if (self.stickerBtn.selected) {
        NSInteger selectedIndex = self.stickerView.selectedIndex ;
        self.beautySlider.hidden = YES;
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.beautyFilterView.filters[selectedIndex];
            _seletedParam = modle;
        }
    }
    
    
    if (self.makeupBtn.selected) {
        NSInteger selectedIndex = self.makeupView.selectedIndex ;
        self.makeupView.type = FUFilterSliderType01 ;
        self.beautySlider.hidden = selectedIndex <= 0;
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.makeupView.filters[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }

    if (self.bodyBtn.selected) {
        NSInteger selectedIndex = self.bodyView.selectedIndex;
        self.beautySlider.hidden = selectedIndex < 0 ;
        
        if (selectedIndex >= 0) {
            PFBeautyParam *modle = self.bodyView.dataArray[selectedIndex];
            _seletedParam = modle;
            self.beautySlider.value = modle.mValue;
        }
    }
    
    
    [self showTopViewWithAnimation:self.topView.isHidden];
    [self setSliderTyep:_seletedParam];
    
    if ([self.mDelegate respondsToSelector:@selector(bottomDidChange:)]) {
            [self.mDelegate bottomDidChange:sender.tag - 101];
    }
}

-(void)setSliderTyep:(PFBeautyParam *)param{
    if (param.iSStyle101) {
        self.beautySlider.type = FUFilterSliderType101;
    }else{
        self.beautySlider.type = FUFilterSliderType01 ;
    }
}


// 开启上半部分
- (void)showTopViewWithAnimation:(BOOL)animation {
    
    if (animation) {
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
    }else {
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.alpha = 1.0 ;
    }
}

// 关闭上半部分
-(void)hiddenTopViewWithAnimation:(BOOL)animation {
    
    if (self.topView.hidden) {
        return ;
    }
    if (animation) {
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
        self.topView.hidden = NO ;
        [UIView animateWithDuration:0.35 animations:^{
            self.topView.transform = CGAffineTransformMakeTranslation(0, self.topView.frame.size.height / 2.0) ;
            self.topView.alpha = 0.0 ;
        }completion:^(BOOL finished) {
            self.topView.hidden = YES ;
            self.topView.alpha = 1.0 ;
            self.topView.transform = CGAffineTransformIdentity ;
            
            self.skinBtn.selected = NO ;
            self.shapeBtn.selected = NO ;
            self.beautyFilterBtn.selected = NO ;
        }];
        
        if (self.mDelegate && [self.mDelegate respondsToSelector:@selector(showTopView:)]) {
            [self.mDelegate showTopView:NO];
        }
    }else {
        
        self.topView.hidden = YES ;
        self.topView.alpha = 1.0 ;
        self.topView.transform = CGAffineTransformIdentity ;
    }
}


- (UIViewController *)viewControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
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
    
    if(param.type == FUDataTypeMakeup&& _makeupView.selectedIndex > 0){
                self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
    }
    
    if(param.type == FUDataTypebody&& _bodyView.selectedIndex > 0){
        self.beautySlider.value = param.mValue;
        self.beautySlider.hidden = NO;
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
//    if(fabsf(sender.value) < 0.01){
        [_shapeView reloadData];
        [_skinView reloadData];
//    }
}

- (IBAction)isOpenFURender:(UISwitch *)sender {
    
    if (_mDelegate && [_mDelegate respondsToSelector:@selector(switchRenderState:)]) {
        [_mDelegate switchRenderState:sender.on];
    }
}

-(void)reloadSkinView:(NSArray<PFBeautyParam *> *)skinParams{
    _skinView.dataArray = skinParams;
    _skinView.selectedIndex = 0;
    PFBeautyParam *modle = skinParams[0];
    if (modle) {
        _beautySlider.hidden = NO;
        _beautySlider.value = modle.mValue;
    }
    [_skinView reloadData];
}

-(void)reloadShapView:(NSArray<PFBeautyParam *> *)shapParams{
    _shapeView.dataArray = shapParams;
    _shapeView.selectedIndex = 1;
    [_shapeView reloadData];
}

-(void)reloadFilterView:(NSArray<PFBeautyParam *> *)filterParams{
    _beautyFilterView.filters = filterParams;
    [_beautyFilterView reloadData];
}

-(void)setDefaultFilter:(PFBeautyParam *)filter{
    [self.beautyFilterView setDefaultFilter:filter];
}

-(BOOL)isTopViewShow {
    return !self.topView.hidden ;
}



@end
