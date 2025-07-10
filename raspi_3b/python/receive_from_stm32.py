"""
Author: Viet Nguyen Duc
Send and receive CAN frames using a Raspberry Pi 3B and a Waveshare RS485 CAN HAT.
"""

import os
import can
import time
import struct

# Configuration Parameters
CAN_INTERFACE = 'can0'  
BITRATE = 250000        #kbps
CHECK_SENSORS_ID = 0x100
CHECK_SENSORS_RESPOND_ID = 0x001
REQUEST_DATA_SENSORS_ID = 0x200
RPM_ENCODER_ID = 0x101
CUR_SENSOR_ID  = 0x102
TEMP_SENSOR_ID = 0x103
TORQ_SENSOR_ID = 0x104
# DATA_PAYLOAD = [0, 1, 0, 3, 4, 5, 8, 7]
NUM_MESSAGES = 1
SEND_INTERVAL = 1    #ms
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

def send_can_messages(bus, message, num_messages, interval):
    """
    Sends a specified number of CAN messages with a delay between each.
    """
    for i in range(num_messages):
        try:
            bus.send(message)
            print(f"Message {i+1}/{num_messages} sent: {message}")
            message.data[2] = message.data[2] + 2
            time.sleep(interval)
        except can.CanError as e:
            print(f"Failed to send message {i+1}: {e}")

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
            if CHECK_SENSORS_RESPOND_ID == response.arbitration_id:
                print('stm32 is ready and waiting for data frame...')
                break
            if NUM_RESPONSES - 1 <= i:
                raise Exception('Timeout occurred, no response with specific ID received.')

def bytes_to_float(data):
    """Convert 4 bytes (little-endian) to float."""
    return struct.unpack('<f', bytes(data))[0]

def receive_motor_data_realtime(bus):
    """
    Receives motor's parameters over CAN
    """
    rpm = 0.0
    current = 0.0
    temperature = 0.0
    torque = 0.0
    output_file = './tmp/motor_data.txt'

    os.makedirs(os.path.dirname(output_file), exist_ok=True)

    print("Start receiving and updating motor data in real-time... Press Ctrl+C to stop.")

    try:
        while True:
            msg = bus.recv(timeout=1.5)
            if msg is None or len(msg.data) < 4:
                continue

            if msg.arbitration_id == RPM_ENCODER_ID:
                rpm = bytes_to_float(msg.data[:4])
            elif msg.arbitration_id == CUR_SENSOR_ID:
                current = bytes_to_float(msg.data[:4])
            elif msg.arbitration_id == TEMP_SENSOR_ID:
                temperature = bytes_to_float(msg.data[:4])
            elif msg.arbitration_id == TORQ_SENSOR_ID:
                torque = bytes_to_float(msg.data[:4])
            else:
                continue

            with open(output_file, 'w') as f:
                f.write(f"{rpm:.3f},{current:.3f},{temperature:.3f},{torque:.3f}\n")

            print(f"Updated motor data: RPM={rpm:.3f}, Current={current:.3f}, Temp={temperature:.3f}, Torque={torque:.3f}")

    except KeyboardInterrupt:
        print("\nUser interruption detected. Stopping motor data reception.")
        raise  # Re-raise to trigger the `finally` block in `main()`

def main():
    can_bus = None
    try:
        configure_can_interface(CAN_INTERFACE, BITRATE, TX_QUEUE_LEN)
        can_bus = can.interface.Bus(channel=CAN_INTERFACE, bustype='socketcan')

        # Initial handshake
        check_frame = create_remote_message(CHECK_SENSORS_ID)
        can_bus.send(check_frame)
        wait_for_response(can_bus, WAIT_TIMEOUT)

        # Request data from STM32
        request_frame = create_remote_message(REQUEST_DATA_SENSORS_ID)
        can_bus.send(request_frame)

        # Start receiving loop
        receive_motor_data_realtime(can_bus)

    except can.CanError as e:
        print(f"CAN communication error: {e}")

    finally:
        if can_bus:
            # Send stop frame
            try:
                stop_data = [1, 0, 0] + [0]*5
                stop_msg = create_data_message(REQUEST_DATA_SENSORS_ID, stop_data)
                can_bus.send(stop_msg)
                print("Sent stop message to STM32.")
            except can.CanError as e:
                print(f"Failed to send stop message: {e}")

        # Clear motor_data.txt
        output_file = './tmp/motor_data.txt'
        try:
            open(output_file, 'w').close()
            print("Cleared motor_data.txt.")
        except Exception as e:
            print(f"Failed to clear motor_data.txt: {e}")

        teardown_can_interface(CAN_INTERFACE)

if __name__ == "__main__":
    main()
