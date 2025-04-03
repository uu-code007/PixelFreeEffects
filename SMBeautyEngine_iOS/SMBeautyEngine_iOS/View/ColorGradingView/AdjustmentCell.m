//
//  AdjustmentCell.m
//  testGPUImage
//
//  Created by sunmu on 2025/3/16.
//

#import "AdjustmentCell.h"
#import "AdjustmentItem.h"

@interface AdjustmentCell ()

@property (nonatomic, strong) UILabel *nameLabel; // 调节项名称
@property (nonatomic, strong) UISlider *slider;    // 滑动条

@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation AdjustmentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    // 名称标签
    self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 80, 30)];
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:self.nameLabel];
    
    // 滑动条
    self.slider = [[UISlider alloc] initWithFrame:CGRectMake(120, 10, CGRectGetWidth(self.contentView.frame) - 140, 30)];
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:self.slider];
    
    self.valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.slider.frame) + 10, 10, 60, 30)];
    self.valueLabel.font = [UIFont systemFontOfSize:15];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:self.valueLabel];
}

- (void)setItem:(AdjustmentItem *)item {
    _item = item;
    
    // 更新 UI
    self.nameLabel.text = item.name;
    self.slider.minimumValue = item.minValue;
    self.slider.maximumValue = item.maxValue;
    self.slider.value = item.value;
    self.valueLabel.text = [NSString stringWithFormat:@"%0.1f",item.value];
}

#pragma mark - UISlider 事件处理

- (void)sliderValueChanged:(UISlider *)slider {
    // 更新调节项的值
    self.item.value = slider.value;
    self.valueLabel.text = [NSString stringWithFormat:@"%0.1f",self.item.value];
    
    // 回调滑动事件
    if (self.sliderValueChangedBlock) {
        self.sliderValueChangedBlock(slider.value);
    }
}

@end

