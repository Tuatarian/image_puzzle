# 
#   rlgl v4.0 - A multi-OpenGL abstraction layer with an immediate-mode style API
# 
#   An abstraction layer for multiple OpenGL versions (1.1, 2.1, 3.3 Core, 4.3 Core, ES 2.0)
#   that provides a pseudo-OpenGL 1.1 immediate-mode style API (rlVertex, rlTranslate, rlRotate...)
# 
#   When chosing an OpenGL backend different than OpenGL 1.1, some internal buffer are
#   initialized on rlglInit() to accumulate vertex data.
# 
#   When an internal state change is required all the stored vertex data is renderer in batch,
#   additioanlly, rlDrawRenderBatchActive() could be called to force flushing of the batch.
# 
#   Some additional resources are also loaded for convenience, here the complete list:
#      - Default batch (RLGL.defaultBatch): RenderBatch system to accumulate vertex data
#      - Default texture (RLGL.defaultTextureId): 1x1 white pixel R8G8B8A8
#      - Default shader (RLGL.State.defaultShaderId, RLGL.State.defaultShaderLocs)
# 
#   Internal buffer (and additional resources) must be manually unloaded calling rlglClose().
# 
# 
#   CONFIGURATION:
# 
#   #define GRAPHICS_API_OPENGL_11
#   #define GRAPHICS_API_OPENGL_21
#   #define GRAPHICS_API_OPENGL_33
#   #define GRAPHICS_API_OPENGL_43
#   #define GRAPHICS_API_OPENGL_ES2
#       Use selected OpenGL graphics backend, should be supported by platform
#       Those preprocessor defines are only used on rlgl module, if OpenGL version is
#       required by any other module, use rlGetVersion() to check it
# 
#   #define RLGL_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers
#       or source files without problems. But only ONE file should hold the implementation.
# 
#   #define RLGL_RENDER_TEXTURES_HINT
#       Enable framebuffer objects (fbo) support (enabled by default)
#       Some GPUs could not support them despite the OpenGL version
# 
#   #define RLGL_SHOW_GL_DETAILS_INFO
#       Show OpenGL extensions and capabilities detailed logs on init
# 
#   #define RLGL_ENABLE_OPENGL_DEBUG_CONTEXT
#       Enable debug context (only available on OpenGL 4.3)
# 
#   rlgl capabilities could be customized just defining some internal
#   values before library inclusion (default values listed):
# 
#   #define RL_DEFAULT_BATCH_BUFFER_ELEMENTS   8192    // Default internal render batch elements limits
#   #define RL_DEFAULT_BATCH_BUFFERS              1    // Default number of batch buffers (multi-buffering)
#   #define RL_DEFAULT_BATCH_DRAWCALLS          256    // Default number of batch draw calls (by state changes: mode, texture)
#   #define RL_DEFAULT_BATCH_MAX_TEXTURE_UNITS    4    // Maximum number of textures units that can be activated on batch drawing (SetShaderValueTexture())
# 
#   #define RL_MAX_MATRIX_STACK_SIZE             32    // Maximum size of internal Matrix stack
#   #define RL_MAX_SHADER_LOCATIONS              32    // Maximum number of shader locations supported
#   #define RL_CULL_DISTANCE_NEAR              0.01    // Default projection matrix near cull distance
#   #define RL_CULL_DISTANCE_FAR             1000.0    // Default projection matrix far cull distance
# 
#   When loading a shader, the following vertex attribute and uniform
#   location names are tried to be set automatically:
# 
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_POSITION     "vertexPosition"    // Binded by default to shader location: 0
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD     "vertexTexCoord"    // Binded by default to shader location: 1
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_NORMAL       "vertexNormal"      // Binded by default to shader location: 2
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_COLOR        "vertexColor"       // Binded by default to shader location: 3
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TANGENT      "vertexTangent"     // Binded by default to shader location: 4
#   #define RL_DEFAULT_SHADER_ATTRIB_NAME_TEXCOORD2    "vertexTexCoord2"   // Binded by default to shader location: 5
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MVP         "mvp"               // model-view-projection matrix
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_VIEW        "matView"           // view matrix
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_PROJECTION  "matProjection"     // projection matrix
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_MODEL       "matModel"          // model matrix
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_NORMAL      "matNormal"         // normal matrix (transpose(inverse(matModelView))
#   #define RL_DEFAULT_SHADER_UNIFORM_NAME_COLOR       "colDiffuse"        // color diffuse (base tint color, multiplied by texture color)
#   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE0  "texture0"          // texture0 (texture slot active 0)
#   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE1  "texture1"          // texture1 (texture slot active 1)
#   #define RL_DEFAULT_SHADER_SAMPLER2D_NAME_TEXTURE2  "texture2"          // texture2 (texture slot active 2)
# 
#   DEPENDENCIES:
# 
#      - OpenGL libraries (depending on platform and OpenGL version selected)
#      - GLAD OpenGL extensions loading library (only for OpenGL 3.3 Core, 4.3 Core)
# 
# 
#   LICENSE: zlib/libpng
# 
#   Copyright (c) 2014-2022 Ramon Santamaria (@raysan5)
# 
#   This software is provided "as-is", without any express or implied warranty. In no event
#   will the authors be held liable for any damages arising from the use of this software.
# 
#   Permission is granted to anyone to use this software for any purpose, including commercial
#   applications, and to alter it and redistribute it freely, subject to the following restrictions:
# 
#     1. The origin of this software must not be misrepresented; you must not claim that you
#     wrote the original software. If you use this software in a product, an acknowledgment
#     in the product documentation would be appreciated but is not required.
# 
#     2. Altered source versions must be plainly marked as such, and must not be misrepresented
#     as being the original software.
# 
#     3. This notice may not be removed or altered from any source distribution.
# 
template RLGL_H*(): auto = RLGL_H
template RLGL_VERSION*(): auto = "4.0"
# Function specifiers in case library is build/used as a shared library (Windows)
# NOTE: Microsoft specifiers to tell compiler that symbols are imported/exported from a .dll
# Function specifiers definition
{.pragma: RLAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}
# Support TRACELOG macros
# Allow custom memory allocators
# Security check in case no GRAPHICS_API_OPENGL_* defined
# Security check in case multiple GRAPHICS_API_OPENGL_* defined
# OpenGL 2.1 uses most of OpenGL 3.3 Core functionality
# WARNING: Specific parts are checked with #if defines
# OpenGL 4.3 uses OpenGL 3.3 Core functionality
# Support framebuffer objects by default
# NOTE: Some driver implementation do not support it, despite they should
template RLGL_RENDER_TEXTURES_HINT*(): auto = RLGL_RENDER_TEXTURES_HINT
# ----------------------------------------------------------------------------------
# Defines and Macros
# ----------------------------------------------------------------------------------
# Default internal render batch elements limits
# Internal Matrix stack
# Shader limits
# Projection matrix culling
# Texture parameters (equivalent to OpenGL defines)
template RL_TEXTURE_WRAP_S*(): auto = 0x2802
template RL_TEXTURE_WRAP_T*(): auto = 0x2803
template RL_TEXTURE_MAG_FILTER*(): auto = 0x2800
template RL_TEXTURE_MIN_FILTER*(): auto = 0x2801
template RL_TEXTURE_FILTER_NEAREST*(): auto = 0x2600
template RL_TEXTURE_FILTER_LINEAR*(): auto = 0x2601
template RL_TEXTURE_FILTER_MIP_NEAREST*(): auto = 0x2700
template RL_TEXTURE_FILTER_NEAREST_MIP_LINEAR*(): auto = 0x2702
template RL_TEXTURE_FILTER_LINEAR_MIP_NEAREST*(): auto = 0x2701
template RL_TEXTURE_FILTER_MIP_LINEAR*(): auto = 0x2703
template RL_TEXTURE_FILTER_ANISOTROPIC*(): auto = 0x3000
template RL_TEXTURE_WRAP_REPEAT*(): auto = 0x2901
template RL_TEXTURE_WRAP_CLAMP*(): auto = 0x812F
template RL_TEXTURE_WRAP_MIRROR_REPEAT*(): auto = 0x8370
template RL_TEXTURE_WRAP_MIRROR_CLAMP*(): auto = 0x8742
# Matrix modes (equivalent to OpenGL)
template RL_MODELVIEW*(): auto = 0x1700
template RL_PROJECTION*(): auto = 0x1701
template RL_TEXTURE*(): auto = 0x1702
# Primitive assembly draw modes
template RL_LINES*(): auto = 0x0001
template RL_TRIANGLES*(): auto = 0x0004
template RL_QUADS*(): auto = 0x0007
# GL equivalent data types
template RL_UNSIGNED_BYTE*(): auto = 0x1401
template RL_FLOAT*(): auto = 0x1406
# Buffer usage hint
template RL_STREAM_DRAW*(): auto = 0x88E0
template RL_STREAM_READ*(): auto = 0x88E1
template RL_STREAM_COPY*(): auto = 0x88E2
template RL_STATIC_DRAW*(): auto = 0x88E4
template RL_STATIC_READ*(): auto = 0x88E5
template RL_STATIC_COPY*(): auto = 0x88E6
template RL_DYNAMIC_DRAW*(): auto = 0x88E8
template RL_DYNAMIC_READ*(): auto = 0x88E9
template RL_DYNAMIC_COPY*(): auto = 0x88EA
# GL Shader type
template RL_FRAGMENT_SHADER*(): auto = 0x8B30
template RL_VERTEX_SHADER*(): auto = 0x8B31
template RL_COMPUTE_SHADER*(): auto = 0x91B9
# ----------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------
type rlGlVersion* = enum 
    OPENGL_11 = 1 
    OPENGL_21 
    OPENGL_33 
    OPENGL_43 
    OPENGL_ES_20 
