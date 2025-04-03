// ToolUI.m
#import "ToolUI.h"
#import "AdjustmentItem.h"
#import "AdjustmentCell.h"

@interface ToolUI () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<AdjustmentItem *> *adjustmentItems;

@end

@implementation ToolUI

- (instancetype)initWithFrame:(CGRect)frame adjustmentItems:(NSArray<AdjustmentItem *> *)items {
    self = [super initWithFrame:frame];
    if (self) {
        self.adjustmentItems = items;
        
        // 创建 UITableView
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView registerClass:[AdjustmentCell class] forCellReuseIdentifier:@"AdjustmentCell"];
        [self addSubview:self.tableView];
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.adjustmentItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AdjustmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AdjustmentCell" forIndexPath:indexPath];
    AdjustmentItem *item = self.adjustmentItems[indexPath.row];
    cell.item = item;
    
    // 设置滑动事件回调
    __weak typeof(self) weakSelf = self;
    cell.sliderValueChangedBlock = ^(float value) {
        item.value = value;
        if (weakSelf.sliderValueChangedBlock) {
            weakSelf.sliderValueChangedBlock(item);
        }
    };
    
    return cell;
}

@end
