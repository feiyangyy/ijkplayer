### 1. avcodec 相关
1. **AVCodecContext** 是不是线程安全的?
    * 不是，如果动态调整AVCodecContext, 需要认为保证安全，或者注意时序关系
    * 两种方案：加速、解码线程接收事件队列，动态调整
2. AVPacket 代表什么数据
    * demuxer输出的数据单元，对于264这类视频流来说，通常是一个或者多个连续的NALU单元

### 2. 播放器相关

#### 播放下溢
1. 播放下溢，是指播放速度快，但是缓冲区内部没有数据，导致播放停顿
2. packet-buffering 可以一定程度上缓解播放速度过快的问题，但是如果输入就是很慢（磁盘、**网络**），那么是没办法解决的。
3. ffplay 可以设置-nobuffer 模式，以降低延迟，但是代价就是卡顿多发

有人为了控制ffplay的延迟，设置:
```java
mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "packet-buffering", 0);
mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "fflags", "nobuffer");
```
就是为了消除因为缓存而引入的延迟

#### infbuf
infbuf 取消缓冲限制，比如rtp over udp 这种，服务端不断推流，不会care 客户端是否接受，此时如果客户端受不了就会丢帧

rtp over tcp, 会因为发送断的滑动窗口为0而无法发送，进而阻塞

infbuf 只适合要服务端持续推流，而播放端要稳定接收所有数据的情况

对于ffplay 主动拉流的情况，如HLS， 开infbuf 影响不大，因为主动拉流 播放器有主动控制权

#### probesize
探测什么？
```
1. 有多少流
2. 每个流的基本参数（采样率、分辨率、帧率...)
3. 时间戳情况?
4. bitrate 估算
```

1. 用于再打开输入流时，至多读取多少字节，来确定输入格式， 比如各媒体流的codec信息

2. 设置过大可能会影响启动速度，但识别↑， 过小则想法，但是可能会失败

3. 具体工作由AvFormat 执行，avformat_open_input 的阻塞时间受该参数影响

4. 某些确认的封装，如mp4/flv, 很规整，可以设置比较小的probesize， 而像rtsp/rtmp 这种，**推流起始数据可能很乱(why?)**，要适当提升probesize

5. **ffmpeg 如何探测媒体格式? 类似于ffprobe 分析媒体格式等**

以下来自gpt-4:
```
用户输入 URL
      ↓
调用 avformat_open_input()
      ↓
内部创建 AVFormatContext
      ↓
调用 av_probe_input_buffer2()
      ↓
 读取数据（受 probesize 限制）
      ↓
 猜测文件格式 (guess container format)
      ↓
确定格式成功
      ↓
调用 avformat_find_stream_info()
      ↓
 继续读取数据（继续受 probesize/analyzeduration控制）
      ↓
分析流信息：
  - 查找视频流、音频流
  - 分析帧率
  - 估算时长
  - 估算比特率
（分析数据时长受 analyzeduration 限制）
      ↓
探测完成，返回成功

```

```
【开始】用户调用 avformat_open_input()
    ↓
创建 AVFormatContext
    ↓
调用 av_probe_input_buffer2()
    ↓
【此处受 -probesize 限制】
  - 连续读数据
  - 读的最大字节数 <= probesize
  - 期间试探各种format probe function
    ↓
【确定container格式】
如果探测成功
    ↓
继续执行 avformat_find_stream_info()
    ↓
【此处继续受 -probesize / -analyzeduration 限制】
  - 不断读更多数据包 (AVPacket)
  - 收集音频帧/视频帧
  - 推断出流的：
      * 编解码器类型
      * 宽高、码率
      * 时长、帧率
  - 读取数据量不能超过 probesize
  - 分析的时间跨度不能超过 analyzeduration
    ↓
【流信息探测完成】
    ↓
返回 AVFormatContext (初始化完成，所有流都识别)
    ↓
【后续开始正常解码】
```


#### analyzeduration
和上面类似，只不过这个是控制探测工作的时间上限，单位是微秒，一般要和上面的参数一起调