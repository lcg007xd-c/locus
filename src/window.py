from PySide6.QtWidgets import QMainWindow, QVBoxLayout, QHBoxLayout, QWidget, QPushButton, QLabel, QApplication, QLabel, QLineEdit
from PySide6.QtCore import Qt
import sys
from time import sleep 
from random import randint
import re


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
        bottom = QVBoxLayout(bottomContainer)

        layout.addWidget(topContainer)
        layout.addWidget(middleConatiner)
        layout.addWidget(bottomContainer)

        self.label1 = QLabel("[Your function]")
        self.label1.setAlignment(Qt.AlignCenter)
        top.addWidget(self.label1)


        labelm = QLabel("f(x) =")
        middle.addWidget(labelm)

        self.input = QLineEdit()
        self.input.returnPressed.connect(self.validate_expression)
        middle.addWidget(self.input)

        button = QPushButton("Submit")
        bottom.addWidget(button, alignment=Qt.AlignCenter)
        button.setFixedWidth(100)


        button1 = QPushButton("Submit")
        bottom.addWidget(button1, alignment=Qt.AlignCenter)
        button1.setFixedWidth(100)
        button1.clicked.connect(lambda: print(self.expression))

        
        button.clicked.connect(self.validate_expression)

        self.expression = ""
        
    def validate_expression(self):

        expression = self.input.text().strip()
        self.label1.setStyleSheet("color: white")

        if not expression:
            self.label1.setStyleSheet("color: red")
            self.label1.setText("Enter your function")
            return

        allowed_names = {
            "x",
            "e",
            "pi",
            "sin",
            "cos",
            "tan",
            "sqrt",
            "log",
            "ln",
            "abs",
        }

        errors = []

        # Find all names made from letters
        names = re.findall(r"[A-Za-z]+", expression)

        for name in names:
            if name not in allowed_names:
                errors.append(name)

        # Remove valid names, then validate the remaining symbols
        expression_without_names = re.sub(r"[A-Za-z]+", "", expression)

        allowed_characters = set("0123456789+-*/^(). ")

        for character in expression_without_names:
            if character not in allowed_characters:
                errors.append(character)

        if errors:
            self.label1.setStyleSheet("color: red")
            self.label1.setText(
                f"Error\n{errors} not valid"
            )
            return

        self.expression = expression
        self.label1.setText(self.expression)
        


def main():

    app = QApplication(sys.argv)

    #windoiw as class main window, will run innit method by definition, class QMainWindow has .show method by definition i think
    window = MainWindow()
    window.show()

    print("a")
    print(window.x)
    print("b")

    sys.exit(app.exec())
   
  
if __name__ == "__main__":
    main()