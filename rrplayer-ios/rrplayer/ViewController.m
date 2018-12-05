//
//  ViewController.m
//  rrplayer
//
//  Created by helei on 2018/11/30.
//  Copyright © 2018 何磊. All rights reserved.
//

#import "ViewController.h"
#import "RRVideoRender.h"
@interface ViewController ()

//
//@property (nonatomic, strong) EAGLContext *context;
//@property (nonatomic, strong) GLKBaseEffect *baseEffect;
//@property (nonatomic, strong) CAEAGLLayer * layer;

@property (nonatomic, strong) RRVideoRender * render;

@end
//
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _render = [[RRVideoRender alloc]initWithView:self.view];
    unsigned char * y = malloc(320*480);
    memset(y, 100, 320*480);
    [self.render drawYuv:y u:y v:y w:320 h:480];
}



@end