converter rlGlVersion2int32* (self: rlGlVersion): int32 = self.int32 
type rlFramebufferAttachType* = enum 
    RL_ATTACHMENT_COLOR_CHANNEL0 = 0 
    RL_ATTACHMENT_COLOR_CHANNEL1 
    RL_ATTACHMENT_COLOR_CHANNEL2 
    RL_ATTACHMENT_COLOR_CHANNEL3 
    RL_ATTACHMENT_COLOR_CHANNEL4 
    RL_ATTACHMENT_COLOR_CHANNEL5 
    RL_ATTACHMENT_COLOR_CHANNEL6 
    RL_ATTACHMENT_COLOR_CHANNEL7 
    RL_ATTACHMENT_DEPTH = 100 
    RL_ATTACHMENT_STENCIL = 200 
converter rlFramebufferAttachType2int32* (self: rlFramebufferAttachType): int32 = self.int32 
type rlFramebufferAttachTextureType* = enum 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_X = 0 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_X 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Y 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y 
    RL_ATTACHMENT_CUBEMAP_POSITIVE_Z 
    RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z 
    RL_ATTACHMENT_TEXTURE2D = 100 
    RL_ATTACHMENT_RENDERBUFFER = 200 
converter rlFramebufferAttachTextureType2int32* (self: rlFramebufferAttachTextureType): int32 = self.int32 
# Dynamic vertex buffers (position + texcoords + colors + indices arrays)
type rlVertexBuffer* {.bycopy.} = object
    elementCount*: int32 # Number of elements in the buffer (QUADS)
    vertices*: float32 # Vertex position (XYZ - 3 components per vertex) (shader-location = 0)
    texcoords*: float32 # Vertex texture coordinates (UV - 2 components per vertex) (shader-location = 1)
    colors*: uint8 # Vertex colors (RGBA - 4 components per vertex) (shader-location = 3)
    indices*: uint32 # Vertex indices (in case vertex data comes indexed) (6 indices per quad)
    # Skipped another *indices
    vaoId*: uint32 # OpenGL Vertex Array Object id
    vboId*: array[0..3, uint32] # OpenGL Vertex Buffer Objects id (4 types of vertex data)
