//
//  ChatViewController.m
//  IM
//
//  Created by Chan on 15/2/4.
//  Copyright (c) 2015年 aicai. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatToolBar.h"
#import <CoreData/CoreData.h>
#import "DocumentUtil.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
#import "CellFrameModel.h"
#import "ChatCell.h"
#import "UploadFileUtil.h"
#import "SocketClient.h"
#import "JCAudioRecorder.h"
#import <AVFoundation/AVFoundation.h>

#define kUploadFileUrl [NSString stringWithFormat:@"http://%@:8080/UploadFile/servlet/UploadFileServlet",kFileServerIP]

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, NSFetchedResultsControllerDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, JCAudioRecorderDelegate, ChatToolBarDelegate>
{
    UITableView *_chatView;
    ChatToolBar *_toolBar;
    NSFetchedResultsController *_fetchedResultControler;
    NSArray * _cellFrameArray;
    SocketClient *_client;
    AVAudioPlayer *_player;
    
}
@property (nonatomic, strong) JCAudioRecorder *audioRecorder;
@end

@implementation ChatViewController

- (JCAudioRecorder *)audioRecorder
{
    if (_audioRecorder == nil) {
        _audioRecorder = [[JCAudioRecorder alloc] init];
        _audioRecorder.audioRecorderDelegate = self;
    }
    return _audioRecorder;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _client = [[SocketClient alloc] init];
    self.view.backgroundColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0];

    //加载数据
    [self setupFetchedController];
    //添加对话视图
    [self addChatView];
    [self scrollToLastRecord:_chatView];
    //添加工具栏
    [self addChatToolBar];
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatViewRefreshVoice:) name:@"ChatViewShouldRefreshVoice" object:nil];
}

- (void)chatViewRefreshVoice:(NSNotification *)notif
{
    [_chatView reloadData];
//    [self scrollToLastRecord:_chatView];
}
#pragma mark -键盘即将打开或消失时调用
- (void)keyboardWillChangeFrame:(NSNotification *)notif
{
    NSDictionary *userInfo = notif.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];//根据UIKeyboardFrameEndUserInfoKey可知道keyFrame是键盘frame停止改变时的frame
    CGFloat moveY = keyFrame.origin.y - self.view.frame.size.height;
//    CGAffineTransformMakeTranslation每次都是以最初位置的中心点为起始参照
//    
//    CGAffineTransformTranslate每次都是以传入的transform为起始参照
//    
//    CGAffineTransformIdentity为最初状态，即最初位置的中心点
    
    [UIView animateWithDuration:duration animations:^{
        self.view.transform = CGAffineTransformMakeTranslation(0, moveY);
    }];

    
}
#pragma mark -加载CellFrameModel数据
- (void)setupFetchedController
{
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSManagedObjectContext *context = appDelegate.msgArchivingCoreDataStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *des = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[des];
    request.predicate = [NSPredicate predicateWithFormat:@"bareJidStr CONTAINS[cd] %@ AND streamBareJidStr CONTAINS[cd] %@", _bareJidStr, [UserModel sharedUserModel].jid];
    _fetchedResultControler = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultControler.delegate = self;
    NSError *error = nil;
    if (![_fetchedResultControler performFetch:&error]) {
        IMLog(@"%@",[error localizedDescription]);
        return;
    }
    [self loadCellFrameModels];
}

#pragma mark -加载CellFrameModel数据
- (void)loadCellFrameModels
{
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:_fetchedResultControler.fetchedObjects.count];
    for (XMPPMessageArchiving_Message_CoreDataObject *obj in _fetchedResultControler.fetchedObjects) {
        CellMessageModel *msg = [[CellMessageModel alloc] initWithXMPPMessageArchivingMessageCoreDataObject:obj];
        CellFrameModel *frame = [[CellFrameModel alloc] init];
        frame.cellMsg = msg;
        [frames addObject:frame];
        
    }
    _cellFrameArray = frames;
}
#pragma mark -添加消息展示页面
- (void)addChatView
{
    UITableView *chatView = [[UITableView alloc] init];
//    chatView.separatorColor = [UIColor clearColor];
    chatView.separatorStyle = UITableViewCellSeparatorStyleNone;//去掉分割线
//    chatView.separatorInset = UIEdgeInsetsZero;
    chatView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kChatToolBarHeight);
    [self.view addSubview:chatView];
    _chatView = chatView;
    _chatView.showsVerticalScrollIndicator = YES;
