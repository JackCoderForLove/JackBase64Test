//
//  ViewController.m
//  JackAnimation
//
//  Created by 李策 on 16/3/23.
//  Copyright © 2016年 app.yasn.com. All rights reserved.
//

#import "ViewController.h"
#import "Helper.h"

@interface ViewController ()

@property (strong,nonatomic) UIImageView * imgView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //测试一下子把
    //哗啦啦啦
    //飞一边
    //调用动画
    [self jackAnimation];
    //调用加密解密示例
  //  [self base64Use];
    [self base64Use2];


    // Do any additional setup after loading the view, typically from a nib.
}
- (void)jackAnimation
{
    UIImageView * img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    img.center = self.view.center;
    img.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"2" ofType:@"jpg"]];
    [self.view addSubview:img];
    self.imgView = img;
    [self stop];
    //    img.transform = CGAffineTransformMakeScale(1.0f, 1.0f);//将要显示的view按照正常比例显示出来
    //    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //InOut 表示进入和出去时都启动动画
    //    [UIView setAnimationDuration:2.0f];//动画时间
    //     img.transform=CGAffineTransformMakeScale(0.5f, 0.5f);
    //
    //    //img.transform=CGAffineTransformMakeScale(0.01f, 0.01f);//先让要显示的view最小直至消失
    //    [UIView setAnimationDelegate:self];
    //    [UIView setAnimationDidStopSelector:@selector(stop)];
    //    [UIView commitAnimations]; //启动动画

}
- (void)stop
{
    CABasicAnimation * scale = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scale.fromValue = [NSNumber numberWithFloat:0.0];
    scale.toValue = [NSNumber numberWithFloat:1.5];
    scale.duration = 5.0f;
    scale.removedOnCompletion = NO;
    scale.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

    CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
   // animation.repeatCount = 10;
    animation.toValue = [NSNumber numberWithFloat:(5 * M_PI)];
    animation.duration = 5.0f;
    animation.cumulative  = YES;
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.autoreverses = YES;
    group.duration = 10.0f;
   [group setAnimations:[NSArray arrayWithObjects:scale,animation, nil]];
    
    [self.imgView.layer addAnimation:group forKey:@"jack"];
//    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
//        [UIView beginAnimations:@"baga" context:UIGraphicsGetCurrentContext()];
//        
//        
//    } completion:^(BOOL finished)
//     {
//         
//         [self.imgView removeFromSuperview];
//     }];
  

}

//未封装的用法
- (void)base64Use
{
    //源字符串
    NSString * jcStr = @"哈哈哈哈你好啊小伙伴";
    NSLog(@"源字符串为:-----%@",jcStr);
    
    //进行base64加密
    //将字符串转为NSData
    NSData * jcSecretData = [jcStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"普通base64转码之后的data-----%@",jcSecretData);
    //压缩
    NSData * zipData = [Helper compressData:jcSecretData];
    NSLog(@"压缩之后的data-----%@",zipData);
    
    //将nsdata进行base64加密
    NSString * jcSecretStr = [zipData base64EncodedStringWithOptions:0];
    NSLog(@"普通base64加密后的字符串为:-----%@",jcSecretStr);
    
    
    //普通base64解密
    //将base64加密的字符串转为data类型
    
    NSData * base64Data = [[NSData alloc]initWithBase64EncodedString:jcSecretStr options:0];
    NSLog(@"普通base64解密后的data为:-----%@",base64Data);
    //将编码之后的data进行解压
    NSData * unzipData = [Helper uncompressZippedData:base64Data];
    NSLog(@"普通base64解密并解压后的data为:-----%@",base64Data);
    
    //将base64加密的data解密，并转为nsstring
    NSString * unSecretStr = [[NSString alloc]initWithData:unzipData encoding:NSUTF8StringEncoding];
    NSLog(@"普通base64解密之后的字符串-----%@",unSecretStr);
    
    //    //这种方法不可行，因为这只是单纯地字符串转为nsdata类型，并没有按照base64进行编码
    //    NSData * strData = [jcSecretStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSLog(@"普通base64解密之后的data2-----%@",strData);
    //
    //    NSString * unSecretStr2 = [[NSString alloc]initWithData:strData encoding:NSUTF8StringEncoding];
    //    NSLog(@"普通base64解密之后的字符串2-----%@",unSecretStr2);
    //
    //    //将nsdata用base64加密，转为nsdata
    //    NSData * jcbase64Data = [jcSecretData base64EncodedDataWithOptions:0];
    //    NSLog(@"普通base64加密之后的data3-----%@",jcbase64Data);
    //
    //    //将base64 data转换为解码的data
    //    NSData * jcjiemaData = [jcbase64Data initWithBase64EncodedData:jcbase64Data options:0];
    //      NSLog(@"普通base64解密之后的data3-----%@",jcbase64Data);
    //
    //    NSString * unSecretStr3 = [[NSString alloc]initWithData:jcjiemaData encoding:NSUTF8StringEncoding];
    //    NSLog(@"普通base64解密之后的字符串3-----%@",unSecretStr3);

}
//封装base加密用法
- (void)base64Use2
{
    //创建一个字符串
    NSString * jcStr = @"神龙无敌大将，你是无敌的";
    NSLog(@"源字符串:---%@",jcStr);
    //进行普通base64加密
    NSString * base64EnCommonStr = [Helper jackBase64Encode:jcStr];
    NSLog(@"普通加密之后的字符串:---%@",base64EnCommonStr);
    //解密后的字符串
    NSString * base64DecCommonStr = [Helper jackBase64Decode:base64EnCommonStr];
    NSLog(@"普通解密之后的字符串:---%@",base64DecCommonStr);
    
    
    
    //高级base64加密
    NSData * jcData = [jcStr dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"转换之后的data:---%@",jcData);
    //高级base64加密
    NSString * base64EnStr = [Helper base64Encode:jcData];
    NSLog(@"高级base64加密之后的字符串：---%@",base64EnStr);
    //高级base64解密
    NSData * base64DecData = [Helper base64Decode:base64EnStr];
    NSLog(@"高级base64解密之后的data：---%@",base64DecData);
    NSString * base64DecStr = [[NSString alloc]initWithData:base64DecData encoding:NSUTF8StringEncoding];
    NSLog(@"高级base64解密之后的字符串：---%@",base64DecStr);

    


    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