# Draw call type
# NOTE: Only texture changes register a new draw, other state-change-related elements are not
# used at this moment (vaoId, shaderId, matrices), raylib just forces a batch draw call if any
# of those state-change happens (this is done in core module)
type rlDrawCall* {.bycopy.} = object
    mode*: int32 # Drawing mode: LINES, TRIANGLES, QUADS
    vertexCount*: int32 # Number of vertex of the draw
    vertexAlignment*: int32 # Number of vertex required for index alignment (LINES, TRIANGLES)
    textureId*: uint32 # Texture id to be used on the draw -> Use to create new draw call if changes
# rlRenderBatch type
type rlRenderBatch* {.bycopy.} = object
    bufferCount*: int32 # Number of vertex buffers (multi-buffering support)
    currentBuffer*: int32 # Current buffer tracking in case of multi-buffering
    vertexBuffer*: ptr rlVertexBuffer # Dynamic buffer(s) for vertex data
    draws*: ptr rlDrawCall # Draw calls array, depends on textureId
    drawCounter*: int32 # Draw calls counter
    currentDepth*: float32 # Current depth value for next draw
# Matrix, 4x4 components, column major, OpenGL style, right handed
type Matrix* {.bycopy.} = object
    m0*, m4*, m8*, m12*: float32 # Matrix first row (4 components)
    m1*, m5*, m9*, m13*: float32 # Matrix second row (4 components)
    m2*, m6*, m10*, m14*: float32 # Matrix third row (4 components)
    m3*, m7*, m11*, m15*: float32 # Matrix fourth row (4 components)
template RL_MATRIX_TYPE*(): auto = RL_MATRIX_TYPE
# Trace log level
# NOTE: Organized by priority level
type rlTraceLogLevel* = enum 
    RL_LOG_ALL = 0 # Display all logs
    RL_LOG_TRACE # Trace logging, intended for internal use only
    RL_LOG_DEBUG # Debug logging, used for internal debugging, it should be disabled on release builds
    RL_LOG_INFO # Info logging, used for program execution info
    RL_LOG_WARNING # Warning logging, used on recoverable failures
    RL_LOG_ERROR # Error logging, used on unrecoverable failures
    RL_LOG_FATAL # Fatal logging, used to abort program: exit(EXIT_FAILURE)
    RL_LOG_NONE # Disable logging
converter rlTraceLogLevel2int32* (self: rlTraceLogLevel): int32 = self.int32 
# Texture formats (support depends on OpenGL version)
type rlPixelFormat* = enum 
    RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE = 1 # 8 bit per pixel (no alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA # 8*2 bpp (2 channels)
    RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5 # 16 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8 # 24 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1 # 16 bpp (1 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4 # 16 bpp (4 bit alpha)
    RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8 # 32 bpp
    RL_PIXELFORMAT_UNCOMPRESSED_R32 # 32 bpp (1 channel - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32 # 32*3 bpp (3 channels - float)
    RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32 # 32*4 bpp (4 channels - float)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGB # 4 bpp (no alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA # 4 bpp (1 bit alpha)
    RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA # 8 bpp
    RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA # 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC1_RGB # 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_RGB # 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA # 8 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGB # 4 bpp
    RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA # 4 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA # 8 bpp
    RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA # 2 bpp
converter rlPixelFormat2int32* (self: rlPixelFormat): int32 = self.int32 
# Texture parameters: filter mode
# NOTE 1: Filtering considers mipmaps if available in the texture
# NOTE 2: Filter is accordingly set for minification and magnification
type rlTextureFilter* = enum 
    RL_TEXTURE_FILTER_POINT = 0 # No filter, just pixel approximation
    RL_TEXTURE_FILTER_BILINEAR # Linear filtering
    RL_TEXTURE_FILTER_TRILINEAR # Trilinear filtering (linear with mipmaps)
    RL_TEXTURE_FILTER_ANISOTROPIC_4X # Anisotropic filtering 4x
    RL_TEXTURE_FILTER_ANISOTROPIC_8X # Anisotropic filtering 8x
    RL_TEXTURE_FILTER_ANISOTROPIC_16X # Anisotropic filtering 16x
converter rlTextureFilter2int32* (self: rlTextureFilter): int32 = self.int32 
# Color blending modes (pre-defined)
type rlBlendMode* = enum 
    RL_BLEND_ALPHA = 0 # Blend textures considering alpha (default)
    RL_BLEND_ADDITIVE # Blend textures adding colors
    RL_BLEND_MULTIPLIED # Blend textures multiplying colors
    RL_BLEND_ADD_COLORS # Blend textures adding colors (alternative)
    RL_BLEND_SUBTRACT_COLORS # Blend textures subtracting colors (alternative)
    RL_BLEND_ALPHA_PREMUL # Blend premultiplied textures considering alpha
    RL_BLEND_CUSTOM # Blend textures using custom src/dst factors (use rlSetBlendFactors())
