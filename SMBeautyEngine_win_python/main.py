import cv2
import numpy as np
import OpenGL.GL as gl
import glfw
import os
import ctypes
from enum import IntEnum
from typing import Optional, Union, List, Tuple

# 修正OpenGL导入
from OpenGL.GL import *
from OpenGL.GL import shaders
from OpenGL.GL import glGetString
from OpenGL.GL import glGetError
from OpenGL.GL import glEnable
from OpenGL.GL import glDisable
from OpenGL.GL import glCreateProgram
from OpenGL.GL import glDeleteProgram
from OpenGL.GL import glCreateShader
from OpenGL.GL import glShaderSource
from OpenGL.GL import glCompileShader
from OpenGL.GL import glAttachShader
from OpenGL.GL import glLinkProgram
from OpenGL.GL import glUseProgram
from OpenGL.GL import glGenTextures
from OpenGL.GL import glBindTexture
from OpenGL.GL import glTexImage2D
from OpenGL.GL import glTexParameteri
from OpenGL.GL import glDrawArrays

# Enums and Structures
class PFDetectFormat(IntEnum):
    PFFORMAT_UNKNOWN = 0
    PFFORMAT_IMAGE_RGB = 1
    PFFORMAT_IMAGE_BGR = 2
    PFFORMAT_IMAGE_RGBA = 3
    PFFORMAT_IMAGE_BGRA = 4
    PFFORMAT_IMAGE_ARGB = 5
    PFFORMAT_IMAGE_ABGR = 6
    PFFORMAT_IMAGE_GRAY = 7
    PFFORMAT_IMAGE_YUV_NV12 = 8
    PFFORMAT_IMAGE_YUV_NV21 = 9
    PFFORMAT_IMAGE_YUV_I420 = 10
    PFFORMAT_IMAGE_TEXTURE = 11

class PFRotationMode(IntEnum):
    PFRotationMode0 = 0
    PFRotationMode90 = 1
    PFRotationMode180 = 2
    PFRotationMode270 = 3

class PFSrcType(IntEnum):
    PFSrcTypeFilter = 0
    PFSrcTypeAuthFile = 2
    PFSrcTypeStickerFile = 3

class PFBeautyFiterType(IntEnum):
    PFBeautyFiterTypeFace_EyeStrength = 0
    PFBeautyFiterTypeFace_thinning = 1
    PFBeautyFiterTypeFace_narrow = 2
    PFBeautyFiterTypeFace_chin = 3
    PFBeautyFiterTypeFace_V = 4
    PFBeautyFiterTypeFace_small = 5
    PFBeautyFiterTypeFace_nose = 6
    PFBeautyFiterTypeFace_forehead = 7
    PFBeautyFiterTypeFace_mouth = 8
    PFBeautyFiterTypeFace_philtrum = 9
    PFBeautyFiterTypeFace_long_nose = 10
    PFBeautyFiterTypeFace_eye_space = 11
    PFBeautyFiterTypeFace_smile = 12
    PFBeautyFiterTypeFace_eye_rotate = 13
    PFBeautyFiterTypeFace_canthus = 14
    PFBeautyFiterTypeFaceBlurStrength = 15
    PFBeautyFiterTypeFaceWhitenStrength = 16
    PFBeautyFiterTypeFaceRuddyStrength = 17
    PFBeautyFiterTypeFaceSharpenStrength = 18
    PFBeautyFiterTypeFaceM_newWhitenStrength = 19
    PFBeautyFiterTypeFaceH_qualityStrength = 20
    PFBeautyFiterTypeFaceEyeBrighten = 21
    PFBeautyFiterName = 22
    PFBeautyFiterStrength = 23
    PFBeautyFiterLvmu = 24
    PFBeautyFiterSticker2DFilter = 25
    PFBeautyFiterTypeOneKey = 26
    PFBeautyFiterWatermark = 27
    PFBeautyFiterExtend = 28

class PFIamgeInput(ctypes.Structure):
    _fields_ = [
        ("textureID", ctypes.c_uint),
        ("wigth", ctypes.c_int),
        ("height", ctypes.c_int),
        ("p_data0", ctypes.c_void_p),  # Y or rgba
        ("p_data1", ctypes.c_void_p),
        ("p_data2", ctypes.c_void_p),
        ("stride_0", ctypes.c_int),
        ("stride_1", ctypes.c_int),
        ("stride_2", ctypes.c_int),
        ("format", ctypes.c_int),
        ("rotationMode", ctypes.c_int)
    ]

