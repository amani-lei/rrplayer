//
//  RRVideoRender.h
//  rrplayer
//
//  Created by helei on 2018/11/30.
//  Copyright © 2018 何磊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
//NS_ASSUME_NONNULL_BEGIN

@interface RRVideoRender : UIView
- (id) init;
- (id) initWithView :(UIView *)view;
- (void) checkGlError: (const char*) op;
- (void) initRenderBuffer;
- (void) initFrameBuffer;
- (GLuint) buildShader :(const char *)shaderSrc shaderType:(GLenum)shaderType;
- (GLuint) buildProgram :(const char *) vertexShaderSrc fragmentShaderSrc:(const char*)fragmentShaderSrc;
- (GLuint)buildTexture:(GLuint)texture data:(unsigned char *)data width:(int)width height:(int)height;
//- (void)setupRenderBuffer;
- (void) drawYuv :(unsigned char *)y u:(unsigned char *)u v:(unsigned char *)v w:(int)width h:(int)height;
@end

//NS_ASSUME_NONNULL_END
