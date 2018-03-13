#import "AddViewController.h"
#import "MyTableViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@interface AddViewController ()
{
    //網路傳輸物件
    NSURLSession *session;
    NSURLSessionDataTask *dataTask;
    //網址字串
    NSString *strURL;
    //網址物件
    NSURL *url;
    //存放PickerView的資料來源
    NSArray *arrGender;
    NSArray *arrClass;
    //記錄目前輸入元件的Y軸底部位置
    CGFloat currentObjectBottomYPosition;
    //記錄來源VC
    MyTableViewController *theSourceVC;
    //記錄目前的詞典資料
    NSMutableDictionary *dicRow;
    //圖片挑選器
    UIImagePickerController *imgPicker;
    //判斷檔案是否上傳
    BOOL isFileUploaded;
}
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UITextField *txtNo;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UIImageView *imgPicture;
@property (weak, nonatomic) IBOutlet UIPickerView *pkvGender;
@property (weak, nonatomic) IBOutlet UIPickerView *pkvClass;
@property (weak, nonatomic) IBOutlet UITextField *txtPhone;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;

@end

@implementation AddViewController
@synthesize progressView,txtNo,txtName,imgPicture,pkvGender,txtPhone,txtAddress,txtEmail,pkvClass;
#pragma mark - 自訂函式
//接收上一頁傳來的參數
-(void)passData:(MyTableViewController *)sourceVC
{
    NSLog(@"上一頁的陣列：%@",sourceVC.arrTable);
    //將來源VC記錄到全域變數
    theSourceVC = sourceVC;
    //這裏不能動UI
}
//由點按手勢呼叫
- (void)CloseKeyBoard
{
    //請所有會喚起鍵盤的物件都要交出第一回應權
    for (UIView *subView in self.view.subviews)
    {
        if ([subView isKindOfClass:[UITextField class]])
        {
            [subView resignFirstResponder];
        }
    }
}
//監聽鍵盤所呼叫的事件-鍵盤彈出
-(void)keyboadrdWillShow:(NSNotification*)sender
{
    //================把畫面往上移================
    //取得通知中心的資料
    NSDictionary *userInfo = sender.userInfo;
    if (userInfo)
    {
        //從通知中心的資料中取得鍵盤高度
        CGFloat keyboardHeight = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        if (keyboardHeight > 0)
        {
            //計算可視高度
            CGFloat visibleHeight = self.view.frame.size.height - keyboardHeight;
            //計算可視高度與特定元件的Y軸底緣之間的差值(正值表示元件被遮住了)
            CGFloat diffHeight = currentObjectBottomYPosition - visibleHeight;
            if (diffHeight > 0)     //如果有遮住才移動
            {
                //整個View往上移動其差值
                [UIView animateWithDuration:0.25 animations:^{
                    self.view.frame = CGRectMake(0, -(diffHeight+20), self.view.frame.size.width, self.view.frame.size.height);
                }];
            }
        }
    }
}