class PixelFree:
    def __init__(self, dll_path: str):
        if not os.path.exists(dll_path):
            raise FileNotFoundError(f"PixelFree DLL not found at: {dll_path}")
        
        self._dll = ctypes.CDLL(dll_path)
        self._setup_function_prototypes()
        
        # 获取当前OpenGL上下文信息
        self._gl_context = {
            'version': gl.glGetString(gl.GL_VERSION).decode(),
            'vendor': gl.glGetString(gl.GL_VENDOR).decode(),
            'renderer': gl.glGetString(gl.GL_RENDERER).decode(),
            'window': glfw.get_current_context()
        }
        print(f"Current OpenGL Context:")
        print(f"  Version: {self._gl_context['version']}")
        print(f"  Vendor: {self._gl_context['vendor']}")
        print(f"  Renderer: {self._gl_context['renderer']}")
        
        # 创建PixelFree实例
        self._handle = self._dll.PF_NewPixelFree()
        if not self._handle:
            raise RuntimeError("Failed to create PixelFree instance")
        
        # 确保OpenGL状态正确
        gl.glDisable(gl.GL_DEPTH_TEST)
        gl.glDisable(gl.GL_CULL_FACE)
        gl.glDisable(gl.GL_BLEND)
        
        # 检查OpenGL错误
        error = gl.glGetError()
        if error != gl.GL_NO_ERROR:
            print(f"OpenGL error after initialization: {error}")
    
    def _setup_function_prototypes(self):
        self._dll.PF_Version.restype = ctypes.c_char_p
        self._dll.PF_NewPixelFree.restype = ctypes.c_void_p
        
        # 修改函数原型以匹配C接口
        self._dll.PF_processWithBuffer.restype = ctypes.c_int
        self._dll.PF_processWithBuffer.argtypes = [
            ctypes.c_void_p,  # handle
            ctypes.POINTER(PFIamgeInput)  # 使用指针类型
        ]
        
        self._dll.PF_pixelFreeSetBeautyFiterParam.argtypes = [
            ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p
        ]
        self._dll.PF_createBeautyItemFormBundle.argtypes = [
            ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int
        ]
    
    def load_bundle(self, data: bytes, bundle_type: PFSrcType):
        buffer = ctypes.create_string_buffer(data)
        self._dll.PF_createBeautyItemFormBundle(
            self._handle, buffer, len(data), bundle_type.value)
    
    def process_image(self, image_input: PFIamgeInput) -> int:
        # 确保在正确的OpenGL上下文中
        current_window = glfw.get_current_context()
        if current_window != self._gl_context['window']:
            glfw.make_context_current(self._gl_context['window'])
        
        # 创建结构体的副本并获取其指针
        input_ptr = ctypes.pointer(image_input)
        
        # 确保数据指针有效
        if image_input.format == PFDetectFormat.PFFORMAT_IMAGE_TEXTURE.value:
            # 在纹理模式下，确保textureID有效
            if image_input.textureID == 0:
                raise ValueError("Invalid texture ID in texture mode")
            
            # 确保纹理在当前OpenGL上下文中是有效的
            gl.glBindTexture(gl.GL_TEXTURE_2D, image_input.textureID)
            error = gl.glGetError()
            if error != gl.GL_NO_ERROR:
                raise RuntimeError(f"Invalid texture ID: {error}")
            gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
            
            # 在纹理模式下，确保所有数据指针都是NULL
            image_input.p_data0 = None
            image_input.p_data1 = None
            image_input.p_data2 = None
            image_input.stride_0 = 0
            image_input.stride_1 = 0
            image_input.stride_2 = 0
        elif image_input.p_data0:
            # 在非纹理模式下，确保数据指针不会被垃圾回收
            self._data_buffer = image_input.p_data0
        
        # 调用DLL处理图像
        result = self._dll.PF_processWithBuffer(self._handle, input_ptr)
        if result <= 0:
            raise RuntimeError(f"PF_processWithBuffer failed with result: {result}")
        return result
    
    def set_parameter(self, param_type: PFBeautyFiterType, value: Union[float, str, bool]):
        if isinstance(value, str):
            encoded = value.encode('utf-8')
            self._dll.PF_pixelFreeSetBeautyFiterParam(
                self._handle, param_type.value, encoded)
        elif isinstance(value, (float, int)):
            c_value = ctypes.c_float(float(value))
            self._dll.PF_pixelFreeSetBeautyFiterParam(
                self._handle, param_type.value, ctypes.byref(c_value))
        elif isinstance(value, bool):
            c_value = ctypes.c_bool(value)
            self._dll.PF_pixelFreeSetBeautyFiterParam(
                self._handle, param_type.value, ctypes.byref(c_value))

