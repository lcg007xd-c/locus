from PySide6.QtWidgets import QMainWindow, QVBoxLayout, QHBoxLayout, QWidget, QPushButton, QLabel, QApplication, QLabel, QLineEdit
from PySide6.QtCore import Qt
import sys
from time import sleep 





class MainWindow(QMainWindow):
    
    def __init__(self):

        super().__init__()

        self.setWindowTitle("Window thingy")
        self.resize(500,300)

        whole = QWidget()
        self.setCentralWidget(whole)

        layout = QVBoxLayout(whole)

        topContainer = QWidget()
        middleConatiner = QWidget()
        bottomContainer = QWidget()
     
        top = QHBoxLayout(topContainer)
        middle = QHBoxLayout(middleConatiner)
        bottom = QHBoxLayout(bottomContainer)
       
        layout.addWidget(topContainer)
        layout.addWidget(middleConatiner)
        layout.addWidget(bottomContainer)

        label1 = QLabel("This says somehtingg")
        label1.setAlignment(Qt.AlignCenter)
        top.addWidget(label1)


        labelm = QLabel("Input function: ")
        middle.addWidget(labelm)
        input = QLineEdit()
        middle.addWidget(input)

        button = QPushButton("Submit")
        function = button.clickedk.connect()
        
        bottom.addWidget(button)

    def recity(self, func):
        ...

        


def main():

    app = QApplication(sys.argv)

    #windoiw as class main window, will run innit method by definition, class QMainWindow has .show method by definition i think
    window = MainWindow()
    window.show()


    
    sys.exit(app.exec())
    print("blablabla")
    

if __name__ == "__main__":
    main()