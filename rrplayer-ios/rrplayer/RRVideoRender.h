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

@interface RRVideoRender : NSObject
- (id) init;
- (GLuint) buildShader :(const char *)shaderSrc shaderType:(GLenum)shaderType;
- (GLuint) buildProgram :(const char *) vertexShaderSrc fragmentShaderSrc:(const char*)fragmentShaderSrc;
@end

//NS_ASSUME_NONNULL_END
