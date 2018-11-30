//
//  RRVideoRender.m
//  rrplayer
//
//  Created by helei on 2018/11/30.
//  Copyright © 2018 何磊. All rights reserved.
//

#import "RRVideoRender.h"

@interface RRVideoRender ()

@property (nonatomic, assign) GLuint program;

@end

@implementation RRVideoRender
- (id) init{
    self = [super init];
    self.program = [self buildProgram:"" fragmentShaderSrc:""];
    return self;
}

- (GLuint) buildProgram: (const char *) vertexShaderSrc fragmentShaderSrc:(const char*)fragmentShaderSrc {
    GLuint vertexShader = [self buildShader:vertexShaderSrc shaderType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self buildShader: fragmentShaderSrc shaderType:GL_FRAGMENT_SHADER];
    GLuint programHandle = glCreateProgram();
    if (programHandle) {
        glAttachShader(programHandle, vertexShader);
        //checkGlError("glAttachShader");
        glAttachShader(programHandle, fragmentShader);
        //checkGlError("glAttachShader");
        glLinkProgram(programHandle);
        
        GLint linkStatus = GL_FALSE;
        glGetProgramiv(programHandle, GL_LINK_STATUS, &linkStatus);
        if (linkStatus != GL_TRUE) {
            GLint bufLength = 0;
            glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &bufLength);
            if (bufLength) {
                char* buf = (char*) malloc(bufLength);
                if (buf) {
                    glGetProgramInfoLog(programHandle, bufLength, NULL, buf);
                    //log_easy("error::Could not link program:\n%s\n", buf);
                    free(buf);
                }
            }
            glDeleteProgram(programHandle);
            programHandle = 0;
        }
    }
    return programHandle;
}

- (GLuint)buildShader:(const char *)shaderSrc shaderType:(GLenum)shaderType {
    GLuint shaderHandle = glCreateShader(shaderType);
    if (shaderHandle) {
        glShaderSource(shaderHandle, 1, &shaderSrc, 0);
        glCompileShader(shaderHandle);
        
        GLint compiled = 0;
        glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compiled);
        if (!compiled){
            GLint infoLen = 0;
            glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &infoLen);
            if (infoLen){
                char* buf = (char*) malloc(infoLen);
                if (buf){
                    glGetShaderInfoLog(shaderHandle, infoLen, NULL, buf);
                    //log_easy("error::Could not compile shader %d:\n%s\n", shaderType, buf);
                    free(buf);
                }
                glDeleteShader(shaderHandle);
                shaderHandle = 0;
            }
        }
    }
    
    return shaderHandle;
}

@end
