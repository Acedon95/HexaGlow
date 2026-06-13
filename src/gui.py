import sys
import socket
from typing import Literal, get_args
from PyQt6.QtWidgets import QApplication, QWidget, QPushButton, QColorDialog, QVBoxLayout, QLabel
from PyQt6.QtGui import QColor


# --- Configure your ESP32 here ---
ESP32_IP = "192.168.1.123"   # replace with your ESP32's IP
ESP32_PORT = 4210            # replace with your ESP32's listening port


# Commands

commands = Literal[        
        "POSITION",
        "COLORALL",
        "COLORHEX",
        "COLORPIXEL",
        "COLOREDGE",
        "BRIGHTNESS",
        "CLEAR",
        "SETHEXCOUNT",
        "NONE"
]


class ColorSender(QWidget):
    def __init__(self):
        super().__init__()

        self._r: int = 0
        self._g: int = 0
        self._b: int = 0
        self.commands = get_args(commands)

        self._current_command: str = "NONE"

        # Setup UDP socket
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

        # Setup UI
        layout = QVBoxLayout()

        self.label = QLabel("Selected color: None", self)
        self.picker_button = QPushButton("Pick a Color", self)
        self.picker_button.clicked.connect(self.open_color_dialog)

        layout.addWidget(self.label)
        layout.addWidget(self.picker_button)

        self.setWindowTitle("LED Color Controller")
        self.resize(300, 150)

        self.command_buttons = {}
        for cmd in self.commands:
            btn = QPushButton(cmd, self)
            btn.clicked.connect(lambda checked, c=cmd: self.set_current_command(c))
            self.command_buttons[cmd] = btn
            layout.addWidget(btn)

        self.send_button = QPushButton("Send Command", self)
        self.send_button.clicked.connect(lambda: self.send_command(self._current_command))


        self.setLayout(layout)

    def open_color_dialog(self):
        color = QColorDialog.getColor()

        if color.isValid():
            r, g, b, _ = color.getRgb()
            self.label.setText(f"Selected color: R={r}, G={g}, B={b}")
            self._r, self._g, self._b = r, g, b
            # Send over UDP
           #self._r, self._g, self._b = r, g, b
           #msg = f"{self._r},{self._g},{self._b}".encode("utf-8")
           #self.sock.sendto(msg, (ESP32_IP, ESP32_PORT))
           #print(f"Sent: {msg}")

    def send_command(self):
        msg = self._current_command.encode("utf-8")
        self.sock.sendto(msg, (ESP32_IP, ESP32_PORT))
        print(f"Sent command: {msg}")

    def build_command(self):
        if self._current_command == "COLORHEX":
            return f"COLORHEX {self._r},{self._g},{self._b}"
        elif self._current_command == "COLORALL":
            return f"COLORALL {self._r},{self._g},{self._b}"
        elif self._current_command == "BRIGHTNESS":
            brightness = int((self._r + self._g + self._b) / 3)
            return f"BRIGHTNESS {brightness}"
        elif self._current_command == "CLEAR":
            return "CLEAR"
        # Add more command constructions as needed
        return "NONE"


if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = ColorSender()
    window.show()
    sys.exit(app.exec())
