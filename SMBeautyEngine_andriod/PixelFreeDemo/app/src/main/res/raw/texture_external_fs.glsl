#extension GL_OES_EGL_image_external : require
precision mediump float;
uniform samplerExternalOES u_tex;
varying vec2 v_tex_coord;
void main()
{
    vec4 vCameraColor = texture2D(u_tex, v_tex_coord);
    gl_FragColor = vec4(vCameraColor.r, vCameraColor.g, vCameraColor.b, 1.0);
}
