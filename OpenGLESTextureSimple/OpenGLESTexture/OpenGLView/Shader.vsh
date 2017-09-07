
attribute vec3 vPosition;
attribute vec2 vTexCoord;

varying vec2 TexCoord;

void main()
{
    gl_Position = vec4(vPosition, 1.0);
    TexCoord = vTexCoord;
}

