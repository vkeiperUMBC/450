import sys
import random
from PyQt5.QtWidgets import *
from PyQt5.QtCore import QEvent, Qt, QTimer
from PyQt5.QtGui import QIcon, QPalette, QColor
import serial
import serial.tools.list_ports

# Initial declaration of serial class
ser = serial.Serial()

class UARTGUI(QWidget):
    new_bit = 0

    def __init__(self):
        super().__init__()
        self.setup_ui()
        self.serial_port = None
        self.timer = QTimer(self)  # Timer for generating bitstream
        self.timer.timeout.connect(self.generate_random_bitstream)
        self.receive_timer = QTimer(self)  # Timer for listening to incoming data
        self.receive_timer.timeout.connect(self.listen_for_data)  # Connect to the listening function
        self.file_cursor = 0  # Initialize the cursor position
        self.file_path = "encoded_input.txt"  # File path to read from
        self.bit_buffer = ""  # Buffer to store received bits

        # Set the initial size of the window to maintain a 4:3 aspect ratio
        screenSize = QApplication.primaryScreen().size()
        screenWidth = screenSize.width()
        screenHeight = screenSize.height()
        self.setGeometry(int((screenWidth / 2) - 200), int((screenHeight / 2) - 200), int(400), int(300))  # x, y, width, height (4:3 aspect ratio)

    def setup_ui(self):
        self.setWindowTitle('CCED GUI')

        # Main layout
        main_layout = QVBoxLayout(self)

        # Top section layouts
        top_layout = QHBoxLayout()

        # Left and right sections within top layout
        left_section_layout = QVBoxLayout()
        right_section_layout = QVBoxLayout()

        # Nested layouts within the left section
        port_settings_layout = QHBoxLayout()
        baud_settings_layout = QHBoxLayout()
        left_section_layout.addLayout(port_settings_layout)
        left_section_layout.addLayout(baud_settings_layout)

        # Nested layouts within the right section
        control_buttons_layout = QVBoxLayout()
        right_section_layout.addLayout(control_buttons_layout)

        # Adding left and right sections to the top layout
        top_layout.addLayout(left_section_layout)
        top_layout.addLayout(right_section_layout)

        # Other sections for the UI
        input_section_layout = QVBoxLayout()
        received_section_layout = QVBoxLayout()
        encoded_section_layout = QVBoxLayout()
        decoded_section_layout = QVBoxLayout()

        # Adding layouts to the main layout
        main_layout.addLayout(top_layout)
        main_layout.addLayout(input_section_layout)
        main_layout.addLayout(received_section_layout)
        main_layout.addLayout(encoded_section_layout)
        main_layout.addLayout(decoded_section_layout)

        # Dropdown for serial port selection
        self.port_combobox = QComboBox()
        self.port_combobox.setEditable(False)
        self.port_combobox.installEventFilter(self)
        port_settings_layout.addWidget(self.port_combobox)

        # Button to connect/disconnect UART
        self.connect_button = QPushButton("Connect")
        self.connect_button.clicked.connect(self.connect_uart)
        port_settings_layout.addWidget(self.connect_button)

        # Baud rate label and input field
        baud_label = QLabel("Baud Rate:")
        baud_settings_layout.addWidget(baud_label)

        self.baud_input = QLineEdit()
        self.baud_input.setPlaceholderText("Enter Baud Rate")
        baud_settings_layout.addWidget(self.baud_input)

        # Start and stop buttons for bitstream generation
        self.clear_button = QPushButton('Clear')
        self.clear_button.clicked.connect(self.clear_text)
        baud_settings_layout.addWidget(self.clear_button)
                
        # Start and stop buttons for bitstream generation
        self.start_button = QPushButton('Start')
        self.start_button.clicked.connect(self.start_bitstream_generation)
        control_buttons_layout.addWidget(self.start_button)
        
        self.stop_button = QPushButton('Stop')
        self.stop_button.clicked.connect(self.stop_bitstream_generation)
        control_buttons_layout.addWidget(self.stop_button)

        # Input bits section
        input_label = QLabel("Input Bits:")
        input_section_layout.addWidget(input_label)
        
        self.input_text_area = QPlainTextEdit()
        self.input_text_area.setReadOnly(True)
        self.input_text_area.setStyleSheet("background-color: black; color: white;")
        input_section_layout.addWidget(self.input_text_area)

        # Input bits section
        received_label = QLabel("Received:")
        received_section_layout.addWidget(received_label)
        
        self.received_text_area = QPlainTextEdit()
        self.received_text_area.setReadOnly(True)
        self.received_text_area.setStyleSheet("background-color: black; color: white;")
        received_section_layout.addWidget(self.received_text_area)

        # Encoded bits section
        encoded_label = QLabel("Encoded Bits:")
        encoded_section_layout.addWidget(encoded_label)
        
        self.encoded_text_area = QPlainTextEdit()
        self.encoded_text_area.setReadOnly(True)
        self.encoded_text_area.setStyleSheet("background-color: black; color: white;")
        encoded_section_layout.addWidget(self.encoded_text_area)

        # Decoded bits section
        decoded_label = QLabel("Decoded Bits:")
        decoded_section_layout.addWidget(decoded_label)
        
        self.decoded_text_area = QTextEdit()
        self.decoded_text_area.setReadOnly(True)
        self.decoded_text_area.setStyleSheet("background-color: black; color: white;")
        decoded_section_layout.addWidget(self.decoded_text_area)

        self.setLayout(main_layout)

    def start_bitstream_generation(self):
        if ser.is_open:
            self.timer.start(200)  # Start timer with interval of 500 ms
        else:
            QMessageBox.warning(self, "Warning", "Serial port is not connected. Please connect to a port first.")
            
    def stop_bitstream_generation(self):
        self.timer.stop()  # Stop the timer

    def generate_random_bitstream(self):
        new_bit = random.choice('01')  # Generate a single random bit
        ser.write(new_bit.encode())  # Send the bit over UART
        bitstream = ''.join(new_bit)  # Generate a single random bit
        current_text_input = self.input_text_area.toPlainText()
        self.input_text_area.setPlainText(current_text_input + bitstream)  # Append new bitstream to the input area

        # # Simulate decoding with possible error
        # decoded_bit = bitstream
        # if random.randrange(0, 99) > 90:  # Introduce an error with 10% probability
        #     decoded_bit = '0' if bitstream == '1' else '1'

        # # Update decoded text with highlighting
        # cursor = self.decoded_text_area.textCursor()
        # cursor.movePosition(cursor.End)  # Move cursor to the end of text
        # if decoded_bit != bitstream:
        #     cursor.insertHtml(f'<span style="color:red;">{decoded_bit}</span>')  # Highlight mismatch in red
        # else:
        #     cursor.insertHtml(f'<span style="color:white;">{decoded_bit}</span>')  # Append matching bit in white
        # self.decoded_text_area.setTextCursor(cursor)  # Set updated cursor back
        # self.decoded_text_area.ensureCursorVisible()  # Keep cursor visible


    def clear_text(self):
        self.input_text_area.clear()
        self.received_text_area.clear()
        self.encoded_text_area.clear()
        self.decoded_text_area.clear()



    def is_integer(self, text):
        try:
            int(text)
            return True
        except ValueError:
            return False

    def connect_uart(self):
        if not ser.is_open:
            ports = list(serial.tools.list_ports.comports())
            for port in ports:
                self.log_message(f"Port: {port.device}, Description: {port.description}, Baud: {self.baud_input.text()}")
            if self.port_combobox.currentText():
                port_name = self.port_combobox.currentText()
            else:
                self.log_message("No COM Port Selected")
                return

            if self.is_integer(self.baud_input.text()):
                ser.baudrate = int(self.baud_input.text())  # Convert to integer
            else:
                self.log_message("Invalid Baud rate")
                return

            ser.port = port_name
            ser.open()
            if ser.is_open:
                self.log_message("Serial Port Opened")
                self.connect_button.setText("Disconnect")
                self.receive_timer.start(100)  # Start listening for data every 100ms
            else:
                self.log_message("Failed to open Serial Port")
        else:
            ser.close()
            self.connect_button.setText("Connect")
            self.log_message("Disconnected from port")
            self.receive_timer.stop()  # Stop listening for data

    def print_uart_message(self, bits):
        """Print the received UART message bits to the console."""
        print(f"UART Message Received: {bits}")

    def listen_for_data(self):
        """Listen for incoming data from the serial port."""
        if ser.is_open and ser.in_waiting > 0:  # Check if data is available
            try:
                data = ser.read(ser.in_waiting)  # Read available data as raw bytes
                # Convert bytes to bits
                new_bits = ''.join(format(byte, '08b') for byte in data)
                if len(new_bits) >= 4:
                    if len(new_bits) >= 8:
                        print(f"Full 8-bit UART Transmission: {new_bits[:8]}")
                    else:
                        print(f"UART Transmission (less than 8 bits): {new_bits}")
                    chunk = new_bits[-4:]  # Take only last 4 bits
                    self.print_uart_message(chunk)  # Print to console (last 4 bits)
                    self.update_ui_with_bits(chunk)
            except Exception as e:
                self.log_message(f"Error reading data: {str(e)}")

    def update_ui_with_bits(self, chunk):
        """Update the UI with the received bits in a cycle of 4."""
        if len(chunk) == 4:
            # 1st bit to the "Received" section
            current_received = self.received_text_area.toPlainText()
            self.received_text_area.setPlainText(current_received + chunk[3])

            # Next 2 bits to the "Encoded" section
            current_encoded = self.encoded_text_area.toPlainText()
            self.encoded_text_area.setPlainText(current_encoded + chunk[1] + chunk[2])

            # Last bit to the "Decoded" section
            current_decoded = self.decoded_text_area.toPlainText()
            self.decoded_text_area.setPlainText(current_decoded + chunk[0])

    def eventFilter(self, source, event):
        if event.type() == QEvent.MouseButtonPress and source == self.port_combobox:
            self.refresh_ports()
        return super().eventFilter(source, event)

    def log_message(self, message):
        print(message)  # Replace with appropriate logging or UI handling
    # Gets all of the ports and clears the previous ports in the dropdown then sets them to the retrieved ports

    def refresh_ports(self):
        ports = serial.tools.list_ports.comports()
        available_ports = [port.device for port in ports]
        self.port_combobox.clear()
        for port in available_ports:
            self.port_combobox.addItem(port)