//    _chatView.backgroundView = nil;
    _chatView.backgroundColor = [UIColor clearColor];
    _chatView.opaque = YES;
    
    chatView.delegate = self;
    chatView.dataSource = self;
    //点击tableview 关闭键盘
    UITapGestureRecognizer *tapReg = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyBoard)];
    tapReg.delegate = self;
    [chatView addGestureRecognizer:tapReg];
    chatView.delegate = self;
    
}

#pragma mark -UIGestureRecognizerDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}
#pragma mark -关闭键盘
- (void)dismissKeyBoard
{
    [_toolBar hideKeyBoard];
}

#pragma mark -点击对应按钮分享相应内容
- (void)shareMoreWithTag:(int) tag
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"方式选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相机" otherButtonTitles:@"图库", nil];
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:pickerController.sourceType];
        pickerController.mediaTypes = mediaTypes;
        pickerController.delegate = self;
        pickerController.allowsEditing = YES;

    }
    switch (tag){
        case 0://分享图片
            [sheet showInView:delegate.window];
            break;
        case 1://分享视频
            [self presentViewController:pickerController animated:YES completion:nil];

            break;
        case 2://分享小视频（用自定义相机）
            [_client setupSocketWithHost:@"127.0.0.1" port:8888];
            [_client sendString:@"this is from iphone"];
            break;

        default:
            break;
    }
}
#pragma mark -UIActionSheet 代理方法
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//         [actionSheet removeFromSuperview];
//    });
    [actionSheet removeFromSuperview];
    IMLog(@"index = %ld",buttonIndex);
    if (2 == buttonIndex) return;
    UIImagePickerController *imgController = [[UIImagePickerController alloc] init];
    [imgController setAllowsEditing:YES];
    imgController.delegate = self;
    
    
    if(0 == buttonIndex){
//        [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
        
#if TARGET_IPHONE_SIMULATOR
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"友情提示" message:@"该设备不支持摄像" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
        
#else
        [imgController setSourceType:UIImagePickerControllerSourceTypeCamera];
#endif
    }else{
        
        [imgController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        
    }
    
    [self presentViewController:imgController animated:YES completion:nil];
    
}


#pragma mark -UIImagePickerControllerDelegate methods

//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0)
//{
//    IMLog(@"didFinishPickingImage");
//}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    IMLog(@"info = %@",info);
    NSString *mediaTypeStr = info[@"UIImagePickerControllerMediaType"];
    if ([mediaTypeStr isEqualToString:@"public.image"]) {//处理图片
        UIImage *editedImg = info[@"UIImagePickerControllerEditedImage"];
        //    CGFloat imgWidth = editedImg.size.width;
        //    CGFloat imgHeight = editedImg.size.height;
        //  数据转换
        NSData *data = UIImagePNGRepresentation(editedImg);
        NSString *fileName = [NSString stringWithFormat:@"%@.png",[NSString randomString]];
        NSString *doc =  NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        NSString *path = [doc stringByAppendingPathComponent:fileName];
        [data writeToFile:path atomically:YES];
        NSString *returnMsg = [UploadFileUtil uploadFilewWithServerUrl:kUploadFileUrl fileName:fileName fileData:data];
        //    NSData *sendData = UIImagePNGRepresentation(editedImg);
        //    [self.avatarBtn setImage:editedImg forState:UIControlStateNormal];
        [self dismissViewControllerAnimated:YES completion:^{
            [self sendMessage:[returnMsg trimString] type:@"chat"];
        }];
    }else if ([mediaTypeStr isEqualToString:@"public.movie"]){//处理视频
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *movData = [NSData dataWithContentsOfURL:info[@"UIImagePickerControllerMediaURL"]];
            NSString *fileName = [NSString stringWithFormat:@"%@.mov",[NSString randomString]];
            NSString *returnMsg = [UploadFileUtil uploadFilewWithServerUrl:kUploadFileUrl fileName:fileName fileData:movData];
            [self dismissViewControllerAnimated:YES completion:^{
                [self sendMessage:[returnMsg trimString] type:@"chat"];
                
            }];
        });
        //发送本地url
