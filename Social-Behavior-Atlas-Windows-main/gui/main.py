from tab import MainWindow
from PySide6.QtWidgets import QApplication
from util import configMang

if __name__ == '__main__':
    app = QApplication([])
    configMang.g_windows = MainWindow()
    window = configMang.g_windows
    window.show()
    app.exec()
