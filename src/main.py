import PySide6 as ps
from PySide6.QtCore import Qt
import sys
class MainWindow(ps.QMainWindow):   # main window class, inherits from QMainWindow
    def __init__(self, parent=None):             # main window innit, needs to be inside a class that inherits from QMainWindow

        # pyrefly: ignore [invalid-super-call]
        super().__init__(parent)


        #window areas
        ps.setCorner(Qt.TopLeftCorner, Qt.LeftDockWidgetArea)
        ps.setCorner(Qt.BottomLeftCorner, Qt.LeftDockWidgetArea)
        ps.setCorner(Qt.TopRightCorner, Qt.RightDockWidgetArea)
        ps.setCorner(Qt.BottomRightCorner, Qt.RightDockWidgetArea)



        #window actions!!!
        newAct = ps.QAction(ps.QIcon.fromTheme("document-new"), "&New", self)   #icon
        newAct.setShortcuts(ps.QKeySequence.New)    #shortcut
        newAct.setStatusTip("Create a new file")    #label
        newAct.triggered.connect(self.newFile)      #what happens. self.newFile is a function that will be called when the action is triggered
                                                    #its a method of the class that this code is in. It will be defined later in the class.
        
        fileMenu = self.menuBar().addMenu("&File")
        fileMenu.addAction(newAct)
        fileMenu.addAction(self.openAct)

        fileMenu.addSeparator()

        #main widget, QTextEdit.
        centralWidget = ps.QWidget()
        textEdit = ps.QTextEdit()
        layout = ps.QVBoxLayout()
        layout.addWidget(textEdit)
        centralWidget.setLayout(layout)

        self.setCentralWidget(centralWidget)



def main():


    app = ps.QApplication(sys.argv)   # create a QApplication object, which is needed to run the application
    window = MainWindow()   # create an instance of the MainWindow class
    window.show()   # show the main window
    app.exec()   # start the event loop, which waits for user input and updates the GUI accordingly





    print("blablabla")
    

if __name__ == "__main__":
    main()