if __name__ == '__main__':
    app = QApplication(sys.argv)


    app.setStyle('Fusion')
    darkPalette = QPalette()
    darkPalette.setColor(QPalette.Window, QColor(53, 53, 53))
    darkPalette.setColor(QPalette.WindowText, Qt.white)
    darkPalette.setColor(QPalette.Disabled, QPalette.WindowText, QColor(127, 127, 127))
    darkPalette.setColor(QPalette.Base, QColor(42, 42, 42))
    darkPalette.setColor(QPalette.AlternateBase, QColor(66, 66, 66))
    darkPalette.setColor(QPalette.ToolTipBase, Qt.white)
    darkPalette.setColor(QPalette.ToolTipText, Qt.white)
    darkPalette.setColor(QPalette.Text, Qt.white)
    darkPalette.setColor(QPalette.Disabled, QPalette.Text, QColor(127, 127, 127))
    darkPalette.setColor(QPalette.Dark, QColor(35, 35, 35))
    darkPalette.setColor(QPalette.Shadow, QColor(20, 20, 20))
    darkPalette.setColor(QPalette.Button, QColor(53, 53, 53))
    darkPalette.setColor(QPalette.ButtonText, Qt.white)
    darkPalette.setColor(QPalette.Disabled, QPalette.ButtonText, QColor(127, 127, 127))
    darkPalette.setColor(QPalette.BrightText, Qt.red)
    darkPalette.setColor(QPalette.Link, QColor(42, 130, 218))
    darkPalette.setColor(QPalette.Highlight, QColor(42, 130, 218))
    darkPalette.setColor(QPalette.Disabled, QPalette.Highlight, QColor(80, 80, 80))
    darkPalette.setColor(QPalette.HighlightedText, Qt.white)
    darkPalette.setColor(QPalette.Disabled, QPalette.HighlightedText, QColor(127, 127, 127))

    app.setPalette(darkPalette)

    ex = UARTGUI()
    ex.show()
    sys.exit(app.exec_())
