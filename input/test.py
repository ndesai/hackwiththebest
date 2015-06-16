#! /usr/bin/python

import serial, sys
import paho.mqtt.client as mqtt
import json

# Each test bench is labeled with the serial device name on the USB cable
device_name = '/dev/cu.usbserial-FTF0F8FI'
baud_rate   = 115200

# Set up the serial port connection
ser = serial.Serial(device_name, baud_rate)
ser.flushInput()
ser.flushOutput()

mqttc = mqtt.Client("hack")
mqttc.connect("localhost", 1883)

while True:
    raw_data = ser.readline()

    # Parse the raw message from the serial port into a 'command' string and 'params' dictionary
    parts = raw_data.split()
    command = parts[0]
    params = dict((k, int(v)) for k, v in (p.split(':') for p in parts[1:]))

    # Print for debugging
    print command, params

    # Process the command
    if command == 'swipeUp' and params['touches'] == 2:
        print 'I detected a two finger SWIPE UP on the touchpad!'

    # Force the system to flush the data buffer and write the output immediately
    sys.stdout.flush()

    #mqttc.publish("hack", command + "|" + json.dumps(params))
    mqttc.publish("hack", "Test")


