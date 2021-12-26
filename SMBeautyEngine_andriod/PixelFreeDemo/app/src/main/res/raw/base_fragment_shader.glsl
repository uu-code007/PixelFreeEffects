#extension GL_OES_EGL_image_external : require
precision mediump float;
uniform samplerExternalOES uTextureSampler;
varying vec2 vTextureCoord;
void main()
{
    vec4 vCameraColor = texture2D(uTextureSampler, vTextureCoord);
    gl_FragColor = vec4(vCameraColor.r, vCameraColor.g, vCameraColor.b, 1.0);
}
