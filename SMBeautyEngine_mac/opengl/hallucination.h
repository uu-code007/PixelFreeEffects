//
//  hallucination.h
//  opengl
//  幻觉特效
//  Created by wlanjie on 2019/10/26.
//  Copyright © 2019 com.wlanjie.opengl. All rights reserved.
//

#ifndef hallucination_h
#define hallucination_h

#include "frame_buffer.h"
#include "gl.h"

#ifdef __ANDROID__
static const char* HALLUCINATION_VERTEX_SHADER = 
    "precision highp float;                                                                     \n"
    "attribute vec4 position;                                                                   \n"
    "attribute vec4 inputTextureCoordinate;                                                     \n"
    "varying vec2 textureCoordinate;                                                            \n"
    "varying vec2 textureCoordinate2;                                                           \n"
    "void main() {                                                                              \n"
    "   gl_Position = position;                                                                 \n"
    "   textureCoordinate = inputTextureCoordinate.xy;                                          \n"
    "   textureCoordinate2 = inputTextureCoordinate.xy * 0.5 + 0.5;                             \n"
    "}                                                                                          \n";
    
static const char* HALLUCINATION_FRAGMENT_SHADER = 
    "varying highp vec2 textureCoordinate;                                                                          \n"
    "varying highp vec2 textureCoordinate2;                                                                         \n" 
    "uniform sampler2D inputImageTexture;                                                                           \n"
    "uniform sampler2D inputImageTextureLookup;                                                                     \n"
    "uniform sampler2D inputImageTextureLast;                                                                       \n"
    "const lowp vec3 blend = vec3(0.05, 0.2, 0.5);                                                                  \n"
    "void main() {                                                                                                  \n"
    "    highp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);                                 \n"    
    "    textureColor = clamp(textureColor, 0.0, 1.0);                                                              \n"
    "    highp float blueColor = textureColor.b * 63.0;                                                             \n"
    "    highp vec2 quad1;                                                                                          \n"
    "    quad1.y = floor(floor(blueColor) / 8.0);                                                                   \n"
    "    quad1.x = floor(blueColor) - (quad1.y * 8.0);                                                              \n"
    "    highp vec2 quad2;                                                                                          \n"
    "    quad2.y = floor(ceil(blueColor) / 8.0);                                                                    \n"
    "    quad2.x = ceil(blueColor) - (quad2.y * 8.0);                                                               \n"    
    "    highp vec2 texPos1;                                                                                        \n"
    "    texPos1.x = (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);                    \n"
    "    texPos1.y = (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);                    \n"
    "    highp vec2 texPos2;                                                                                        \n"
    "    texPos2.x = (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);                    \n"
    "    texPos2.y = (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);                    \n"
    "    lowp vec4 newColor1 = texture2D(inputImageTextureLookup, texPos1);                                         \n"
    "    lowp vec4 newColor2 = texture2D(inputImageTextureLookup, texPos2);                                         \n"
    "    lowp vec4 lookupColor = mix(newColor1, newColor2, fract(blueColor));                                       \n"
    "    lowp vec4 textureColorLast = texture2D(inputImageTextureLast, textureCoordinate);                          \n"
    "    gl_FragColor = vec4(mix(textureColorLast.rgb, lookupColor.rgb, blend), textureColor.w);                    \n"
    "}                                                                                                              \n";
#else
static const char* HALLUCINATION_VERTEX_SHADER = 
    "attribute vec4 position;                                                                   \n"
    "attribute vec4 inputTextureCoordinate;                                                     \n"
    "varying vec2 textureCoordinate;                                                            \n"
    "varying vec2 textureCoordinate2;                                                           \n"
    "void main() {                                                                              \n"
    "   gl_Position = position;                                                                 \n"
    "   textureCoordinate = inputTextureCoordinate.xy;                                          \n"
    "   textureCoordinate2 = inputTextureCoordinate.xy * 0.5 + 0.5;                             \n"
    "}                                                                                          \n";
    
