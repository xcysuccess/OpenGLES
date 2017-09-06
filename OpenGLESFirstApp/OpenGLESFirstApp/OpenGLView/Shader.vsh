
attribute vec3 vPosition;
attribute vec3 vInputColor;

varying vec3 ourColor;

void main()
{
    gl_Position = vec4(vPosition, 1.0);
    ourColor = vInputColor;
}