class OpenGLRenderer:
    def __init__(self, width, height):
        print(f"Initializing OpenGLRenderer with dimensions: {width}x{height}")
        self.width = width
        self.height = height
        
        # Vertex shader source
        vertex_shader_source = """
        #version 330 core
        layout (location = 0) in vec4 position;
        layout (location = 1) in vec4 inputTextureCoordinate;
        out vec2 textureCoordinate;
        void main() {
            gl_Position = position;
            textureCoordinate = inputTextureCoordinate.xy;
        }
        """
        
        # Fragment shader source
        fragment_shader_source = """
        #version 330 core
        in vec2 textureCoordinate;
        out vec4 FragColor;
        uniform sampler2D inputImageTexture;
        void main() {
            FragColor = texture(inputImageTexture, textureCoordinate);
        }
        """
        
        # Compile shaders
        vertex_shader = gl.glCreateShader(gl.GL_VERTEX_SHADER)
        gl.glShaderSource(vertex_shader, vertex_shader_source)
        gl.glCompileShader(vertex_shader)
        
        # Check vertex shader compilation
        if not gl.glGetShaderiv(vertex_shader, gl.GL_COMPILE_STATUS):
            error = gl.glGetShaderInfoLog(vertex_shader)
            print(f"Vertex shader compilation error: {error}")
        
        fragment_shader = gl.glCreateShader(gl.GL_FRAGMENT_SHADER)
        gl.glShaderSource(fragment_shader, fragment_shader_source)
        gl.glCompileShader(fragment_shader)
        
        # Check fragment shader compilation
        if not gl.glGetShaderiv(fragment_shader, gl.GL_COMPILE_STATUS):
            error = gl.glGetShaderInfoLog(fragment_shader)
            print(f"Fragment shader compilation error: {error}")
        
        # Create program
        self.program = gl.glCreateProgram()
        gl.glAttachShader(self.program, vertex_shader)
        gl.glAttachShader(self.program, fragment_shader)
        gl.glLinkProgram(self.program)
        
        # Check program linking
        if not gl.glGetProgramiv(self.program, gl.GL_LINK_STATUS):
            error = gl.glGetProgramInfoLog(self.program)
            print(f"Program linking error: {error}")
        
        # Cleanup shaders
        gl.glDeleteShader(vertex_shader)
        gl.glDeleteShader(fragment_shader)
        
        # Setup vertex data
        vertices = [
            -1.0, -1.0, 0.0, 1.0,
             1.0, -1.0, 0.0, 1.0,
            -1.0,  1.0, 0.0, 1.0,
             1.0,  1.0, 0.0, 1.0
        ]
        
        # 修改纹理坐标以修复倒置问题
        texture_coords = [
            0.0, 1.0, 0.0, 1.0,  # 左下
            1.0, 1.0, 0.0, 1.0,  # 右下
            0.0, 0.0, 0.0, 1.0,  # 左上
            1.0, 0.0, 0.0, 1.0   # 右上
        ]
        
        # Create and bind VAO
        self.vao = gl.glGenVertexArrays(1)
        gl.glBindVertexArray(self.vao)
        
        # Vertex buffer
        self.vbo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.vbo)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, 
                       np.array(vertices, dtype=np.float32), 
                       gl.GL_STATIC_DRAW)
        gl.glEnableVertexAttribArray(0)
        gl.glVertexAttribPointer(0, 4, gl.GL_FLOAT, gl.GL_FALSE, 0, None)
        
        # Texture coordinate buffer
        self.tbo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.tbo)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, 
                       np.array(texture_coords, dtype=np.float32), 
                       gl.GL_STATIC_DRAW)
        gl.glEnableVertexAttribArray(1)
        gl.glVertexAttribPointer(1, 4, gl.GL_FLOAT, gl.GL_FALSE, 0, None)
        
        gl.glBindVertexArray(0)
        print("OpenGLRenderer initialization completed")
    
    def render(self, texture_id):
        gl.glUseProgram(self.program)
        gl.glBindVertexArray(self.vao)
        
        gl.glActiveTexture(gl.GL_TEXTURE0)
        gl.glBindTexture(gl.GL_TEXTURE_2D, texture_id)
        
        gl.glDrawArrays(gl.GL_TRIANGLE_STRIP, 0, 4)
        
        gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
        gl.glBindVertexArray(0)
        gl.glUseProgram(0)

