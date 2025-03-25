# ijkplayer

使用最新 IDE 编译了 B 站 ijkplayer，不做功能上的开发，仅为了让老用户能够在新设备上继续使用。

## 特色：

将依赖库编译成静态库，预编译出了 Android 平台的 ijkpalyer.aar 和 iOS 平台预编译的 xcframework。

## 对比

| 类别         | B 站 ijkplayer                       | debugly/ijkplayer          | 备注                               |
| ---------- | ----------------------------------- | -------------------------- | -------------------------------- |
| 安卓库        | ijkplayer.so,ijkffmpeg.so,ijksdl.so | ijkplayer.arr              | 从三个so缩减成一个arr，内部是一个 ijkpalyer.so |
| iOS库       | -                                   | IJKMediaPlayer.xcframework | 通过 xcframework 分发                |
| ABI        | armv5 armv7a arm64 x86 x86_64       | armv7a arm64 x86 x86_64    | 一套cmake支持所有ABI，无须每个 ABI 一个文件夹    |
| NDK        | r10e                                | r27c                       | 使用最新最稳定的 NDK                     |
| openssl    | 可选                                  | 默认包含                       | 升级到了最新 1.1.1w                    |
| yuv        | 源码编译                                | 预编译成.a                     | 升级到了较新的stable分支                  |
| soundtouch | 源码编译                                | 预编译成.a                     | 升级到了最新 2.3.3                     |
| soxr       | 支持                                  | 不支持                        | 音频重采样库，暂不编译了，有问题时可加上             |

老旧项目一直在使用 B 站 ijkplayer 并且功能完全可以满足的情况下，可直接升级上来，好处是升级了编译工具链，能够正常在最新的安卓15 和 iOS18 上正常运行。

## FSPlayer

如果 ijkplayer 功能不能满足当前复杂的业务需求，则可以使用 [fsplayer](https://github.com/debugly/fsplayer) ，提供了更加强劲的功能。