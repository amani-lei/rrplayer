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
@property (nonatomic, assign) GLuint texY;
@property (nonatomic, assign) GLuint texU;
@property (nonatomic, assign) GLuint texV;

@property (nonatomic, assign) GLuint width;
@property (nonatomic, assign) GLuint height;

@property (nonatomic, assign) GLuint renderBuffer;
@property (nonatomic, assign) GLuint frameBuffer;

@property (nonatomic, strong) EAGLContext * glContext;
@property (nonatomic, strong) GLKView * drawLayer;


@end

@implementation RRVideoRender
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (id) init{
    self = [super init];
    self.program = [self buildProgram:"" fragmentShaderSrc:""];
    return self;
}

- (id)initWithView:(UIView *)view {
    //创建一个openglview
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    self.glContext = [[EAGLContext alloc]initWithAPI:api];
    [EAGLContext setCurrentContext:self.glContext];
    
//    self.glView = [[GLKView alloc]init];
//    [self.glView setContext:self.glContext];
//    self.glView.frame = CGRectMake(20, 20, 200, 300);
//    //self.glView.backgroundColor = UIColor.blueColor;
//
//    [view addSubview:self.glView];
    
    [self initRenderBuffer];
    [self initFrameBuffer];
    glGenTextures(1, &_texY);
    [self checkGlError: "glGenTextures"];
    glGenTextures(1, &_texU);
    [self checkGlError: "glGenTextures"];
    glGenTextures(1, &_texV);
    [self checkGlError: "glGenTextures"];
    
    static const char* VERTEX_SHADER =
    "attribute vec4 vPosition;    \n"
    "attribute vec2 a_texCoord;   \n"
    "varying vec2 tc;     \n"
    "void main()                  \n"
    "{                            \n"
    "   gl_Position = vPosition;  \n"
    "   tc = a_texCoord;  \n"
    "}                            \n";
    
    
    static const char* FRAG_SHADER =
    "varying lowp vec2 tc;\n"
    "uniform sampler2D SamplerY;\n"
    "uniform sampler2D SamplerU;\n"
    "uniform sampler2D SamplerV;\n"
    "void main(void)\n"
    "{\n"
    "mediump vec3 yuv;\n"
    "lowp vec3 rgb;\n"
    "yuv.x = texture2D(SamplerY, tc).r;\n"
    "yuv.y = texture2D(SamplerU, tc).r - 0.5;\n"
    "yuv.z = texture2D(SamplerV, tc).r - 0.5;\n"
    "rgb = mat3( 1,   1,   1,\n"
    "0,       -0.39465,  2.03211,\n"
    "1.13983,   -0.58060,  0) * yuv;\n"
    "gl_FragColor = vec4(rgb, 1);\n"
    "}\n";
    
    self.program = [self buildProgram:VERTEX_SHADER fragmentShaderSrc:FRAG_SHADER];
    return self;
}

- (void) checkGlError: (const char*) op{
    GLint error;
    for (error = glGetError(); error; error = glGetError()) {
        printf("error::after %s() glError (0x%x)\n", op, error);
    }
}

- (void) initRenderBuffer{
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    //为render buffer分配存储空间
    //[self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.glView.layer];
}

- (void) initFrameBuffer{
//    GLuint framebuffer;
//    glGenFramebuffers(1, &framebuffer);
//    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
//    //将之前创建的render buffer附着到frame buffer作为其logical buffer
//    //GL_COLOR_ATTACHMENT0指定第一个颜色缓冲区附着点
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
//                              GL_RENDERBUFFER, self.renderBuffer);
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
                    free(buf);
                }
                glDeleteShader(shaderHandle);
                shaderHandle = 0;
            }
        }
    }
    return shaderHandle;
}

- (GLuint)buildTexture:(GLuint)texture data:(unsigned char *)data width:(int)width height:(int)height {
    glBindTexture ( GL_TEXTURE_2D, texture);
    [self checkGlError: "glBindTexture"];
    glTexImage2D ( GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
    [self checkGlError: "glTexImage2D"];
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
    [self checkGlError: "glTexParameteri"];
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
    [self checkGlError: "glTexParameteri"];
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE );
    [self checkGlError: "glTexParameteri"];
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE );
    [self checkGlError: "glTexParameteri"];
    //glBindTexture ( GL_TEXTURE_2D, 0);
    return texture;
}

- (void) drawYuv :(unsigned char *)y u:(unsigned char *)u v:(unsigned char *)v w:(int)width h:(int)height {
    static GLfloat squareVertices[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f,  1.0f,
        1.0f,  1.0f,
    };
    static GLfloat coordVertices[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f,  0.0f,
        1.0f,  0.0f,
    };

    glClearColor(0.5f, 0.5f, 0.5f, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    glViewport(0, 0, width, height);
    int vPosition = 0, a_texCoord = 1;
    //设置着色器变量    
    glBindAttribLocation(self.program, vPosition, "vPosition");
    glBindAttribLocation(self.program, a_texCoord, "a_texCoord");
    
    //设置顶点数组
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    [self checkGlError: "glVertexAttribPointer"];
    glEnableVertexAttribArray(0);
    [self checkGlError: "glEnableVertexAttribArray"];
    //设置顶点数组
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, coordVertices);
    [self checkGlError: "glVertexAttribPointer"];
    glEnableVertexAttribArray(1);
    [self checkGlError: "glEnableVertexAttribArray"];
    
    //指定着色器
    glUseProgram(self.program);
    [self checkGlError: "glUseProgram"];
    
    //绑定纹理
    glActiveTexture(GL_TEXTURE0);
    [self checkGlError: "glActiveTexture"];
    [self buildTexture:self.texY data:y width:width height:height];
    glUniform1i(self.texY, 0);
    [self checkGlError: "glUniform1i"];
    
    glActiveTexture(GL_TEXTURE1);
    [self checkGlError: "glActiveTexture"];
    [self buildTexture:self.texU data:u width:width/2 height:height/2];
    glUniform1i(self.texU, 1);
    [self checkGlError: "glUniform1i"];
    
    glActiveTexture(GL_TEXTURE2);
    [self checkGlError: "glActiveTexture"];
    [self buildTexture:self.texV data:v width:width/2 height:height/2];
    glUniform1i(self.texV, 2);
    [self checkGlError: "glUniform1i"];
    
    glEnable(GL_TEXTURE_2D);
    [self checkGlError: "GL_TEXTURE_2D"];
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self checkGlError: "glDrawArrays"];
}

@end
