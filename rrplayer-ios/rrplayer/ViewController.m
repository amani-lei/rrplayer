//
//  ViewController.m
//  rrplayer
//
//  Created by helei on 2018/11/30.
//  Copyright © 2018 何磊. All rights reserved.
//

#import "ViewController.h"
#import "RRVideoRenderView.h"
@interface ViewController ()

//
//@property (nonatomic, strong) EAGLContext *context;
//@property (nonatomic, strong) GLKBaseEffect *baseEffect;
//@property (nonatomic, strong) CAEAGLLayer * layer;

@property (nonatomic, strong) RRVideoRenderView * render;

@end
//
@implementation ViewController
{
    FILE * file;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _render = [[[RRVideoRenderView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)] init];
    [self.view addSubview:_render];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(draw)];
    [self.view addGestureRecognizer:tap];
}

- (void)draw {
    static i = 0;
    int w = 4,h=480;
    static unsigned char * y = NULL;
    static unsigned char * u = NULL;
    static unsigned char * v = NULL;
    if(y == NULL){
        y = malloc(w*h);
        u = malloc(w*h);
        v = malloc(w*h);
    }
    i++;
    memset(y, i%255, w*h);
    memset(u, 100, w*h);
    memset(v, 100, w*h);
    [self.render drawYuv:y u:u v:v width:w height:h];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self draw];
    });
}



@end
