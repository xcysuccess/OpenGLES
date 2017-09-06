//
//  XXOpenGLView.m
//  OpenGLESFirstApp
//
//  Created by tomxiang on 2017/9/5.
//  Copyright © 2017年 tomxiang. All rights reserved.
//

#import "XXOpenGLView.h"
#import "GLSLUtils.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

GLfloat vertices[] = {
    // 位置              // 颜色
    0.0f,  0.5f, 0.0f,  1.0, 0.0, 0.0,
    -0.5f, -0.5f, 0.0f, 0.0, 1.0, 0.0,
    0.5f,  -0.5f, 0.0f, 0.0, 0.0, 1.0 };

@interface XXOpenGLView()
{
    CAEAGLLayer *_eaglLayer;    //提供了一个OpenGLES渲染环境
    EAGLContext *_context;      //渲染上下文，管理所有使用OpenGL ES 进行描绘的状态、命令以及资源信息
    GLuint _colorRenderBuffer;  //颜色渲染缓存
    GLuint _frameBuffer;        //帧缓存
    
    GLuint _programHandle;      //着色器程序
    GLuint _positionSlot;
    GLuint _inputColorSlot;
    
    unsigned int _VAO;

}
@end

@implementation XXOpenGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void) destoryRenderAndFrameBuffer{
    glDeleteBuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    
    glDeleteBuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)layoutSubviews {
    [self setupLayer];
    [self setupContext];
    
    [self destoryRenderAndFrameBuffer];
    
    [self setupRenderBuffer];
    [self setupFrameBuffer];
     
    [self compileShaders];

    [self initGL];
    [self render];
    
//    [self renderNOVAOVBO];
}

- (void) setupLayer{
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;                //默认透明,不透明度是
    
    //kEAGLDrawablePropertyRetainedBacking:表示是否要保持呈现的内容不变，默认为NO
    //设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking:@(NO),
                                      kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                                      };
}

- (void) setupContext{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if(!_context){
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    //设置成当前上下文
    if(![EAGLContext setCurrentContext:_context]){
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

//缓冲区分为三种-1.模板缓冲区 2.颜色缓冲区 3.深度缓冲区 ，RenderBuffer是指颜色缓冲区
- (void) setupRenderBuffer{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    //为color分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void) setupFrameBuffer{
    glGenRenderbuffers(1, &_frameBuffer);
    //设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    //将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
}
- (void) compileShaders{
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    NSString *fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    
    //Create Program, attach shaders,compile and link program
    _programHandle = [[GLSLUtils sharedInstance] loadProgramWithVertexFilePath:vertexShaderPath FragmentFilePath:fragmentShaderPath];
    if(_programHandle == 0){
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    //Get attribute slot from program
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    _inputColorSlot = glGetAttribLocation(_programHandle, "vInputColor");
    
    //Get fragmentColor from program
    int vertexColorLocation = glGetUniformLocation(_programHandle, "testColor");
    glUseProgram(_programHandle);
    glUniform4f(vertexColorLocation, 0.0f, 1.0, 0.0f, 1.0f);
}

- (void)initGL {
    unsigned int VBO;
    glGenVertexArraysOES(1, &_VAO);
    glGenBuffers(1, &VBO);
    //1. 绑定VAO
    glBindVertexArrayOES(_VAO);
    //2. 把顶点数组复制到缓冲中供OpenGL使用
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    //3. 设置顶点属性指针
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttribPointer(_inputColorSlot,3,GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3* sizeof(float)));
    glEnableVertexAttribArray(_inputColorSlot);
    
    glBindVertexArrayOES(0);
}

- (void) render{
    glClearColor(0.2, 0.3, 0.3, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    // Setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    glUseProgram(_programHandle);
    
    glBindVertexArrayOES(_VAO);
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderNOVAOVBO
{
    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup viewport
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);

    // Load the vertex data
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}
@end
