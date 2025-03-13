    cmake_minimum_required(VERSION 3.22)

    project(ijkplayer)
    target_link_libraries(${CMAKE_PROJECT_NAME}
        android
        log
        OpenSLES
        EGL
        GLESv2
        z
    )