//        [self dismissViewControllerAnimated:YES completion:^{
//            IMLog(@"absoluteString=============%@",info[@"UIImagePickerControllerMediaURL"]);
//            NSString *str = [NSString stringWithFormat:@"%@?ft=2",[info[@"UIImagePickerControllerMediaURL"] absoluteString]];
//            [self sendMessage:str type:@"chat"];
//        }];

    }
   
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    IMLog(@"imagePickerControllerDidCancel");
}
#pragma mark -添加聊天工具条
- (void)addChatToolBar
{
    ChatToolBar *toolBar = [[ChatToolBar alloc] init];
    
    toolBar.delegate = self;
    toolBar.frame = CGRectMake(0, kScreenHeight - kChatToolBarHeight, kScreenWidth, kChatToolBarHeight);
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
    __weak ChatViewController *pSelf = self;
    _toolBar.textFieldShouldReturnBlock =^(NSString *msg){
        [pSelf sendMessage:msg type:@"chat"];
    };
    //点击ShareMoreView中的按钮调用
    __weak ChatViewController *chatVC = self;
    _toolBar.shareBlock = ^(int tag){
        [chatVC shareMoreWithTag:tag];
    };
}

#pragma mark -发送消息 ,默认是chat类型
- (void)sendMessage:(NSString *)message  type:(NSString *)typeStr
{
    //    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    //
    //    // 1) 实例化一个XMPPMessage
    //    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:[XMPPJID jidWithString:_bareJidStr]];
    //
    //    //                NSString *msgStr = [data base64Encoding];
    //
    //    // 3) 设置内容
    //    //                NSXMLElement *imageElement = [NSXMLElement elementWithName:@"imageData" stringValue:msgStr];
    //    //                [message addChild:imageElement];
    //    [message addBody:[returnMsg trimString]];
    //
    //    // 4) 发送消息
    //    //                [[xmppDelegate xmppStream] sendElement:message];
    //    [delegate.xmppStream sendElement:message];
//    1) 实例化一个XMPPMessage
    if ([typeStr isEmptyString]) {
        typeStr = @"chat";
    }

    XMPPMessage *msg = [[XMPPMessage alloc] initWithType:@"chat" to:[XMPPJID jidWithString:self.bareJidStr]];
    if ([typeStr isEqualToString:@"chat"]) {
        // 2) 设置内容
        [msg addBody:message];
    }else{
        NSXMLElement *videoElement = [NSXMLElement elementWithName:typeStr stringValue:message];
        [msg addChild:videoElement];
    }

    // 3) 发送消息
    AppDelegate *delegate = [UIApplication sharedApplication].delegate;
    [delegate.xmppStream sendElement:msg];
    dispatch_async(dispatch_get_main_queue(), ^{
         [self scrollToLastRecord:_chatView];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRecentMsg" object:nil];
}

#pragma mark -滚动到最后一条
- (void)scrollToLastRecord:(UITableView *)tableview
{
    NSInteger row = _cellFrameArray.count - 1;
    if (row > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
        [tableview selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
    }
   
}

#pragma mark -tableview datasource delegate method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellFrameArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_cellFrameArray[indexPath.row] cellHeight];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ReuseId = @"ChatCell";
    ChatCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseId];
    if (cell == nil) {
        cell = [[ChatCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ReuseId];
    }
    cell.cellFrame = _cellFrameArray[indexPath.row];
    cell.tag = indexPath.row;
    return cell;
}

#pragma mark -tableveiw delegate method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark -NSFectedcontroller delegate method
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self loadCellFrameModels];
    [_chatView reloadData];
    [self scrollToLastRecord:_chatView];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    [_toolBar popKeyBoard];
}


- (void)audioRecorder:(JCAudioRecorder *)recorder endWithFailure:(NSString *)errorStr
{
    IMLog(@"录音错误-------》%@",errorStr);
#warning 录音错误提醒
}
- (void)audioRecorder:(JCAudioRecorder *)recorder endWithSuccess:(NSData *)audioData
{
#warning 录音时间过短提醒
    IMLog(@"录音成功-------");
    NSString *fileName = [NSString stringWithFormat:@"%@.caf",[NSString randomString]];
    NSString *returnMsg = [UploadFileUtil uploadFilewWithServerUrl:kUploadFileUrl fileName:fileName fileData:audioData];
    [self sendMessage:returnMsg type:@"chat"];
}


#pragma mark -JCAudioPlayerDelegate methods
- (void)chatToolBarDidStartAudioRecording:(ChatToolBar *)bar
{
    [self.audioRecorder record];
    
}

- (void)chatToolBarDidStopAudioRecording:(ChatToolBar *)bar
{
    [self.audioRecorder stop];
}

- (void)chatToolBarDidCancleAudioRecording:(ChatToolBar *)bar
{
    [self.audioRecorder cancel];
}
@end