def load_image(image_path):
    """使用OpenCV加载图像并转换为RGBA格式"""
    print(f"Loading image from: {image_path}")
    img = cv2.imread(image_path, cv2.IMREAD_UNCHANGED)
    if img is None:
        raise ValueError(f"无法加载图像: {image_path}")
    
    print(f"Original image shape: {img.shape}, dtype: {img.dtype}")
    
    # 处理不同通道数的图像
    if img.ndim == 2:  # 灰度图
        print("Converting grayscale image to RGBA")
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2RGBA)
    elif img.shape[2] == 3:  # RGB/BGR
        print("Converting BGR image to RGBA")
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGBA)
    elif img.shape[2] == 4:  # RGBA/BGRA
        print("Converting BGRA image to RGBA")
        img = cv2.cvtColor(img, cv2.COLOR_BGRA2RGBA)
    
    # 确保图像数据是连续的
    img = np.ascontiguousarray(img)
    
    height, width = img.shape[:2]
    print(f"Processed image shape: {img.shape}, dtype: {img.dtype}")
    return width, height, img

def create_texture(width, height, data):
    print(f"Creating texture with dimensions: {width}x{height}")
    print(f"Input data shape: {data.shape}, dtype: {data.dtype}")
    
    texture_id = gl.glGenTextures(1)
    if texture_id == 0:
        raise RuntimeError("Failed to generate texture ID")
        
    gl.glBindTexture(gl.GL_TEXTURE_2D, texture_id)
    
    # 设置纹理参数
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP_TO_EDGE)
    gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP_TO_EDGE)
    
    # 使用RGBA格式
    gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGBA, width, height, 0, 
                   gl.GL_RGBA, gl.GL_UNSIGNED_BYTE, data)
    
    # 检查OpenGL错误
    error = gl.glGetError()
    if error != gl.GL_NO_ERROR:
        gl.glDeleteTextures(1, [texture_id])
        raise RuntimeError(f"OpenGL error after texture creation: {error}")
    
    gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
    print(f"Texture created successfully with ID: {texture_id}")
    return texture_id

