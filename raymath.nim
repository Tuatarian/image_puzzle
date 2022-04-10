# 
#   raymath v1.5 - Math functions to work with Vector2, Vector3, Matrix and Quaternions
# 
#   CONFIGURATION:
# 
#   #define RAYMATH_IMPLEMENTATION
#       Generates the implementation of the library into the included file.
#       If not defined, the library is in header only mode and can be included in other headers
#       or source files without problems. But only ONE file should hold the implementation.
# 
#   #define RAYMATH_STATIC_INLINE
#       Define static inline functions code, so #include header suffices for use.
#       This may use up lots of memory.
# 
#   CONVENTIONS:
# 
#     - Functions are always self-contained, no function use another raymath function inside,
#       required code is directly re-implemented inside
#     - Functions input parameters are always received by value (2 unavoidable exceptions)
#     - Functions use always a "result" variable for return
#     - Functions are always defined inline
#     - Angles are always in radians (DEG2RAD/RAD2DEG macros provided for convenience)
# 
# 
#   LICENSE: zlib/libpng
# 
#   Copyright (c) 2015-2022 Ramon Santamaria (@raysan5)
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
template RAYMATH_H*(): auto = RAYMATH_H
# Function specifiers definition
{.pragma: RMAPI, cdecl, discardable, dynlib: "libraylib" & LEXT.}
# ----------------------------------------------------------------------------------
# Defines and Macros
# ----------------------------------------------------------------------------------
# Get float vector for Matrix
# Get float vector for Vector3
# ----------------------------------------------------------------------------------
# Types and Structures Definition
# ----------------------------------------------------------------------------------
# Vector2 type
type Vector2* {.bycopy.} = object
    x*: float32 
    y*: float32 
template RL_VECTOR2_TYPE*(): auto = RL_VECTOR2_TYPE
# Vector3 type
type Vector3* {.bycopy.} = object
    x*: float32 
    y*: float32 
    z*: float32 
template RL_VECTOR3_TYPE*(): auto = RL_VECTOR3_TYPE
# Vector4 type
type Vector4* {.bycopy.} = object
    x*: float32 
    y*: float32 
    z*: float32 
    w*: float32 
template RL_VECTOR4_TYPE*(): auto = RL_VECTOR4_TYPE
# Quaternion type
type Quaternion* = Vector4
template RL_QUATERNION_TYPE*(): auto = RL_QUATERNION_TYPE
# Matrix type (OpenGL style 4x4 - right handed, column major)
type Matrix* {.bycopy.} = object
    m0*, m4*, m8*, m12*: float32 # Matrix first row (4 components)
    m1*, m5*, m9*, m13*: float32 # Matrix second row (4 components)
    m2*, m6*, m10*, m14*: float32 # Matrix third row (4 components)
    m3*, m7*, m11*, m15*: float32 # Matrix fourth row (4 components)
template RL_MATRIX_TYPE*(): auto = RL_MATRIX_TYPE
# NOTE: Helper types to be used instead of array return types for *ToFloat functions
type float3* {.bycopy.} = object
    v*: array[0..2, float32] 
type float16* {.bycopy.} = object
    # Skipped another v
# ----------------------------------------------------------------------------------
# Module Functions Definition - Utils math
# ----------------------------------------------------------------------------------
# Clamp float value
# Calculate linear interpolation between two floats
# Normalize input value within input range
# Remap input value within input range to output range
# ----------------------------------------------------------------------------------
# Module Functions Definition - Vector2 math
# ----------------------------------------------------------------------------------
# Vector with components value 0.0f
# Vector with components value 1.0f
# Add two vectors (v1 + v2)
# Add vector and float value
# Subtract two vectors (v1 - v2)
# Subtract vector by float value
# Calculate vector length
# Calculate vector square length
# Calculate two vectors dot product
# Calculate distance between two vectors
# Calculate square distance between two vectors
# Calculate angle from two vectors
# Scale vector (multiply by value)
# Multiply vector by vector
# Negate vector
# Divide vector by vector
# Normalize provided vector
# Transforms a Vector2 by a given Matrix
# Calculate linear interpolation between two vectors
# Calculate reflected vector to normal
# Rotate vector by angle
# Move Vector towards target
# ----------------------------------------------------------------------------------
# Module Functions Definition - Vector3 math
# ----------------------------------------------------------------------------------
# Vector with components value 0.0f
# Vector with components value 1.0f
# Add two vectors
# Add vector and float value
# Subtract two vectors
# Subtract vector by float value
# Multiply vector by scalar
# Multiply vector by vector
# Calculate two vectors cross product
# Calculate one vector perpendicular vector
# Calculate vector length
# Calculate vector square length
# Calculate two vectors dot product
# Calculate distance between two vectors
# Calculate square distance between two vectors
# Calculate angle between two vectors
# Negate provided vector (invert direction)
# Divide vector by vector
# Normalize provided vector
# Orthonormalize provided vectors
# Makes vectors normalized and orthogonal to each other
# Gram-Schmidt function implementation
# Transforms a Vector3 by a given Matrix
# Transform a vector by quaternion rotation
# Calculate linear interpolation between two vectors
# Calculate reflected vector to normal
# Get min value for each pair of components
# Get max value for each pair of components
# Compute barycenter coordinates (u, v, w) for point p with respect to triangle (a, b, c)
# NOTE: Assumes P is on the plane of the triangle
# Projects a Vector3 from screen space into object space
# NOTE: We are avoiding calling other raymath functions despite available
# Get Vector3 as float array
# ----------------------------------------------------------------------------------
# Module Functions Definition - Matrix math
# ----------------------------------------------------------------------------------
# Compute matrix determinant
# Get the trace of the matrix (sum of the values along the diagonal)
# Transposes provided matrix
# Invert provided matrix
# Get identity matrix
# Add two matrices
# Subtract two matrices (left - right)
# Get two matrix multiplication
# NOTE: When multiplying matrices... the order matters!
# Get translation matrix
# Create rotation matrix from axis and angle
# NOTE: Angle should be provided in radians
# Get x-rotation matrix (angle in radians)
# Get y-rotation matrix (angle in radians)
# Get z-rotation matrix (angle in radians)
# Get xyz-rotation matrix (angles in radians)
# Get zyx-rotation matrix (angles in radians)
# Get scaling matrix
# Get perspective projection matrix
# Get perspective projection matrix
# NOTE: Angle should be provided in radians
# Get orthographic projection matrix
# Get camera look-at matrix (view matrix)
# Get float array of matrix data
# ----------------------------------------------------------------------------------
# Module Functions Definition - Quaternion math
# ----------------------------------------------------------------------------------
# Add two quaternions
# Add quaternion and float value
# Subtract two quaternions
# Subtract quaternion and float value
# Get identity quaternion
# Computes the length of a quaternion
# Normalize provided quaternion
# Invert provided quaternion
# Calculate two quaternion multiplication
# Scale quaternion by float value
# Divide two quaternions
# Calculate linear interpolation between two quaternions
# Calculate slerp-optimized interpolation between two quaternions
# Calculates spherical linear interpolation between two quaternions
# Calculate quaternion based on the rotation from one vector to another
# Get a quaternion for a given rotation matrix
# Get a matrix for a given quaternion
# Get rotation quaternion for an angle and axis
# NOTE: angle must be provided in radians
# Get the rotation angle and axis for a given quaternion
# Get the quaternion equivalent to Euler angles
# NOTE: Rotation order is ZYX
# Get the Euler angles equivalent to quaternion (roll, pitch, yaw)
# NOTE: Angles are returned in a Vector3 struct in radians
# Transform a quaternion given a transformation matrix