converter rlBlendMode2int32* (self: rlBlendMode): int32 = self.int32 
# Shader location point type
type rlShaderLocationIndex* = enum 
    RL_SHADER_LOC_VERTEX_POSITION = 0 # Shader location: vertex attribute: position
    RL_SHADER_LOC_VERTEX_TEXCOORD01 # Shader location: vertex attribute: texcoord01
    RL_SHADER_LOC_VERTEX_TEXCOORD02 # Shader location: vertex attribute: texcoord02
    RL_SHADER_LOC_VERTEX_NORMAL # Shader location: vertex attribute: normal
    RL_SHADER_LOC_VERTEX_TANGENT # Shader location: vertex attribute: tangent
    RL_SHADER_LOC_VERTEX_COLOR # Shader location: vertex attribute: color
    RL_SHADER_LOC_MATRIX_MVP # Shader location: matrix uniform: model-view-projection
    RL_SHADER_LOC_MATRIX_VIEW # Shader location: matrix uniform: view (camera transform)
    RL_SHADER_LOC_MATRIX_PROJECTION # Shader location: matrix uniform: projection
    RL_SHADER_LOC_MATRIX_MODEL # Shader location: matrix uniform: model (transform)
    RL_SHADER_LOC_MATRIX_NORMAL # Shader location: matrix uniform: normal
    RL_SHADER_LOC_VECTOR_VIEW # Shader location: vector uniform: view
    RL_SHADER_LOC_COLOR_DIFFUSE # Shader location: vector uniform: diffuse color
    RL_SHADER_LOC_COLOR_SPECULAR # Shader location: vector uniform: specular color
    RL_SHADER_LOC_COLOR_AMBIENT # Shader location: vector uniform: ambient color
    RL_SHADER_LOC_MAP_ALBEDO # Shader location: sampler2d texture: albedo (same as: RL_SHADER_LOC_MAP_DIFFUSE)
    RL_SHADER_LOC_MAP_METALNESS # Shader location: sampler2d texture: metalness (same as: RL_SHADER_LOC_MAP_SPECULAR)
    RL_SHADER_LOC_MAP_NORMAL # Shader location: sampler2d texture: normal
    RL_SHADER_LOC_MAP_ROUGHNESS # Shader location: sampler2d texture: roughness
    RL_SHADER_LOC_MAP_OCCLUSION # Shader location: sampler2d texture: occlusion
    RL_SHADER_LOC_MAP_EMISSION # Shader location: sampler2d texture: emission
    RL_SHADER_LOC_MAP_HEIGHT # Shader location: sampler2d texture: height
    RL_SHADER_LOC_MAP_CUBEMAP # Shader location: samplerCube texture: cubemap
    RL_SHADER_LOC_MAP_IRRADIANCE # Shader location: samplerCube texture: irradiance
    RL_SHADER_LOC_MAP_PREFILTER # Shader location: samplerCube texture: prefilter
    RL_SHADER_LOC_MAP_BRDF # Shader location: sampler2d texture: brdf
converter rlShaderLocationIndex2int32* (self: rlShaderLocationIndex): int32 = self.int32 
template RL_SHADER_LOC_MAP_DIFFUSE*(): auto = RL_SHADER_LOC_MAP_ALBEDO
template RL_SHADER_LOC_MAP_SPECULAR*(): auto = RL_SHADER_LOC_MAP_METALNESS
# Shader uniform data type
type rlShaderUniformDataType* = enum 
    RL_SHADER_UNIFORM_FLOAT = 0 # Shader uniform type: float
    RL_SHADER_UNIFORM_VEC2 # Shader uniform type: vec2 (2 float)
    RL_SHADER_UNIFORM_VEC3 # Shader uniform type: vec3 (3 float)
    RL_SHADER_UNIFORM_VEC4 # Shader uniform type: vec4 (4 float)
    RL_SHADER_UNIFORM_INT # Shader uniform type: int
    RL_SHADER_UNIFORM_IVEC2 # Shader uniform type: ivec2 (2 int)
    RL_SHADER_UNIFORM_IVEC3 # Shader uniform type: ivec3 (3 int)
    RL_SHADER_UNIFORM_IVEC4 # Shader uniform type: ivec4 (4 int)
    RL_SHADER_UNIFORM_SAMPLER2D # Shader uniform type: sampler2d
converter rlShaderUniformDataType2int32* (self: rlShaderUniformDataType): int32 = self.int32 
# Shader attribute data types
type rlShaderAttributeDataType* = enum 
    RL_SHADER_ATTRIB_FLOAT = 0 # Shader attribute type: float
    RL_SHADER_ATTRIB_VEC2 # Shader attribute type: vec2 (2 float)
    RL_SHADER_ATTRIB_VEC3 # Shader attribute type: vec3 (3 float)
    RL_SHADER_ATTRIB_VEC4 # Shader attribute type: vec4 (4 float)
