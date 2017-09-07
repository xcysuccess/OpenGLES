
attribute vec3 vPosition;
attribute vec3 vInputColor;
attribute vec2 vTexCoord;

varying vec3 ourColor;
varying vec2 TexCoord;

void main()
{
    gl_Position = vec4(vPosition, 1.0);
    ourColor = vInputColor;
    TexCoord = vec2(vTexCoord.x, 1.0 - vTexCoord.y);
}