static const char* HALLUCINATION_FRAGMENT_SHADER = 
    "varying vec2 textureCoordinate;                                                                                \n"
    "varying vec2 textureCoordinate2;                                                                               \n" 
    "uniform sampler2D inputImageTexture;                                                                           \n"
    "uniform sampler2D inputImageTextureLookup;                                                                     \n"
    "uniform sampler2D inputImageTextureLast;                                                                       \n"
    "const vec3 blend = vec3(0.05, 0.2, 0.5);                                                                       \n"
    "void main() {                                                                                                  \n"
    "    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);                                       \n"    
    "    textureColor = clamp(textureColor, 0.0, 1.0);                                                              \n"
    "    float blueColor = textureColor.b * 63.0;                                                                   \n"
    "    vec2 quad1;                                                                                                \n"
    "    quad1.y = floor(floor(blueColor) / 8.0);                                                                   \n"
    "    quad1.x = floor(blueColor) - (quad1.y * 8.0);                                                              \n"
    "    vec2 quad2;                                                                                                \n"
    "    quad2.y = floor(ceil(blueColor) / 8.0);                                                                    \n"
    "    quad2.x = ceil(blueColor) - (quad2.y * 8.0);                                                               \n"    
    "    vec2 texPos1;                                                                                              \n"
    "    texPos1.x = (quad1.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);                    \n"
    "    texPos1.y = (quad1.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);                    \n"
    "    vec2 texPos2;                                                                                              \n"
    "    texPos2.x = (quad2.x * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.r);                    \n"
    "    texPos2.y = (quad2.y * 0.125) + 0.5 / 512.0 + ((0.125 - 1.0 / 512.0) * textureColor.g);                    \n"
    "    vec4 newColor1 = texture2D(inputImageTextureLookup, texPos1);                                              \n"
    "    vec4 newColor2 = texture2D(inputImageTextureLookup, texPos2);                                              \n"
    "    vec4 lookupColor = mix(newColor1, newColor2, fract(blueColor));                                            \n"
    "    vec4 textureColorLast = texture2D(inputImageTextureLast, textureCoordinate);                               \n"
    "    gl_FragColor = vec4(mix(textureColorLast.rgb, lookupColor.rgb, blend), textureColor.w);                    \n"
    "}                                                                                                              \n";
#endif

namespace trinity {

class Hallucination : public FrameBuffer {
 public:
    Hallucination(int width, int height) : FrameBuffer(width, height, HALLUCINATION_VERTEX_SHADER, HALLUCINATION_FRAGMENT_SHADER),
                 lookup_texture_id_(0),
                 last_texture_id_(0),
                 current_index_(0) {
        last_texture_frame_ = new FrameBuffer(512, 512, DEFAULT_VERTEX_SHADER, DEFAULT_FRAGMENT_SHADER);
    }
    
    ~Hallucination() {
        delete last_texture_frame_;
        last_texture_frame_ = nullptr;
    }
    
    void SetTextureLookupTexture(int texture_id) {
        lookup_texture_id_ = texture_id;
    }
    
    void SetTextureLast(int texture_id) {
        last_texture_id_ = texture_id;
    }
    
    virtual GLuint OnDrawFrame(GLuint texture_id, uint64_t current_time = 0) {
         if (current_index_ % 2 == 0) {
            last_texture_id_ = last_texture_frame_->OnDrawFrame(texture_id);
         }
         current_index_++;
         return FrameBuffer::OnDrawFrame(texture_id, current_time);
    }
    
 protected:
    virtual void RunOnDrawTasks() {
        if (lookup_texture_id_ > 0) {
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(GL_TEXTURE_2D, lookup_texture_id_);
            SetInt("inputImageTextureLookup", 1);
        }
        if (last_texture_id_ > 0) {
            glActiveTexture(GL_TEXTURE2);
            glBindTexture(GL_TEXTURE_2D, last_texture_id_);
            SetInt("inputImageTextureLast", 2);
        }
    } 
 private:
    int lookup_texture_id_;
    int last_texture_id_;
    int current_index_;
    FrameBuffer* last_texture_frame_;
 
};

}  // trinity

#endif /* hallucination_h */
