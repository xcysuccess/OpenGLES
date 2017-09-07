
precision mediump float;

uniform sampler2D ourTexture; // 在OpenGL程序代码中设定这个变量
varying vec2 TexCoord;

void main()
{
    gl_FragColor = texture2D(ourTexture,TexCoord);
}

