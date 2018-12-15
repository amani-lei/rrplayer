//
//  RRVideoRenderView.m
//  rrplayer
//
//  Created by helei on 2018/12/5.
//  Copyright © 2018 何磊. All rights reserved.
//

#import "RRVideoRenderView.h"
#import <GLKit/GLKit.h>
#define TEXTURE_INDEX_Y 0
#define TEXTURE_INDEX_Y 0
#define TEXTURE_INDEX_Y 0

@interface RRVideoRenderView ()

@property (assign,nonatomic) GLuint texY;       //上下文
@property (assign,nonatomic) GLuint texU;       //上下文
@property (assign,nonatomic) GLuint texV;       //上下文
@property (assign,nonatomic) GLuint frameBuffer;        //缓存buf区
@property (assign,nonatomic) GLuint renderBuffer;       //渲染buf区
@property (assign,nonatomic) GLuint program;//程序集句柄。
@property (assign,nonatomic) GLuint width;
@property (assign,nonatomic) GLuint height;

@property (strong,nonatomic) EAGLContext * glContext;       //上下文
@property (strong,nonatomic) CAEAGLLayer * glLayer;     //画布

@end

@implementation RRVideoRenderView


+ (Class)layerClass{
    return [CAEAGLLayer class];
}

- (id)init{
    [self initLayer];
    [self initContext];
    [self initShader];
    [self initTexture];
    return self;
}



- (void)initOpengl{
    
}

- (void)initLayer{
    self.glLayer = (CAEAGLLayer*) self.layer;
    self.glLayer.opaque = true;
    self.glLayer.drawableProperties = @{
                                        kEAGLDrawablePropertyRetainedBacking :[NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyColorFormat : kEAGLColorFormatRGBA8
                                        };
}

- (void)initContext{
    self.glContext = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(self.glContext == nil){
        
    }
    [EAGLContext setCurrentContext:self.glContext];
}

- (void)initTexture{
    NSLog(@"%d", glGetError());
    if(self.texY){
        glDeleteTextures(1, &_texY);
    }
    if(self.texU){
        glDeleteTextures(1, &_texU);
    }
    if(self.texV){
        glDeleteTextures(1, &_texV);
    }
    glGenTextures(1, &_texY);
    glGenTextures(1, &_texU);
    glGenTextures(1, &_texV);
    
    
    //分别对Y,U,V进行设置。
    
    //Y
    //glActiveTexture:选择可以由纹理函数进行修改的当前纹理单位
    //并绑定
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.texY);
    //纹理过滤
    //GL_LINEAR 线性取平均值纹素，GL_NEAREST 取最近点的纹素
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);//放大过滤。
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);//缩小过滤
    //纹理包装
    //包装模式有：GL_REPEAT重复，GL_CLAMP_TO_EDGE采样纹理边缘，GL_MIRRORED_REPEAT镜像重复纹理。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//纹理超过S轴
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//纹理超过T轴
    
    
    //U
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.texU);
    //纹理过滤
    //GL_LINEAR 线性取平均值纹素，GL_NEAREST 取最近点的纹素
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);//放大过滤。
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);//缩小过滤
    NSLog(@"%d", glGetError());
    //纹理包装
    //包装模式有：GL_REPEAT重复，GL_CLAMP_TO_EDGE采样纹理边缘，GL_MIRRORED_REPEAT镜像重复纹理。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//纹理超过S轴
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//纹理超过T轴
    NSLog(@"%d", glGetError());
    
    //V
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.texV);
    //纹理过滤
    //GL_LINEAR 线性取平均值纹素，GL_NEAREST 取最近点的纹素
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);//放大过滤。
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);//缩小过滤
    //纹理包装
    //包装模式有：GL_REPEAT重复，GL_CLAMP_TO_EDGE采样纹理边缘，GL_MIRRORED_REPEAT镜像重复纹理。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//纹理超过S轴
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//纹理超过T轴
}

