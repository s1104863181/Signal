from PySide2.QtWidgets import QApplication, QMessageBox
from PySide2.QtUiTools import QUiLoader
import serial
import serial.tools.list_ports
from threading import Thread
import re


ckopen=0

ser = serial.Serial()
class Stats:

    def __init__(self):
        # 从文件中加载UI定义

        # 从 UI 定义中动态 创建一个相应的窗口对象
        # 注意：里面的控件对象也成为窗口对象的属性了
        # 比如 self.ui.button , self.ui.textEdit
        self.ui = QUiLoader().load('main.ui')
        port_list_1 = list(serial.tools.list_ports.comports())
        port_list_2 = []
        if port_list_1:
            for p in range(0, len(port_list_1)):
                port_list_2.append(str(port_list_1[p])[:4])

            self.ui.comboBox.addItems(port_list_2)

        self.ui.pushButton_3.clicked.connect(self.port)
        self.ui.pushButton.clicked.connect(self.port_open_recv)
        self.ui.pushButton_2.clicked.connect(self.fenxi)




##读取串口列表
    def port(self):
        if(ckopen==0):
            self.ui.comboBox.clear()
            port_list_1 = list(serial.tools.list_ports.comports())
            port_list_2 = []
            if port_list_1:
                for p in range(0, len(port_list_1)):
                    port_list_2.append(str(port_list_1[p])[:4])

                self.ui.comboBox.addItems(port_list_2)

            return 0


        else:
            QMessageBox.critical(
                self.ui,
                '串口已被打开',
                '请关闭串口后再试！')





    def port_open_recv(self):#对串口的参数进行配置
        global ckopen
        global ser


        if(ckopen==0):
            ser.port=self.ui.comboBox.currentText()
            ser.baudrate=9600
            ser.bytesize=8
            ser.stopbits=1
            ser.parity="N"#奇偶校验位
            ser.open()
            if(ser.isOpen()):
                QMessageBox.information(
                    self.ui,
                    '串口打开成功',
                    '请继续下一步操作！')
                ckopen=1
                self.ui.comboBox.setEnabled(0)
                self.ui.pushButton.setText("关闭串口")
                thread1 = Thread(target=self.rx)
                thread1.start()



            else:
                QMessageBox.information(
                    self.ui,
                    '串口打开失败',
                    '请重试！')
        else:
            ser.close()

            if (ser.isOpen()):
                QMessageBox.information(
                    self.ui,
                    '串口关闭失败',
                    '请重试！')
                self.ui.comboBox.setEnabled(0)
                self.ui.pushButton.setText("关闭串口")
            else:


                self.ui.comboBox.setEnabled(1)
                self.ui.pushButton.setText("打开串口")
                ckopen=0

    def fenxi(self):

        if(ckopen==1):
            ser.write(chr(0x01).encode("utf-8"))
            QMessageBox.information(
                self.ui,
                '成功',
                '分析成功！')
        else:
            QMessageBox.critical(
                self.ui,
                '串口未打开',
                '请先打开串口再分析！')

    def rx(self):
        global ser
        while(1):
            if ser.in_waiting:

                data = str(ser.read_all().hex())
                av=data[0:2]
                av=int(av,16)*3.921
                av=round(av,3)

                atime=data[2:10]
                atime = int(atime, 16)/1000000
                atime=round(atime,3)


                at=data[10:12]
                at=int(at, 16)* 3.921
                at = round(at, 3)

                bv=data[12:14]

                bv=int(bv,16)*3.921
                bv=round(bv,3)

                btime=data[14:22]
                btime = int(btime, 16)/1000000
                btime=round(btime,3)

                bt=data[22:24]
                bt=int(bt, 16)* 3.921
                bt = round(bt, 3)

                x=data[24:32]
                x= int(x, 16)*atime/12
                if(x>1):
                    x=2-x

                x=round(x,3)

                self.ui.label_3.setText(str(av)+"mv")
                self.ui.label_5.setText(str(atime) + "mHZ")
                self.ui.label_7.setText(str(at) + "mv")

                self.ui.label_9.setText(str(bv)+"mv")
                self.ui.label_11.setText(str(btime) + "mHZ")
                self.ui.label_13.setText(str(bt ) + "mv")



                self.ui.label_15.setText(str(x)+"π")


            if(ckopen==0):
                break










app = QApplication([])
stats = Stats()
stats.ui.show()
app.exec_()