//監聽鍵盤所呼叫的事件-鍵盤收合
-(void)keyboadrdWillHide:(NSNotification*)sender
{
    //把View移回原來的位置
    [UIView animateWithDuration:0.25 animations:^{
        self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}
//檔案上傳封裝方法(第一個參數：已選定的圖片，第二個參數：處理上傳檔案的photo_upload.php，第三個參數：提交檔案的input file id，第四個參數：存放到伺服器端的檔名)
-(void)FileUpload:(UIImage*)image withURLString:(NSString*)urlString byFormInputID:(NSString*)idName andNewFileName:(NSString*)newFileName
{
    //轉換圖檔成為NSData(壓縮jpg)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
    //準備URLRequest
    NSMutableURLRequest *request = [NSMutableURLRequest new];
    //從參數取得上傳檔案的網址
    request.URL = [NSURL URLWithString:urlString];
    request.HTTPMethod = @"POST";
    
    //產生boundary識別碼來界定要傳送的資料
    NSString *boundary = [NSProcessInfo processInfo].globallyUniqueString;
    
    //設定HTTP header當中的Content-Type
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //準備Post Body
    NSMutableData *body = [NSMutableData new];
    
    //以boundary識別碼來製作分隔界線（開始）
    NSString *boundaryStart = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    //Post Body加入分隔界線（開始）
    [body appendData:[boundaryStart dataUsingEncoding:NSUTF8StringEncoding]];
    
    //加入Form
    NSString *formData = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", idName, newFileName];    //此行的userfile需對應到接收上傳的php內變數名稱，newFileName為上傳後存檔的名稱
    //Post Body加入Form
    [body appendData:[formData dataUsingEncoding:NSUTF8StringEncoding]];
    
    //檔案型態
    NSString *fileType = [NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n\r\n"];
    [body appendData:[fileType dataUsingEncoding:NSUTF8StringEncoding]];
    
    //加入圖檔
    [body appendData:imageData];
    
    //以boundary識別碼來製作分隔界線（結束）
    NSString *boundaryEnd = [NSString stringWithFormat:@"\r\n--%@--\r\n", boundary];
    //Post Body加入分隔界線（結束）
    [body appendData:[boundaryEnd dataUsingEncoding:NSUTF8StringEncoding]];
    
    //把Post Body交給URL Reqeust
    request.HTTPBody = body;
    
    //設定上傳任務
    dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //注意：一定要呼叫dispatch_async轉回主執行緒才更新UI，否則會影響顯示效能
        dispatch_async(dispatch_get_main_queue(), ^{
            //顯示進度元件
            progressView.hidden = NO;
            //計算目前上傳進度
            float currentProgress = (float)data.length / (float)response.expectedContentLength;
            //顯示上傳進度
            [progressView setProgress:currentProgress];
            //取得伺服器上傳檔案的回應訊息
            NSString *strEchoMessage = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if ([strEchoMessage isEqualToString:@"success"])
            {
                //標示檔案已上傳
                isFileUploaded = YES;
            }
        });
    }];
    //執行上傳任務
    [dataTask resume];
}
#pragma mark - View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //初始化網路傳輸物件     *very important!
    session = [NSURLSession sharedSession];
    //隱藏上傳進度條
    progressView.hidden = YES;
    //初始化PickerView的資料來源
    arrGender = @[@"女",@"男"];
    arrClass = @[@"手機程式開發",@"網頁程式設計"];
    //指定pickerView的代理人
    pkvGender.delegate = self;
    pkvGender.dataSource = self;
    pkvClass.delegate = self;
    pkvClass.dataSource = self;
    //加上點按手勢收起鍵盤
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CloseKeyBoard)];
    [self.view addGestureRecognizer:tapGesture];
    //初始化Y軸底部位置
    currentObjectBottomYPosition = 0;
    //註冊鍵盤的監聽事件
    //1.鍵盤彈出
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboadrdWillShow:) name:UIKeyboardWillShowNotification object:nil];
    //2.鍵盤收合
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboadrdWillHide:) name:UIKeyboardWillHideNotification object:nil];
    //預設照片未上傳
    isFileUploaded = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Target Action
//照相
- (IBAction)btnCamera:(UIButton *)sender
{
    //初始化imgPicker
    imgPicker = [UIImagePickerController new];
    imgPicker.delegate = self;
    //檢查裝置是否支援相機
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])   //注意驚嘆號
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"找不到設備" message:@"無法使用相機" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    //指定使用相機
    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    //指定相機的功能
    imgPicker.mediaTypes = @[(NSString*)kUTTypeImage];  //注意：要配合import MobileCoreServices
    //允許裁切照片
    imgPicker.allowsEditing = YES;
    //設定picker的識別標籤
    imgPicker.title = @"From Camera";
    //開啟相機
    [self presentViewController:imgPicker animated:true completion:nil];
    //標示照片未上傳
    isFileUploaded = NO;
}
//更換照片
- (IBAction)btnChangePicture:(UIButton *)sender
{
    //初始化imgPicker
    imgPicker = [UIImagePickerController new];
    imgPicker.delegate = self;
    //指定使用相簿
    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //        imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
    imgPicker.mediaTypes = @[(NSString*)kUTTypeImage];
    //允許裁切照片
    imgPicker.allowsEditing = true;
    //設定picker的識別標籤
    imgPicker.title = @"From Album";
    //開啟相簿
    [self presentViewController:imgPicker animated:YES completion:nil];
    //標示照片未上傳
    isFileUploaded = NO;
}
//收起鍵盤的Did End On Exit觸發事件
- (IBAction)didEndOnExit:(id)sender
{
    [sender resignFirstResponder];
}
//一旦開始編輯，就取得該元件的Y軸底部位置
- (IBAction)FieldTouched:(UITextField*)sender
{
    //計算目前元件的Y軸底端位置
    currentObjectBottomYPosition = sender.frame.origin.y + sender.frame.size.height;
    NSLog(@"Y軸底端位置：%f",currentObjectBottomYPosition);
}
//上傳照片
- (IBAction)btnFileUpload:(UIButton *)sender
{
    //制定上傳檔名
    NSString *serverFileName = [NSString stringWithFormat:@"%@.jpg", txtNo.text];
    //取得上傳服務的網址
    strURL = @"http://perkinsung.honor.es/photo_upload.php";
    //呼叫檔案上傳封裝方法
    [self FileUpload:imgPicture.image withURLString:strURL byFormInputID:@"userfile" andNewFileName:serverFileName];
    //===================清除cache資料（防止App一直讀到舊的圖片）修正iOS9實機的問題！===================
    //宣告檔案管理員
    NSFileManager *fm = [NSFileManager new];
    //取得Caches所在路徑
    NSString *cachesPath = [NSString stringWithFormat:@"%@/Library/Caches",NSHomeDirectory()];
    //刪除暫存檔案
    [fm removeItemAtPath:cachesPath error:nil];
}