converter rlShaderAttributeDataType2int32* (self: rlShaderAttributeDataType): int32 = self.int32 
# ------------------------------------------------------------------------------------
# Functions Declaration - Matrix operations
# ------------------------------------------------------------------------------------
proc rlMatrixMode*(mode: int32) {.RLAPI, importc: "rlMatrixMode".} # Choose the current matrix to be transformed
proc rlPushMatrix*() {.RLAPI, importc: "rlPushMatrix".} # Push the current matrix to stack
proc rlPopMatrix*() {.RLAPI, importc: "rlPopMatrix".} # Pop lattest inserted matrix from stack
proc rlLoadIdentity*() {.RLAPI, importc: "rlLoadIdentity".} # Reset current matrix to identity matrix
proc rlTranslatef*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlTranslatef".} # Multiply the current matrix by a translation matrix
proc rlRotatef*(angle: float32; x: float32; y: float32; z: float32) {.RLAPI, importc: "rlRotatef".} # Multiply the current matrix by a rotation matrix
proc rlScalef*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlScalef".} # Multiply the current matrix by a scaling matrix
proc rlMultMatrixf*(matf: float32) {.RLAPI, importc: "rlMultMatrixf".} # Multiply the current matrix by another matrix
proc rlFrustum*(left: float64; right: float64; bottom: float64; top: float64; znear: float64; zfar: float64) {.RLAPI, importc: "rlFrustum".} 
proc rlOrtho*(left: float64; right: float64; bottom: float64; top: float64; znear: float64; zfar: float64) {.RLAPI, importc: "rlOrtho".} 
proc rlViewport*(x: int32; y: int32; width: int32; height: int32) {.RLAPI, importc: "rlViewport".} # Set the viewport area
# ------------------------------------------------------------------------------------
# Functions Declaration - Vertex level operations
# ------------------------------------------------------------------------------------
proc rlBegin*(mode: int32) {.RLAPI, importc: "rlBegin".} # Initialize drawing mode (how to organize vertex)
proc rlEnd*() {.RLAPI, importc: "rlEnd".} # Finish vertex providing
proc rlVertex2i*(x: int32; y: int32) {.RLAPI, importc: "rlVertex2i".} # Define one vertex (position) - 2 int
proc rlVertex2f*(x: float32; y: float32) {.RLAPI, importc: "rlVertex2f".} # Define one vertex (position) - 2 float
proc rlVertex3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlVertex3f".} # Define one vertex (position) - 3 float
proc rlTexCoord2f*(x: float32; y: float32) {.RLAPI, importc: "rlTexCoord2f".} # Define one vertex (texture coordinate) - 2 float
proc rlNormal3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlNormal3f".} # Define one vertex (normal) - 3 float
proc rlColor4ub*(r: uint8; g: uint8; b: uint8; a: uint8) {.RLAPI, importc: "rlColor4ub".} # Define one vertex (color) - 4 byte
proc rlColor3f*(x: float32; y: float32; z: float32) {.RLAPI, importc: "rlColor3f".} # Define one vertex (color) - 3 float
proc rlColor4f*(x: float32; y: float32; z: float32; w: float32) {.RLAPI, importc: "rlColor4f".} # Define one vertex (color) - 4 float
# ------------------------------------------------------------------------------------
# Functions Declaration - OpenGL style functions (common to 1.1, 3.3+, ES2)
# NOTE: This functions are used to completely abstract raylib code from OpenGL layer,
# some of them are direct wrappers over OpenGL calls, some others are custom
# ------------------------------------------------------------------------------------
# Vertex buffers state
proc rlEnableVertexArray*(vaoId: uint32): bool {.RLAPI, importc: "rlEnableVertexArray".} # Enable vertex array (VAO, if supported)
proc rlDisableVertexArray*() {.RLAPI, importc: "rlDisableVertexArray".} # Disable vertex array (VAO, if supported)
proc rlEnableVertexBuffer*(id: uint32) {.RLAPI, importc: "rlEnableVertexBuffer".} # Enable vertex buffer (VBO)
proc rlDisableVertexBuffer*() {.RLAPI, importc: "rlDisableVertexBuffer".} # Disable vertex buffer (VBO)
proc rlEnableVertexBufferElement*(id: uint32) {.RLAPI, importc: "rlEnableVertexBufferElement".} # Enable vertex buffer element (VBO element)
proc rlDisableVertexBufferElement*() {.RLAPI, importc: "rlDisableVertexBufferElement".} # Disable vertex buffer element (VBO element)
proc rlEnableVertexAttribute*(index: uint32) {.RLAPI, importc: "rlEnableVertexAttribute".} # Enable vertex attribute index
proc rlDisableVertexAttribute*(index: uint32) {.RLAPI, importc: "rlDisableVertexAttribute".} # Disable vertex attribute index
proc rlEnableStatePointer*(vertexAttribType: int32; buffer: pointer) {.RLAPI, importc: "rlEnableStatePointer".} # Enable attribute state pointer
proc rlDisableStatePointer*(vertexAttribType: int32) {.RLAPI, importc: "rlDisableStatePointer".} # Disable attribute state pointer
# Textures state
proc rlActiveTextureSlot*(slot: int32) {.RLAPI, importc: "rlActiveTextureSlot".} # Select and active a texture slot
proc rlEnableTexture*(id: uint32) {.RLAPI, importc: "rlEnableTexture".} # Enable texture
proc rlDisableTexture*() {.RLAPI, importc: "rlDisableTexture".} # Disable texture
proc rlEnableTextureCubemap*(id: uint32) {.RLAPI, importc: "rlEnableTextureCubemap".} # Enable texture cubemap
proc rlDisableTextureCubemap*() {.RLAPI, importc: "rlDisableTextureCubemap".} # Disable texture cubemap
proc rlTextureParameters*(id: uint32; param: int32; value: int32) {.RLAPI, importc: "rlTextureParameters".} # Set texture parameters (filter, wrap)
# Shader state
proc rlEnableShader*(id: uint32) {.RLAPI, importc: "rlEnableShader".} # Enable shader program
proc rlDisableShader*() {.RLAPI, importc: "rlDisableShader".} # Disable shader program
# Framebuffer state
proc rlEnableFramebuffer*(id: uint32) {.RLAPI, importc: "rlEnableFramebuffer".} # Enable render texture (fbo)
proc rlDisableFramebuffer*() {.RLAPI, importc: "rlDisableFramebuffer".} # Disable render texture (fbo), return to default framebuffer
proc rlActiveDrawBuffers*(count: int32) {.RLAPI, importc: "rlActiveDrawBuffers".} # Activate multiple draw color buffers
# General render state
proc rlEnableColorBlend*() {.RLAPI, importc: "rlEnableColorBlend".} # Enable color blending
proc rlDisableColorBlend*() {.RLAPI, importc: "rlDisableColorBlend".} # Disable color blending
proc rlEnableDepthTest*() {.RLAPI, importc: "rlEnableDepthTest".} # Enable depth test
proc rlDisableDepthTest*() {.RLAPI, importc: "rlDisableDepthTest".} # Disable depth test
proc rlEnableDepthMask*() {.RLAPI, importc: "rlEnableDepthMask".} # Enable depth write
proc rlDisableDepthMask*() {.RLAPI, importc: "rlDisableDepthMask".} # Disable depth write
proc rlEnableBackfaceCulling*() {.RLAPI, importc: "rlEnableBackfaceCulling".} # Enable backface culling
proc rlDisableBackfaceCulling*() {.RLAPI, importc: "rlDisableBackfaceCulling".} # Disable backface culling
proc rlEnableScissorTest*() {.RLAPI, importc: "rlEnableScissorTest".} # Enable scissor test
proc rlDisableScissorTest*() {.RLAPI, importc: "rlDisableScissorTest".} # Disable scissor test
proc rlScissor*(x: int32; y: int32; width: int32; height: int32) {.RLAPI, importc: "rlScissor".} # Scissor test
proc rlEnableWireMode*() {.RLAPI, importc: "rlEnableWireMode".} # Enable wire mode
proc rlDisableWireMode*() {.RLAPI, importc: "rlDisableWireMode".} # Disable wire mode
proc rlSetLineWidth*(width: float32) {.RLAPI, importc: "rlSetLineWidth".} # Set the line drawing width
proc rlGetLineWidth*(): float32 {.RLAPI, importc: "rlGetLineWidth".} # Get the line drawing width
proc rlEnableSmoothLines*() {.RLAPI, importc: "rlEnableSmoothLines".} # Enable line aliasing
proc rlDisableSmoothLines*() {.RLAPI, importc: "rlDisableSmoothLines".} # Disable line aliasing
proc rlEnableStereoRender*() {.RLAPI, importc: "rlEnableStereoRender".} # Enable stereo rendering
proc rlDisableStereoRender*() {.RLAPI, importc: "rlDisableStereoRender".} # Disable stereo rendering
proc rlIsStereoRenderEnabled*(): bool {.RLAPI, importc: "rlIsStereoRenderEnabled".} # Check if stereo render is enabled
proc rlClearColor*(r: uint8; g: uint8; b: uint8; a: uint8) {.RLAPI, importc: "rlClearColor".} # Clear color buffer with color
proc rlClearScreenBuffers*() {.RLAPI, importc: "rlClearScreenBuffers".} # Clear used screen buffers (color and depth)
proc rlCheckErrors*() {.RLAPI, importc: "rlCheckErrors".} # Check and log OpenGL error codes
proc rlSetBlendMode*(mode: int32) {.RLAPI, importc: "rlSetBlendMode".} # Set blending mode
proc rlSetBlendFactors*(glSrcFactor: int32; glDstFactor: int32; glEquation: int32) {.RLAPI, importc: "rlSetBlendFactors".} # Set blending mode factor and equation (using OpenGL factors)
# ------------------------------------------------------------------------------------
# Functions Declaration - rlgl functionality
# ------------------------------------------------------------------------------------
# rlgl initialization functions
proc rlglInit*(width: int32; height: int32) {.RLAPI, importc: "rlglInit".} # Initialize rlgl (buffers, shaders, textures, states)
proc rlglClose*() {.RLAPI, importc: "rlglClose".} # De-inititialize rlgl (buffers, shaders, textures)
proc rlLoadExtensions*(loader: pointer) {.RLAPI, importc: "rlLoadExtensions".} # Load OpenGL extensions (loader function required)
proc rlGetVersion*(): int32 {.RLAPI, importc: "rlGetVersion".} # Get current OpenGL version
proc rlGetFramebufferWidth*(): int32 {.RLAPI, importc: "rlGetFramebufferWidth".} # Get default framebuffer width
proc rlGetFramebufferHeight*(): int32 {.RLAPI, importc: "rlGetFramebufferHeight".} # Get default framebuffer height
proc rlGetTextureIdDefault*(): uint32 {.RLAPI, importc: "rlGetTextureIdDefault".} # Get default texture id
proc rlGetShaderIdDefault*(): uint32 {.RLAPI, importc: "rlGetShaderIdDefault".} # Get default shader id
proc rlGetShaderLocsDefault*(): pointer {.RLAPI, importc: "rlGetShaderLocsDefault".} # Get default shader locations
# Render batch management
# NOTE: rlgl provides a default render batch to behave like OpenGL 1.1 immediate mode
# but this render batch API is exposed in case of custom batches are required
proc rlLoadRenderBatch*(numBuffers: int32; bufferElements: int32): rlRenderBatch {.RLAPI, importc: "rlLoadRenderBatch".} # Load a render batch system
proc rlUnloadRenderBatch*(batch: rlRenderBatch) {.RLAPI, importc: "rlUnloadRenderBatch".} # Unload render batch system
proc rlDrawRenderBatch*(batch: ptr rlRenderBatch) {.RLAPI, importc: "rlDrawRenderBatch".} # Draw render batch data (Update->Draw->Reset)
proc rlSetRenderBatchActive*(batch: ptr rlRenderBatch) {.RLAPI, importc: "rlSetRenderBatchActive".} # Set the active render batch for rlgl (NULL for default internal)
proc rlDrawRenderBatchActive*() {.RLAPI, importc: "rlDrawRenderBatchActive".} # Update and draw internal render batch
proc rlCheckRenderBatchLimit*(vCount: int32): bool {.RLAPI, importc: "rlCheckRenderBatchLimit".} # Check internal buffer overflow for a given number of vertex
proc rlSetTexture*(id: uint32) {.RLAPI, importc: "rlSetTexture".} # Set current texture for render batch and check buffers limits
# ------------------------------------------------------------------------------------------------------------------------
# Vertex buffers management
proc rlLoadVertexArray*(): uint32 {.RLAPI, importc: "rlLoadVertexArray".} # Load vertex array (vao) if supported
proc rlLoadVertexBuffer*(buffer: pointer; size: int32; dynamic: bool): uint32 {.RLAPI, importc: "rlLoadVertexBuffer".} # Load a vertex buffer attribute
proc rlLoadVertexBufferElement*(buffer: pointer; size: int32; dynamic: bool): uint32 {.RLAPI, importc: "rlLoadVertexBufferElement".} # Load a new attributes element buffer
proc rlUpdateVertexBuffer*(bufferId: uint32; data: pointer; dataSize: int32; offset: int32) {.RLAPI, importc: "rlUpdateVertexBuffer".} # Update GPU buffer with new data
proc rlUpdateVertexBufferElements*(id: uint32; data: pointer; dataSize: int32; offset: int32) {.RLAPI, importc: "rlUpdateVertexBufferElements".} # Update vertex buffer elements with new data
proc rlUnloadVertexArray*(vaoId: uint32) {.RLAPI, importc: "rlUnloadVertexArray".} 
proc rlUnloadVertexBuffer*(vboId: uint32) {.RLAPI, importc: "rlUnloadVertexBuffer".} 
proc rlSetVertexAttribute*(index: uint32; compSize: int32; typex: int32; normalized: bool; stride: int32; pointer: pointer) {.RLAPI, importc: "rlSetVertexAttribute".} 
proc rlSetVertexAttributeDivisor*(index: uint32; divisor: int32) {.RLAPI, importc: "rlSetVertexAttributeDivisor".} 
proc rlSetVertexAttributeDefault*(locIndex: int32; value: pointer; attribType: int32; count: int32) {.RLAPI, importc: "rlSetVertexAttributeDefault".} # Set vertex attribute default value
proc rlDrawVertexArray*(offset: int32; count: int32) {.RLAPI, importc: "rlDrawVertexArray".} 
proc rlDrawVertexArrayElements*(offset: int32; count: int32; buffer: pointer) {.RLAPI, importc: "rlDrawVertexArrayElements".} 
proc rlDrawVertexArrayInstanced*(offset: int32; count: int32; instances: int32) {.RLAPI, importc: "rlDrawVertexArrayInstanced".} 
proc rlDrawVertexArrayElementsInstanced*(offset: int32; count: int32; buffer: pointer; instances: int32) {.RLAPI, importc: "rlDrawVertexArrayElementsInstanced".} 
# Textures management
proc rlLoadTexture*(data: pointer; width: int32; height: int32; format: int32; mipmapCount: int32): uint32 {.RLAPI, importc: "rlLoadTexture".} # Load texture in GPU
proc rlLoadTextureDepth*(width: int32; height: int32; useRenderBuffer: bool): uint32 {.RLAPI, importc: "rlLoadTextureDepth".} # Load depth texture/renderbuffer (to be attached to fbo)
proc rlLoadTextureCubemap*(data: pointer; size: int32; format: int32): uint32 {.RLAPI, importc: "rlLoadTextureCubemap".} # Load texture cubemap
proc rlUpdateTexture*(id: uint32; offsetX: int32; offsetY: int32; width: int32; height: int32; format: int32; data: pointer) {.RLAPI, importc: "rlUpdateTexture".} # Update GPU texture with new data
proc rlGetGlTextureFormats*(format: int32; glInternalFormat: pointer; glFormat: pointer; glType: pointer) {.RLAPI, importc: "rlGetGlTextureFormats".} # Get OpenGL internal formats
proc rlGetPixelFormatName*(format: uint32): cstring {.RLAPI, importc: "rlGetPixelFormatName".} # Get name string for pixel format
proc rlUnloadTexture*(id: uint32) {.RLAPI, importc: "rlUnloadTexture".} # Unload texture from GPU memory
proc rlGenTextureMipmaps*(id: uint32; width: int32; height: int32; format: int32; mipmaps: pointer) {.RLAPI, importc: "rlGenTextureMipmaps".} # Generate mipmap data for selected texture
proc rlReadTexturePixels*(id: uint32; width: int32; height: int32; format: int32): pointer {.RLAPI, importc: "rlReadTexturePixels".} # Read texture pixel data
proc rlReadScreenPixels*(width: int32; height: int32): uint8 {.RLAPI, importc: "rlReadScreenPixels".} # Read screen pixel data (color buffer)
# Framebuffer management (fbo)
proc rlLoadFramebuffer*(width: int32; height: int32): uint32 {.RLAPI, importc: "rlLoadFramebuffer".} # Load an empty framebuffer
proc rlFramebufferAttach*(fboId: uint32; texId: uint32; attachType: int32; texType: int32; mipLevel: int32) {.RLAPI, importc: "rlFramebufferAttach".} # Attach texture/renderbuffer to a framebuffer
proc rlFramebufferComplete*(id: uint32): bool {.RLAPI, importc: "rlFramebufferComplete".} # Verify framebuffer is complete
proc rlUnloadFramebuffer*(id: uint32) {.RLAPI, importc: "rlUnloadFramebuffer".} # Delete framebuffer from GPU
# Shaders management
proc rlLoadShaderCode*(vsCode: cstring; fsCode: cstring): uint32 {.RLAPI, importc: "rlLoadShaderCode".} # Load shader from code strings
proc rlCompileShader*(shaderCode: cstring; typex: int32): uint32 {.RLAPI, importc: "rlCompileShader".} # Compile custom shader and return shader id (type: RL_VERTEX_SHADER, RL_FRAGMENT_SHADER, RL_COMPUTE_SHADER)
proc rlLoadShaderProgram*(vShaderId: uint32; fShaderId: uint32): uint32 {.RLAPI, importc: "rlLoadShaderProgram".} # Load custom shader program
proc rlUnloadShaderProgram*(id: uint32) {.RLAPI, importc: "rlUnloadShaderProgram".} # Unload shader program
proc rlGetLocationUniform*(shaderId: uint32; uniformName: cstring): int32 {.RLAPI, importc: "rlGetLocationUniform".} # Get shader location uniform
proc rlGetLocationAttrib*(shaderId: uint32; attribName: cstring): int32 {.RLAPI, importc: "rlGetLocationAttrib".} # Get shader location attribute
proc rlSetUniform*(locIndex: int32; value: pointer; uniformType: int32; count: int32) {.RLAPI, importc: "rlSetUniform".} # Set shader value uniform
proc rlSetUniformMatrix*(locIndex: int32; mat: Matrix) {.RLAPI, importc: "rlSetUniformMatrix".} # Set shader value matrix
proc rlSetUniformSampler*(locIndex: int32; textureId: uint32) {.RLAPI, importc: "rlSetUniformSampler".} # Set shader value sampler
proc rlSetShader*(id: uint32; locs: pointer) {.RLAPI, importc: "rlSetShader".} # Set shader currently active (id and locations)
# Compute shader management
proc rlLoadComputeShaderProgram*(shaderId: uint32): uint32 {.RLAPI, importc: "rlLoadComputeShaderProgram".} # Load compute shader program
proc rlComputeShaderDispatch*(groupX: uint32; groupY: uint32; groupZ: uint32) {.RLAPI, importc: "rlComputeShaderDispatch".} # Dispatch compute shader (equivalent to *draw* for graphics pilepine)
# Shader buffer storage object management (ssbo)
proc rlLoadShaderBuffer*(size: unsigned long long; data: pointer; usageHint: int32): uint32 {.RLAPI, importc: "rlLoadShaderBuffer".} # Load shader storage buffer object (SSBO)
proc rlUnloadShaderBuffer*(ssboId: uint32) {.RLAPI, importc: "rlUnloadShaderBuffer".} # Unload shader storage buffer object (SSBO)
proc rlUpdateShaderBufferElements*(id: uint32; data: pointer; dataSize: unsigned long long; offset: unsigned long long) {.RLAPI, importc: "rlUpdateShaderBufferElements".} # Update SSBO buffer data
proc rlGetShaderBufferSize*(id: uint32): unsigned long long {.RLAPI, importc: "rlGetShaderBufferSize".} # Get SSBO buffer size
proc rlReadShaderBufferElements*(id: uint32; dest: pointer; count: unsigned long long; offset: unsigned long long) {.RLAPI, importc: "rlReadShaderBufferElements".} # Bind SSBO buffer
proc rlBindShaderBuffer*(id: uint32; index: uint32) {.RLAPI, importc: "rlBindShaderBuffer".} # Copy SSBO buffer data
# Buffer management
proc rlCopyBuffersElements*(destId: uint32; srcId: uint32; destOffset: unsigned long long; srcOffset: unsigned long long; count: unsigned long long) {.RLAPI, importc: "rlCopyBuffersElements".} # Copy SSBO buffer data
proc rlBindImageTexture*(id: uint32; index: uint32; format: uint32; readonly: int32) {.RLAPI, importc: "rlBindImageTexture".} # Bind image texture
# Matrix state management
proc rlGetMatrixModelview*(): Matrix {.RLAPI, importc: "rlGetMatrixModelview".} # Get internal modelview matrix
proc rlGetMatrixProjection*(): Matrix {.RLAPI, importc: "rlGetMatrixProjection".} # Get internal projection matrix
proc rlGetMatrixTransform*(): Matrix {.RLAPI, importc: "rlGetMatrixTransform".} # Get internal accumulated transform matrix
proc rlGetMatrixProjectionStereo*(eye: int32): Matrix {.RLAPI, importc: "rlGetMatrixProjectionStereo".} # Get internal projection matrix for stereo render (selected eye)
proc rlGetMatrixViewOffsetStereo*(eye: int32): Matrix {.RLAPI, importc: "rlGetMatrixViewOffsetStereo".} # Get internal view offset matrix for stereo render (selected eye)
proc rlSetMatrixProjection*(proj: Matrix) {.RLAPI, importc: "rlSetMatrixProjection".} # Set a custom projection matrix (replaces internal projection matrix)
proc rlSetMatrixModelview*(view: Matrix) {.RLAPI, importc: "rlSetMatrixModelview".} # Set a custom modelview matrix (replaces internal modelview matrix)
proc rlSetMatrixProjectionStereo*(right: Matrix; left: Matrix) {.RLAPI, importc: "rlSetMatrixProjectionStereo".} # Set eyes projection matrices for stereo rendering
proc rlSetMatrixViewOffsetStereo*(right: Matrix; left: Matrix) {.RLAPI, importc: "rlSetMatrixViewOffsetStereo".} # Set eyes view offsets matrices for stereo rendering
# Quick and dirty cube/quad buffers load->draw->unload
proc rlLoadDrawCube*() {.RLAPI, importc: "rlLoadDrawCube".} # Load and draw a cube
proc rlLoadDrawQuad*() {.RLAPI, importc: "rlLoadDrawQuad".} # Load and draw a quad
# 
#   RLGL IMPLEMENTATION
# 
type rlglLoadProc* = proc()
# ----------------------------------------------------------------------------------
# Global Variables Definition
# ----------------------------------------------------------------------------------