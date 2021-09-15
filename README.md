# FPGA_NES, CHN: 为中文fpga学习环境添砖加瓦
FPGA Nintendo Entertainment System

# 支持的开发板和综合工具
当前基于HSEDA的7A35开发板进行开发。
使用vivado2020.1版本。

# 工程使用方法
从github上下载工程文件夹后，需要把工程文件夹改名为FPGA_NES。执行run.bat脚本，脚本会在FPGA_NES文件夹上一层生成工程文件夹。
注意，需要将run.bat脚本的最后一行的C:\Xilinx\Vivado\2020.1\bin\vivado修改为用户安装的vivado所在路径。
各历史版本的bit文件存放在DESIGN.res文件夹下。

# 串口通信
使用串口工具，发送reg_rd 0，可以读出fpga版本号，注意需要设置为HEX显示。
发送reg_wr 1 AB，可以向读写测试寄存器写入数据0xAB，然后发送reg_rd 1，可以读出读写测试寄存器中的值进行验证。

# 加载rom
通过串口发送load_rom，然后选择rom文件发送，文件发送完毕后，发送done退出。