cmake_minimum_required(VERSION 3.22)

project(ijkplayer)

# 为 C 语言添加编译选项以忽略 -Wint-conversion 警告
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wno-int-conversion")
# 为 C++ 语言添加编译选项以忽略 -Wint-conversion 警告
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-int-conversion")

if (ANDROID_ABI STREQUAL "armeabi-v7a")
    set(ARCH "armv7a")
elseif (ANDROID_ABI STREQUAL "arm64-v8a")
    set(ARCH "arm64")
elseif (ANDROID_ABI STREQUAL "x86")
    set(ARCH "x86")
elseif (ANDROID_ABI STREQUAL "x86_64")
    set(ARCH "x86_64")
else()
    message(WARNING "Unsupported ANDROID_ABI: ${ANDROID_ABI}")
endif()


execute_process(
        COMMAND
        "${CMAKE_CURRENT_SOURCE_DIR}/ijkmedia/ijkplayer/version.sh" "${CMAKE_CURRENT_SOURCE_DIR}/ijkmedia/ijkplayer" ijkversion.h
        OUTPUT_VARIABLE _stdout
        ERROR_VARIABLE _stderr
        OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_STRIP_TRAILING_WHITESPACE
)

set(ijkmedia ${CMAKE_CURRENT_SOURCE_DIR}/ijkmedia)
include_directories(${ijkmedia})
include_directories(${ijkmedia}/ijkj4a)
include_directories(${ijkmedia}/ijksdl)
include_directories(${ijkmedia}/ijkplayer)

file(GLOB_RECURSE SOURCE_IJKJ4A ${ijkmedia}/ijkj4a/*.c  ${ijkmedia}/ijkj4a/*.cpp)
file(GLOB_RECURSE SOURCE_SDL ${ijkmedia}/ijksdl/*.c  ${ijkmedia}/ijksdl/*.cpp)
file(GLOB_RECURSE SOURCE_IJKPLAYER ${ijkmedia}/ijkplayer/*.c ${ijkmedia}/ijkplayer/*.cpp)
file(GLOB_RECURSE SOURCE_SOUNDTOUCH ${ijkmedia}/ijksoundtouch/ijksoundtouch_wrap.cpp)

add_library(${CMAKE_PROJECT_NAME}
    SHARED
    prof.c
    ${SOURCE_IJKJ4A}
    ${SOURCE_SDL}
    ${SOURCE_IJKPLAYER}
    ${SOURCE_SOUNDTOUCH}
)

set(FFMPEG_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-libs/ijkffmpeg/ijkffmpeg-${ARCH}/lib)
set(OPENSSL_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-libs/openssl/openssl-${ARCH}/lib)
set(SOUNDTOUCH_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-libs/soundtouch/soundtouch-${ARCH}/lib)
set(YUV_LIB_DIR ${CMAKE_CURRENT_SOURCE_DIR}/third-libs/yuv/yuv-${ARCH}/lib)

include_directories(
    third-libs/ijkffmpeg/ijkffmpeg-${ARCH}/include
    third-libs/soundtouch/soundtouch-${ARCH}/include
    third-libs/yuv/yuv-${ARCH}/include
)

# soundtouch
add_library(soundtouch-lib STATIC IMPORTED)
set_target_properties(soundtouch-lib PROPERTIES
    IMPORTED_LOCATION ${SOUNDTOUCH_LIB_DIR}/libSoundTouch.a
)

# yuv
add_library(yuv-lib STATIC IMPORTED)
set_target_properties(yuv-lib PROPERTIES
    IMPORTED_LOCATION ${YUV_LIB_DIR}/libyuv.a
)

# openssl 创建一个 INTERFACE 库，用于逻辑上组合多个静态库
add_library(openssl-lib INTERFACE)
# 依次为 INTERFACE 库添加链接库
target_link_libraries(openssl-lib INTERFACE
    ${OPENSSL_LIB_DIR}/libcrypto.a
    ${OPENSSL_LIB_DIR}/libssl.a
)

# ijkffmpeg 创建一个 INTERFACE 库，用于逻辑上组合多个静态库
add_library(ijkffmpeg-lib INTERFACE)
# 依次为 INTERFACE 库添加链接库,注意avformat要放到前面
target_link_libraries(ijkffmpeg-lib INTERFACE
    ${FFMPEG_LIB_DIR}/libavformat.a
    ${FFMPEG_LIB_DIR}/libavcodec.a
    ${FFMPEG_LIB_DIR}/libavfilter.a
    ${FFMPEG_LIB_DIR}/libswresample.a
    ${FFMPEG_LIB_DIR}/libswscale.a
    ${FFMPEG_LIB_DIR}/libavutil.a
)

find_library(z-lib z REQUIRED)
# cmake automatic order libz before ffmpeg,so we specify the order,and ${CMAKE_PROJECT_NAME} no need contain libz
target_link_libraries(ijkffmpeg-lib INTERFACE ${z-lib} openssl-lib)

target_link_libraries(${CMAKE_PROJECT_NAME}
    ijkffmpeg-lib
    yuv-lib
    soundtouch-lib
    log
    android
    EGL
    GLESv2
    jnigraphics
    OpenSLES
    m
)
