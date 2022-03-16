# Gigabit-Ethernet
基于 UDP 协议的千兆以太网视频外挂ddr3存储并hdmi显示和心率数据传输 
<img width="448" alt="image" src="https://user-images.githubusercontent.com/94519594/158519212-5eda10da-4d64-4078-bbb5-49d55822b0de.png">
1．软件环境：Vivado 2018.3、ModelSim、 Wireshark、 Matlab 2． 硬件环境：xc7a75tfgg484-2、MT41K128M16JT、vsc8601xkn
3．项目描述： 

(1)Matlab 与板卡通过UDP 协议建立通讯，由Matlab 把视频转为 mat 文件，然后下发给板卡。 

(2)板卡从 RJ45 接收数据，PHY 芯片将差分信号转为双沿触发信号，FPGA 与PHY 芯片通讯采用RGMII

协议。 

(3)FPGA 控制逻辑按功能可分四个部分，IDDR_CTRL 模块将PHY 芯片的双沿采样信号转化为单沿采样信号，PHY 芯片的参考时钟 125MHz，数据位宽 4bit，故传输速率可达到 125x4x2=1000Mbps； DDR_CTRL 模块用于对 MIG 的 IP 核进行封装，从而使用户接口时序更加简洁、易用；HDMI 驱动模块用于 HDMI 设备的驱动显示；ODDR_CTRL 模块则用于产生一个心跳速率的 UDP 包，通过以太网协议传回上位机，验证整个数据传输回路。 
	
(4)实现效果：HDMI 显示设备可以正常显示动画视频，显示模式 1024x768@60Hz，上位机软件 Wireshark

获取到心跳速率 UDP 包，且 CRC 校验正确。
