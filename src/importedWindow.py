from PySide6.QtWidgets import QMainWindow, QVBoxLayout, QWidget, QApplication, QMessageBox, QLabel
from PySide6.QtCore import Qt, QFile
from PySide6.QtUiTools import QUiLoader
import sys


def func():
    print('a')



def main():

    app = QApplication(sys.argv)
    loader = QUiLoader()
    
    ui_file = QFile("ui/main.ui")
    ui_file.open(QFile.ReadOnly)

    mw = loader.load(ui_file)
    ui_file.close()

    
    mw.pushButton.clicked.connect(func())


    mw.show()
    sys.exit(app.exec())



if __name__ == "__main__":
    main()