from PySide6.QtWidgets import QMainWindow, QVBoxLayout, QWidget, QApplication, QMessageBox
from PySide6.QtCore import Qt, QFile
from PySide6.QtUiTools import QUiLoader
import sys







def main():
    app = QApplication(sys.argv)

    loader = QUiLoader()
    path = "ui/window.ui"
    ui_file = QFile(path)
    ui_file.open(QFile.ReadOnly)
    window = loader.load(ui_file)
    ui_file.close()
    window.pushButton.clicked.connect(lambda: QMessageBox.information(window, "Info", "Button clicked!"))
    window.show()
    sys.exit(app.exec())



if __name__ == "__main__":
    main()