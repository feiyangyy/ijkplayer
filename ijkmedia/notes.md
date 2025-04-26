### 1. avcodec 相关
1. **AVCodecContext** 是不是线程安全的?
    * 不是，如果动态调整AVCodecContext, 需要认为保证安全，或者注意时序关系
    * 两种方案：加速、解码线程接收事件队列，动态调整
2. 