- (void)initShader{
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    NSString * vertex_shader_path = [[NSBundle mainBundle] pathForResource:@"render_yuv" ofType:@"vert"];
    NSString * fragment_shader_path = [[NSBundle mainBundle] pathForResource:@"render_yuv" ofType:@"frag"];
    //读取编译shader
    //顶点shader
    GLuint vertexShader = [self compileShader:vertex_shader_path withType:GL_VERTEX_SHADER];
    //片元shader
    GLuint fragmentShader = [self compileShader:fragment_shader_path withType:GL_FRAGMENT_SHADER];
    //创建程序
    self.program = glCreateProgram();
    //向program中添加顶点着色器
    glAttachShader(self.program, vertexShader);
    //向program中添加片元着色器
    glAttachShader(self.program, fragmentShader);
    //绑定position属性到顶点着色器的0位置，绑定TexCoordIn到顶点着色器的1位置
    glBindAttribLocation(self.program, 0, "position");
    glBindAttribLocation(self.program, 1, "TexCoordIn");
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    //链接程序
    glLinkProgram(self.program);
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    //删除
    if (vertexShader)   glDeleteShader(vertexShader);
    if (fragmentShader) glDeleteShader(fragmentShader);
    //从片元着色器中获取到Y,U,V变量。
    GLuint textureUniformY = glGetUniformLocation(self.program, "SamplerY");
    GLuint textureUniformU = glGetUniformLocation(self.program, "SamplerU");
    GLuint textureUniformV = glGetUniformLocation(self.program, "SamplerV");
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    glUseProgram(self.program);
    //分别设置为0，1，2.
    glUniform1i(textureUniformY, 0);
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    glUniform1i(textureUniformU, 1);
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    glUniform1i(textureUniformV, 2);
    NSLog(@"%d(line:%d\n)", glGetError(), __LINE__);
    
}

- (GLuint)compileShader:(NSString*)path withType:(GLuint)type{
    //创建shader句柄
    GLuint shaderHandle = glCreateShader(type);
    
    //读取文件内容
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    const GLchar* source = (GLchar *)[content UTF8String];
    
    //将文件内容设置给shader
    glShaderSource(shaderHandle, 1,&source,NULL);
    //编译shader
    glCompileShader(shaderHandle);
    GLint compileSuccess;
    //获取状态
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)drawYuv:(unsigned char *)y u:(unsigned char *)u v:(unsigned char *)v width:(int)width height:(int)height{
    @synchronized(self){
        //设置着色器属性
        [self setVertexAttributeWidth:width height:height];
        
        /*定义2d图层
         之所以要定义，是因为
         glTexSubImage2D:定义一个存在的一维纹理图像的一部分,但不能定义新的纹理
         glTexImage2D:   定义一个二维的纹理图
         所以每次宽高变化的时候需要调用glTexImage2D重新定义一次
         */
        [self image2DdefineWidth:width height:height];
        
        
        //设置width，height
        [self setWidth:width height:height];
        
        //YUV420p 4个Y对应一套UV，平面结构。 YUV的分布：YYYYUV。Y在一开始。长度等于点数，即宽高的积。
        glBindTexture(GL_TEXTURE_2D, self.texY);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, GL_LUMINANCE, GL_UNSIGNED_BYTE, y);
        //U在Y之后，长度等于点数的1/4，即宽高的积的1/4。
        glBindTexture(GL_TEXTURE_2D, self.texU);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width/2, height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, u);
        //V在U之后，长度等于点数的1/4，即宽高的积的1/4。
        glBindTexture(GL_TEXTURE_2D, self.texV);
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width/2, height/2, GL_LUMINANCE, GL_UNSIGNED_BYTE, v);
        [self render];
    }
}
- (void)setWidth:(GLuint)width height:(GLuint)height {
    if (self.width == width && self.height == height) {
        return;
    }
    //取宽高。
    self.width = width;
    self.height = height;
}

// 默认屏幕
- (void)image2DdefineWidth:(GLuint)width  height:(GLuint)height{
    if (self.width == width&&self.height == height) {
        return;
    }
    //根据宽高生成空的YUV数据
    void *blackData = malloc(width * height * 1.5);
    //全部填0，实际出来的是一张绿色的图- -；但是没有去渲染就直接替换了，所以不会造成影响。只起定义作用。
    if(blackData) memset(blackData, 0x0, width * height * 1.5);
    
    
    /*
     
     GL_APIENTRY glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels);
     
     //target参数用于定义二维纹理；
     //如果提供了多种分辨率的纹理图像，可以使用level参数，否则level设置为0；
     //internalformat确定了哪些成分(RGBA, 深度, 亮度和强度)被选定为图像纹理单元
     //width和height表示纹理图像的宽度和高度；
     //border参数表示边框的宽度
     //format和type参数描述了纹理图像数据的格式和数据类型
     //pixels参数包含了纹理图像的数据，这个数据描述了纹理图像本身和它的边框
     
     */
    
    //Y
    glBindTexture(GL_TEXTURE_2D, self.texY);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, blackData);
    //U
    glBindTexture(GL_TEXTURE_2D, self.texU);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width/2, height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, blackData + width * height);
    //V
    glBindTexture(GL_TEXTURE_2D, self.texV);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width/2, height/2, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, blackData + width * height * 5 / 4);
    
    free(blackData);
    
}