def main():
    # Initialize GLFW
    if not glfw.init():
        print("Failed to initialize GLFW")
        return
    
    # 设置OpenGL版本和兼容模式
    glfw.window_hint(glfw.CONTEXT_VERSION_MAJOR, 3)
    glfw.window_hint(glfw.CONTEXT_VERSION_MINOR, 3)
    glfw.window_hint(glfw.OPENGL_PROFILE, glfw.OPENGL_COMPAT_PROFILE)  # 使用兼容模式
    glfw.window_hint(glfw.OPENGL_FORWARD_COMPAT, gl.GL_FALSE)  # 禁用前向兼容
    
    # Create window
    window = glfw.create_window(720, 1024, "PixelFree Python", None, None)
    if not window:
        glfw.terminate()
        print("Failed to create GLFW window")
        return
    
    # 设置当前上下文
    glfw.make_context_current(window)
    
    # 创建渲染器（在DLL操作之前）
    renderer = OpenGLRenderer(720, 1024)
    
    # 加载OpenGL库
    import ctypes.util
    opengl32_path = ctypes.util.find_library('opengl32')
    if not opengl32_path:
        print("Error: Could not find opengl32.dll")
        glfw.terminate()
        return
    
    # 加载OpenGL库
    opengl32 = ctypes.CDLL(opengl32_path)
    
    # 获取GetProcAddress函数
    kernel32 = ctypes.CDLL('kernel32.dll')
    GetProcAddress = kernel32.GetProcAddress
    GetProcAddress.restype = ctypes.c_void_p
    GetProcAddress.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
    
    # 获取wglGetProcAddress函数
    wglGetProcAddress = opengl32.wglGetProcAddress
    wglGetProcAddress.restype = ctypes.c_void_p
    wglGetProcAddress.argtypes = [ctypes.c_char_p]
    
    # 获取glGetString函数（从opengl32.dll直接获取）
    glGetString = GetProcAddress(opengl32._handle, b"glGetString")
    if glGetString is None:
        print("Error: Failed to get glGetString function pointer")
        glfw.terminate()
        return
    
    # 设置glGetString的类型
    glGetString = ctypes.CFUNCTYPE(ctypes.c_char_p, ctypes.c_uint)(glGetString)
    
    # 初始化OpenGL函数指针
    try:
        # 尝试获取OpenGL版本信息
        version = glGetString(gl.GL_VERSION)
        if version is None:
            raise RuntimeError("Failed to get OpenGL version")
        
        # 确保OpenGL状态正确
        glDisable(gl.GL_DEPTH_TEST)
        glDisable(gl.GL_CULL_FACE)
        glDisable(gl.GL_BLEND)
        
    except Exception as e:
        print(f"OpenGL initialization error: {str(e)}")
        glfw.terminate()
        return
    
    # Get resource paths
    current_dir = os.path.dirname(os.path.abspath(__file__))
    res_dir = os.path.join(current_dir, "res")
    current_dll = os.path.join(current_dir, "lib")
    
    image_path = os.path.join(res_dir, "test.png")
    auth_path = os.path.join(res_dir, "pixelfreeAuth.lic")
    filter_path = os.path.join(res_dir, "filter_model.bundle")
    dll_path = os.path.join(current_dll, "PixelFree.dll")
    
    # Initialize PixelFree
    try:
        # 确保DLL能找到OpenGL函数
        if opengl32_path:
            ctypes.CDLL(opengl32_path)
        
        # 在创建PixelFree实例之前，确保所有OpenGL函数都已加载
        test_functions = [
            "glCreateProgram",
            "glCreateShader",
            "glShaderSource",
            "glCompileShader",
            "glAttachShader",
            "glLinkProgram",
            "glUseProgram",
            "glGenTextures",
            "glBindTexture",
            "glTexImage2D",
            "glTexParameteri",
            "glDrawArrays"
        ]
        
        for func_name in test_functions:
            func_ptr = wglGetProcAddress(func_name.encode())
            if func_ptr is None:
                print(f"Warning: Failed to load {func_name}")
        
        # 确保OpenGL上下文是当前的
        glfw.make_context_current(window)
        
        pf = PixelFree(dll_path)
        
        # Load auth file
        with open(auth_path, "rb") as f:
            auth_data = f.read()
        pf.load_bundle(auth_data, PFSrcType.PFSrcTypeAuthFile)
        
        # Load filter
        with open(filter_path, "rb") as f:
            filter_data = f.read()
        pf.load_bundle(filter_data, PFSrcType.PFSrcTypeFilter)
        
        # Set filter parameters
        pf.set_parameter(PFBeautyFiterType.PFBeautyFiterName, "heibai1")
        pf.set_parameter(PFBeautyFiterType.PFBeautyFiterTypeFace_narrow, 1.0)
        pf.set_parameter(PFBeautyFiterType.PFBeautyFiterTypeFace_V, 1.0)
        
        # Load image
        width, height, image_data = load_image(image_path)
        input_texture = create_texture(width, height, image_data)
        
        # Main loop
        while not glfw.window_should_close(window):
            glfw.poll_events()
            
            try:
                # 确保OpenGL上下文是当前的
                glfw.make_context_current(window)
                
                # Prepare input image
                input_image = PFIamgeInput()
                input_image.textureID = input_texture
                input_image.wigth = width
                input_image.height = height
                input_image.p_data0 = None
                input_image.p_data1 = None
                input_image.p_data2 = None
                input_image.stride_0 = 0
                input_image.stride_1 = 0
                input_image.stride_2 = 0
                input_image.format = PFDetectFormat.PFFORMAT_IMAGE_TEXTURE.value
                input_image.rotationMode = PFRotationMode.PFRotationMode0.value
                
                # Process image
                output_texture = pf.process_image(input_image)
                if output_texture <= 0:
                    continue
                
                # 重新初始化OpenGL上下文和状态
                glfw.make_context_current(window)
                
                # 重新设置OpenGL版本和配置文件
                glfw.window_hint(glfw.CONTEXT_VERSION_MAJOR, 3)
                glfw.window_hint(glfw.CONTEXT_VERSION_MINOR, 3)
                glfw.window_hint(glfw.OPENGL_PROFILE, glfw.OPENGL_COMPAT_PROFILE)
                glfw.window_hint(glfw.OPENGL_FORWARD_COMPAT, gl.GL_FALSE)
                
                # 设置视口和清除缓冲区
                gl.glViewport(0, 0, 720, 1024)
                gl.glClearColor(0.0, 0.0, 0.0, 1.0)
                gl.glClear(gl.GL_COLOR_BUFFER_BIT)
                
                # Render
                renderer.render(output_texture)
                
                # 交换缓冲区
                glfw.swap_buffers(window)
                
            except Exception as e:
                print(f"Error in render loop: {str(e)}")
                # 尝试恢复OpenGL上下文
                try:
                    glfw.make_context_current(window)
                except:
                    pass
                break
        
        # Cleanup
        try:
            if glfw.get_current_context() != window:
                glfw.make_context_current(window)
            if 'input_texture' in locals():
                gl.glDeleteTextures(1, [input_texture])
        except Exception as e:
            print(f"Error during cleanup: {str(e)}")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")
    
    finally:
        glfw.terminate()
        if 'pf' in locals():
            del pf

if __name__ == "__main__":
    main() 