//新增資料
- (IBAction)btnInsert:(UIButton *)sender
{
    if ([txtNo.text isEqualToString:@""] || [txtName.text isEqualToString:@""] || [txtAddress.text isEqualToString:@""] || [txtPhone.text isEqualToString:@""] || [txtEmail.text isEqualToString:@""])
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"輸入資料缺漏" message:@"所有資料皆不可空白" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    if (!imgPicture.image)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"缺少圖片" message:@"尚未選擇照片" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDestructive handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    //原始的網址(注意：性別需代入%lu，picture欄位預設是『學號.jpg』) perkinsung.honor.es
    NSString* strOriginalURL = [NSString stringWithFormat: @"http://perkinsung.honor.es/insert_data.php?no=%@&name=%@&gender=%lu&picture=images/%@.jpg&phone=%@&address=%@&email=%@&class=%@",txtNo.text,txtName.text,[pkvGender selectedRowInComponent:0],txtNo.text,txtPhone.text,txtAddress.text,txtEmail.text,arrClass[[pkvClass selectedRowInComponent:0]]];
    //網址編碼（避免中文亂碼）
    strURL = [strOriginalURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
    NSLog(@"新增網址：%@",strURL);
    //傳送網址
    url = [NSURL URLWithString:strURL];
    //設定新增任務
    dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable echoData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //如果伺服器為付費主機，不會傳出額外訊息時
        NSString *strEchoMessage = [[NSString alloc] initWithData:echoData encoding:NSUTF8StringEncoding];
        //如果伺服器更新成功時，還多傳出其他訊息時，必須做字串擷取
        //        strEchoMessage = [strEchoMessage substringWithRange:NSMakeRange(0, 1)];
        
        if ([strEchoMessage isEqualToString:@"1"])
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"伺服器回應" message:@"資料新增成功！" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            //準備檔名欄位(注意：需加上圖檔資料夾)
            NSString *imageURL = [NSString stringWithFormat:@"images/%@.jpg",txtNo.text];
            //同步新增上一頁arrTable內對應的資料（返回時viewWillAppear需做tableView資料重載）
            NSDictionary *newRow = @{@"no":txtNo.text,
                                     @"name":txtName.text,
                                     @"phone":txtPhone.text,
                                     @"address":txtAddress.text,
                                     @"email":txtEmail.text,
                                     @"gender":[NSString stringWithFormat:@"%lu",[pkvGender selectedRowInComponent:0]],
                                     @"class":arrClass[[pkvClass selectedRowInComponent:0]],
                                     @"picture":imageURL};
            //注意：要包裝成可變更詞典後，才加入陣列（否則key-value在更新時將無法調整）
            dicRow = [NSMutableDictionary dictionaryWithDictionary:newRow];
            //陣列內新增一筆資料（加在陣列的第一筆）
            [theSourceVC.arrTable insertObject:newRow atIndex:0];
            //如果檔案未上傳
            if (!isFileUploaded)  //注意驚嘆號
            {
                //按一下『上傳檔案』按鈕
                [self btnFileUpload:nil];
            }
        }
        else
        {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"伺服器回應" message:@"資料新增失敗！" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDestructive handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
    //執行更新任務
    [dataTask resume];
}
//結束
- (IBAction)btnExit:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
//選定圖片之後
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if ([picker.title isEqualToString:@"From Camera"])
    {
        //顯示圖片（裁切圖）
        imgPicture.image = info[UIImagePickerControllerEditedImage];
    }
    else
    {
        //顯示圖片（原圖）
        imgPicture.image = info[UIImagePickerControllerOriginalImage];
    }
    //退掉圖片挑選畫面
    [self dismissViewControllerAnimated:YES completion:^{
        //清除imgPicker(要在Block內清除，必須定義成@property)
        imgPicker = nil;
    }];
}

#pragma mark - UIImagePickerControllerDelegate
//<方法二>單一滾輪上顯示的資料（自行製作顯示文字的view）
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    //初始化一個UILabel(長寬與PickerView一樣)
    UILabel *myView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, pickerView.frame.size.height)];
    
    if (pickerView.tag == 0)
    {
        //            return arrGender[row]
        myView.text = arrGender[row];
    }
    else
    {
        //            return arrClass[row]
        myView.text = arrClass[row];
    }
    //設定Label的屬性
    myView.textAlignment = NSTextAlignmentLeft;
    myView.font = [UIFont systemFontOfSize:16];
    myView.backgroundColor = [UIColor clearColor];
    return myView;
}

#pragma mark - UIPickerViewDataSource
//滾輪數量
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//可滾動的資料行數
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 0)
    {
        return arrGender.count;
    }
    else
    {
        return arrClass.count;
    }
}

@end