- (void)render {
    
    /*
     glDrawArrays 根据顶点数组中的坐标数据和指定的模式，进行绘制。
     glDrawArrays (GLenum mode, GLint first, GLsizei count);
     mode，绘制方式
     GL_TRIANGLES:
     第一次取1，2，3，第二次取4，5，6，以此类推，不足三个就停止。
     
     GL_TRIANGLE_STRIP:
     从第一个开始取前三个1，2，3，第二次从第二开始取2，3，4，以此类推到不足3个停止。
     
     GL_TRIANGLE_FAN:
     从第一个开始取，1，2，3，第二次的第二个坐标从3开始，1，3，4，以此类推，到不足三个停止。
     
     first，从数组缓存中的哪一位开始绘制，一般为0。
     count，数组中顶点的数量。
     */
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [self.glContext presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setVertexAttributeWidth:(GLuint)width height:(GLuint)height {
    
    if (self.width == width && self.height == height) {
        return;
    }
    
    CGSize size = self.bounds.size;
    //视口变换函数
    /*
     glViewPort(x:GLInt;y:GLInt;Width:GLSizei;Height:GLSizei);
     其中，参数X，Y指定了视见区域的左下角在窗口中的位置
     Width和Height指定了视见区域的宽度和高度。注意OpenGL使用的窗口坐标和WindowsGDI使用的窗口坐标是不一样的
     */
    glViewport(1, 1, size.width, size.height);
    
    
    //以屏幕中心为原点。
    /*
     这里的排布 按三个点确定一个面原则。
     由GL_TRIANGLE_STRIP定义：
     
     先取前三个坐标组成一个三角形。
     再取除了去掉第一个坐标，剩下的组成一个三角形。
     
     这样组成一个矩形最少需要4个坐标，并且排序规则为相邻的三个点第一个点为第四个点的对角。
     */
    
    //这个是用于传给顶点着色器的坐标。
    static const GLfloat squareVertices[] = {
        -1.0f,-1.0f,  //左下角。
        1.0f ,-1.0f,  //右下角。
        -1.0f,1.0f,   //左上角
        1.0f ,1.0f,   //右上角
    };
    
    //这个是用于传给片元着色器的坐标，由顶点着色器代传。
    //由于图像的存放一般是以左上角为原点，从上到下，但是OpenGL的处理是从左下角由下到上，所以图像的上下是颠倒的。
    //所以需要把其中一个坐标的上下改为相反的。左右不用换，不然左右又不对了。
    static const GLfloat coordVertices[] = {
        0.0f, 1.0f,   //左上角
        1.0f, 1.0f,   //右上角
        0.0f, 0.0f,   //左下角
        1.0f, 0.0f,   //右下角
    };
    
    
    /*激活顶点着色器属性*/
    glEnableVertexAttribArray(0);
    glEnableVertexAttribArray(1);
    
    //设置顶点着色器的属性。如果视图不变化，就不用变。
    /*
     GL_APIENTRY glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr)
     
     indx       着色器代码对应变量ID
     size       此类型数据的个数
     type       数据类型
     normalized 是否对非float类型数据转化到float时候进行归一化处理
     stride     此类型数据在数组中的重复间隔宽度，byte类型计数，0为紧密排布。
     ptr        数据指针， 这个值受到VBO的影响
     */
    glVertexAttribPointer(0, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(1, 2, GL_FLOAT, 0, 0, coordVertices);
    
}


- (void)layoutSubviews {
    [self destoryFrameAndRenderBuffer];
    [self bufferCreate];
}


- (BOOL)bufferCreate {
    
    //生成framebuffer和renderbuffer
    glGenFramebuffers(1, &_frameBuffer);
    glGenRenderbuffers(1, &_renderBuffer);
    
    //绑定到OpenGL
    glBindFramebuffer(GL_FRAMEBUFFER, self.frameBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, self.renderBuffer);
    //关联gl上下文和view layer
    if (![self.glContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.glLayer]) {
        NSLog(@"attach渲染缓冲区失败");
    }
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, self.renderBuffer);
    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"创建缓冲区错误 0x%x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    return YES;
}

- (void)destoryFrameAndRenderBuffer{
    if (self.frameBuffer){
        glDeleteFramebuffers(1, &_frameBuffer);
        self.frameBuffer = 0;
    }
    
    if (self.renderBuffer){
        glDeleteRenderbuffers(1, &_renderBuffer);
        self.renderBuffer = 0;
    }
}

@end
