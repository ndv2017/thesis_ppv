"""
Author: Viet Nguyen Duc
Send and receive CAN frames using a Raspberry Pi 3B and a Waveshare RS485 CAN HAT.
"""

import os
import can
import time

# Configuration Parameters
CAN_INTERFACE = 'can0'  
BITRATE = 250000        #kbps
REMOTE_ID = 0x103
DATA_ID = 0x104
DATA_PAYLOAD = [0, 1, 0, 3, 4, 5, 8, 7]
NUM_MESSAGES = 6
TX_QUEUE_LEN = 2000
WAIT_TIMEOUT = 5
NUM_RESPONSES = 5

def configure_can_interface(interface, bitrate, txqueuelen):
    """
    Configures the CAN interface.
    """
    os.system(f'sudo ip link set {interface} type can bitrate {bitrate}')
    os.system(f'sudo ifconfig {interface} up')
    os.system(f'sudo ifconfig {interface} txqueuelen {txqueuelen}')
    print(f"CAN interface {interface} configured with bitrate {bitrate}")

def teardown_can_interface(interface):
    """
    Brings down the CAN interface.
    """
    os.system(f'sudo ifconfig {interface} down')
    print(f"CAN interface {interface} brought down")

def create_remote_message(arbitration_id):
    """
    Creates a remote frame with the specified arbitration ID.
    """
    return can.Message(arbitration_id=arbitration_id, is_extended_id=False, is_remote_frame=True)

def create_data_message(arbitration_id, data_payload):
    """
    Creates a data frame with the specified arbitration ID and data payload.
    """
    return can.Message(arbitration_id=arbitration_id, dlc=3, data=data_payload, is_extended_id=False)

def user_send_can_messages(bus, message):
    """
    Interactively sends CAN messages with data specified by the user.
    Continues until the user types 'q' to quit.
    """
    print("Enter the data for byte[2] (type 'q' to quit):")
    while True:
        user_input = input("Data for byte[2]: ")
        if user_input.lower() == 'q':  # Check if user wants to quit
            print("Turn off DC motor...")
            message.data[2] = 0
            bus.send(message)   # Send the message to stop DC motor
            print("Exiting message sending.")
            break
        try:
            byte_value = int(user_input)
            if 0 <= byte_value <= 100:
                message.data[2] = byte_value
                try:
                    bus.send(message)
                    print(f"Message sent: {message}")
                except can.CanError as e:
                    print(f"Failed to send message: {e}")
            else:
                print("Invalid input! Please enter a value between 0 and 100.")
        except ValueError:
            print("Invalid input! Please enter a numeric value or 'q' to quit.")

def wait_for_response(bus, timeout):
    """
    Waits for a specific response message on the CAN bus within a timeout.
    """
    for i in range(NUM_RESPONSES):
        response = bus.recv(timeout=timeout)
        if not response:
            raise Exception(f'Response {i+1} from stm32: Timeout occurred, no response received.')
        else:
            print(f'Response {i+1} from stm32: {hex(response.arbitration_id)}')
            if REMOTE_ID == response.arbitration_id:
                print('stm32 is ready and waiting for data frame...')
                break
            if NUM_RESPONSES - 1 <= i:
                raise Exception('Timeout occurred, no response with specific ID received.')

def main():
    try:
        # Configure CAN interface
        configure_can_interface(CAN_INTERFACE, BITRATE, TX_QUEUE_LEN)

        # Initialize CAN bus
        can_bus = can.interface.Bus(channel=CAN_INTERFACE, bustype='socketcan')

        # Send a remote frame to request data
        try:
            remote_frame = create_remote_message(REMOTE_ID)
            can_bus.send(remote_frame)
        except can.CanError as e:
            print(f"Failed to send remote frame: {e}")
        
        # Wait for the response
        wait_for_response(can_bus, WAIT_TIMEOUT)
        
        # Send a data frame after receiving the response
        data_frame = create_data_message(DATA_ID, DATA_PAYLOAD)
        user_send_can_messages(can_bus, data_frame)

    finally:
        # Clean up the CAN interface
        teardown_can_interface(CAN_INTERFACE)

if __name__ == "__main__":
    main()

