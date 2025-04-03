//
//  ViewController.h
//  SMBeautyEngine_iOS
//
//  Created by mumu on 2021/11/19.
//

#import <UIKit/UIKit.h>
#include <PixelFree/SMPixelFree.h>
#import "PFAPIDemoBar.h"

@interface ViewController : UIViewController

@property (nonatomic,strong) SMPixelFree *mPixelFree;

@property(nonatomic, strong) PFAPIDemoBar *beautyEditView;

@property (nonatomic,assign)BOOL clickCompare;

@end

