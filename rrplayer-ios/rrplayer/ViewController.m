//
//  ViewController.m
//  rrplayer
//
//  Created by helei on 2018/11/30.
//  Copyright © 2018 何磊. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) CAEAGLLayer * layer;

@end
//
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    GLKView * view = (GLKView*)self.view;
    _layer = (CAEAGLLayer *) self.view.layer;
    self.context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    view.context = self.context;
    [EAGLContext setCurrentContext:view.context];
    self.baseEffect = [[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor = GL_TRUE;
    self.baseEffect.constantColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
}

- (void)setupRenderBuffer {
    GLuint render_buffer;
    glGenRenderbuffers(1, &render_buffer);
    glBindRenderbuffer(GL_RENDERBUFFER, render_buffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_layer];
}

@end
