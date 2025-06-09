#ifndef GL_H
#define GL_H

const char* DEFAULT_VERTEX_SHADER = R"(
    attribute vec4 position;
    attribute vec4 inputTextureCoordinate;
    varying vec2 textureCoordinate;
    void main() {
        gl_Position = position;
        textureCoordinate = inputTextureCoordinate.xy;
    }
)";

const char* DEFAULT_FRAGMENT_SHADER = R"(
    varying vec2 textureCoordinate;
    uniform sampler2D inputImageTexture;
    void main() {
        gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
    }
)";

#endif // GL_H 