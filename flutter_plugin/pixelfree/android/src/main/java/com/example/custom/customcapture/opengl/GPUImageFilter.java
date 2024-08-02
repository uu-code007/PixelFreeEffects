/*
 * Copyright (C) 2012 CyberAgent
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.custom.customcapture.opengl;

import android.opengl.GLES20;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.LinkedList;

public class GPUImageFilter {
    public static final String NO_FILTER_VERTEX_SHADER = ""
            + "attribute vec4 position;\n"
            + "attribute vec4 inputTextureCoordinate;\n"
            + " \n"
            + "varying vec2 textureCoordinate;\n"
            + " \n"
            + "void main()\n"
            + "{\n"
            + "    gl_Position = position;\n"
            + "    textureCoordinate = inputTextureCoordinate.xy;\n"
            + "}";

    public static final String NO_FILTER_FRAGMENT_SHADER = ""
            + "varying highp vec2 textureCoordinate;\n"
            + " \n"
            + "uniform sampler2D inputImageTexture;\n"
            + " \n"
            + "void main()\n"
            + "{\n"
            + "     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);\n"
            + "}";

    public static final String               NO_FILTER_FRAGMENT_SHADER_FLIP = ""
            + "varying highp vec2 textureCoordinate;\n"
            + " \n"
            + "uniform sampler2D inputImageTexture;\n"
            + " \n"
            + "void main()\n"
            + "{\n"
            + "     gl_FragColor = texture2D(inputImageTexture, vec2(textureCoordinate.x, 1.0 - textureCoordinate.y));\n"
            + "}";
    protected final     Program              mProgram;
    private final       LinkedList<Runnable> mRunOnDraw;
    protected           float[]              mTextureMatrix;
    private             int                  mGLAttribPosition;
    private             int                  mGLUniformTexture;
    private             int                  mGLAttribTextureCoordinate;
    private             boolean              mIsInitialized;

    public GPUImageFilter() {
        this(false);
    }

    public GPUImageFilter(boolean flip) {
        this(NO_FILTER_VERTEX_SHADER, flip ? NO_FILTER_FRAGMENT_SHADER_FLIP : NO_FILTER_FRAGMENT_SHADER);
    }

    public GPUImageFilter(final String vertexShader, final String fragmentShader) {
        mRunOnDraw = new LinkedList<>();
        mProgram = new Program(vertexShader, fragmentShader);
    }

    public final void init() {
        onInit();
        mIsInitialized = true;
    }

    protected void onInit() {
        mProgram.build();
        mGLAttribPosition = GLES20.glGetAttribLocation(mProgram.getProgramId(), "position");
        mGLUniformTexture = GLES20.glGetUniformLocation(mProgram.getProgramId(), "inputImageTexture");
        mGLAttribTextureCoordinate = GLES20.glGetAttribLocation(mProgram.getProgramId(), "inputTextureCoordinate");
        mIsInitialized = true;
    }

    public void onOutputSizeChanged(final int width, final int height) {
    }

    protected void onUninit() {
    }

    public final void destroy() {
        runPendingOnDrawTasks();
        onUninit();
        mIsInitialized = false;
        mProgram.destroy();
    }

    public int getTarget() {
        return GLES20.GL_TEXTURE_2D;
    }

    public void setTexutreTransform(float[] matrix) {
        mTextureMatrix = matrix;
    }

    public boolean isInitialized() {
        return mIsInitialized;
    }

    public void onDraw(int textureId, final FloatBuffer cubeBuffer, final FloatBuffer textureBuffer) {
        GLES20.glUseProgram(mProgram.getProgramId());
        runPendingOnDrawTasks();
        if (!mIsInitialized) {
            return;
        }

//        int width = 720;
//        int height = 1024;
//        byte[] pixels = new byte[720 * 1024 * 4];
////
//        for (int i = 0;i < 720 * 1024;i++) {
//            pixels[4*i] = 1;
//            pixels[4*i + 1] = 0;
//            pixels[4*i + 2] = 0;
//            pixels[4*i + 3] = 1;
//        }
//
//        ByteBuffer textureData = ByteBuffer.allocateDirect(width * height * 4);
//        textureData.put((byte[]) pixels);
//        textureData.position(0);
//
//        int[] imageData = new int[width * height];
//        for (int i = 0; i < imageData.length; i++) {
//            imageData[i] = 0xFF0000FF; // 红色
//        }
//
//        ByteBuffer imageBuffer = ByteBuffer.allocateDirect(width * height * 4);
//        imageBuffer.order(ByteOrder.nativeOrder());
//        imageBuffer.asIntBuffer().put(imageData);

//        textureId = OpenGlUtils.loadTexture(GLES20.GL_RGBA, imageBuffer, width, height, -1);

//        textureId = OpenGlUtils.loadTexture(GLES20.GL_RGBA,textureData,720,1024,-1);

        OpenGlUtils.checkGlError("aaa");

        cubeBuffer.position(0);
        GLES20.glVertexAttribPointer(mGLAttribPosition, 2, GLES20.GL_FLOAT, false, 0, cubeBuffer);
        GLES20.glEnableVertexAttribArray(mGLAttribPosition);
        textureBuffer.position(0);
        GLES20.glVertexAttribPointer(mGLAttribTextureCoordinate, 2, GLES20.GL_FLOAT, false, 0,
                textureBuffer);
        GLES20.glEnableVertexAttribArray(mGLAttribTextureCoordinate);

        if (textureId != OpenGlUtils.NO_TEXTURE) {
            GLES20.glActiveTexture(GLES20.GL_TEXTURE0);
            OpenGlUtils.bindTexture(getTarget(), textureId);
            GLES20.glUniform1i(mGLUniformTexture, 0);
        }

        beforeDrawArrays(textureId);
        GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        GLES20.glDisableVertexAttribArray(mGLAttribPosition);
        GLES20.glDisableVertexAttribArray(mGLAttribTextureCoordinate);

        OpenGlUtils.bindTexture(getTarget(), 0);
    }

    protected void beforeDrawArrays(int textureId) {
    }

    protected void runPendingOnDrawTasks() {
        // 将当前要运行的拷贝到新的数组,然后再开始执行,防止执行的里面再次添加
        LinkedList<Runnable> runList;
        synchronized (mRunOnDraw) {
            runList = new LinkedList<>(mRunOnDraw);
            mRunOnDraw.clear();
        }

        while (!runList.isEmpty()) {
            runList.removeFirst().run();
        }
    }
}
