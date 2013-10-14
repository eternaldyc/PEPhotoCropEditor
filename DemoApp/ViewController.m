//
//  ViewController.m
//  PEPhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/22.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "ViewController.h"
#import "PECropViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@property (nonatomic) UIPopoverController *popover;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.editButton.enabled = !!self.imageView.image;   //若没有图片，则使编辑按钮变灰
}

- (void)viewDidUnload
{
    self.editButton = nil;  //资源回收，对应上面property的部分
    self.imageView = nil;
    self.cameraButton = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

#pragma mark -
// finish键对应的操作
- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL]; //裁减后裁减VIEW消失
    self.imageView.image = croppedImage;    //更新imageView中的图片
}
//cancel键对应的操作
- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];//取消后后裁减VIEW消失
}

#pragma mark -
//打开编辑框
- (IBAction)openEditor:(id)sender
{
    PECropViewController *controller = [[PECropViewController alloc] init];//初始化一个PECropViewController
    controller.delegate = self; //用ViewController作为delegate
    controller.image = self.imageView.image;//将显示的图片传给controller以便编辑
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];//初始化一个导航控制器，并用自己实现的PECropViewController来初始化。
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;//如果是iPad要设置一下navigationControllerde 显示方式，此处是按表格形式
    }
    
    [self presentViewController:navigationController animated:YES completion:NULL];
}
//按下选图片键的按钮
- (IBAction)cameraButtonAction:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Photo Album", nil), nil];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {//在调用摄像头之前都要加入这句话
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Camera", nil)];//添加使用摄像头按钮
    }
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];//添加取消按钮
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;//将最后一个按钮添加设为取消功能
    //下面定义菜单的具体呈现方式
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {//用UI_USER_INTERFACE_IDIOM来区别用户设备是iPhone还是iPad
        [actionSheet showFromBarButtonItem:self.cameraButton animated:YES];// 如果是Pad就调用BarButtonItem，从相机按钮展开菜单
    } else {
        [actionSheet showFromToolbar:self.navigationController.toolbar];//如果是Phone就从导航控制器展开菜单
    }
}

- (void)showCamera
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];   //声明一个图像采集控制器
    controller.delegate = self; //以当前的ViewController作为delegate
    controller.sourceType = UIImagePickerControllerSourceTypeCamera;//以相机作为资源类型
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {//如果是iPad，考虑用popover来呈现选照片的功能
        if (self.popover.isPopoverVisible) {    //如果Popover处于弹出状态
            [self.popover dismissPopoverAnimated:NO]; //直接将其关闭
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];//新建popoverController，用新建的图像采集控制器(UIImagePickerController)初始化。
        [self.popover presentPopoverFromBarButtonItem:self.cameraButton //设置popover的锚点对象
                             permittedArrowDirections:UIPopoverArrowDirectionAny//可以强行设置popover的位置，此处设为系统自动选择
                                             animated:YES];
    } else {//如果是iPhone，则考虑用ViewController直接呈现图像采集控制器（UIImagePickerController）
        [self presentViewController:controller animated:YES completion:NULL];
    }
}
//打开相册
- (void)openPhotoAlbum
{
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];//同上面函数
    controller.delegate = self;//同上面函数
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//此处改成以相册作为资源
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {//对于iPad、iPhone分别操作，具体同上面函数
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        self.popover = [[UIPopoverController alloc] initWithContentViewController:controller];
        [self.popover presentPopoverFromBarButtonItem:self.cameraButton
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
    } else {
        [self presentViewController:controller animated:YES completion:NULL];
    }
}

#pragma mark -
//定义actionSheet的具体操作
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex    //传入的参数是按钮的index号
{
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];  //获取按钮的名称
    if ([buttonTitle isEqualToString:NSLocalizedString(@"Photo Album", nil)]) { //用按钮的名称，选择操作！点击photoAlbum执行openPhotoAlbum（）来获取图片
        [self openPhotoAlbum];
    } else if ([buttonTitle isEqualToString:NSLocalizedString(@"Camera", nil)]) {//点击Camera，调用通过摄像头来获取图片
        [self showCamera];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info  //重新自定义图片获取控制器
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];//从info中读取原图片
    self.imageView.image = image;   //并将读取的图片放到imageView上进行显示
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) { //如果是iPad,记得要先将popover取消显示，再做其他事情
        if (self.popover.isPopoverVisible) {
            [self.popover dismissPopoverAnimated:NO];
        }
        
        [self openEditor:nil];//将实例化的openEditor实例回收
    } else {
        [picker dismissViewControllerAnimated:YES completion:^{
            [self openEditor:nil];  //将实例化的openEditor实例回收
        }];
    }
}

@end
