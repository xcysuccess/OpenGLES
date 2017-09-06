
precision highp float;
uniform vec4 testColor; // 在OpenGL程序代码中设定这个变量
varying highp vec3 ourColor;

void main()
{
//    gl_FragColor = testColor;
    gl_FragColor = vec4(ourColor,1.0);
}
