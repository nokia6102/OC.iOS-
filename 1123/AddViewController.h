#import <UIKit/UIKit.h>
#import "MyTableViewController.h"
@interface AddViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
//接收上一頁傳來的參數
-(void)passData:(MyTableViewController *)sourceVC;
@end
