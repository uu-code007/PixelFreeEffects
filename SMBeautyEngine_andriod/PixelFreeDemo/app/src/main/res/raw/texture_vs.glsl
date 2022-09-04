attribute vec2 a_pos;
attribute vec2 a_tex;
varying vec2 v_tex_coord;
uniform mat4 u_mvp;
uniform mat4 u_tex_trans;
void main() {
    gl_Position = u_mvp * vec4(a_pos, 0.0, 1.0);
    v_tex_coord = (u_tex_trans * vec4(a_tex, 0.0, 1.0)).st;
}
