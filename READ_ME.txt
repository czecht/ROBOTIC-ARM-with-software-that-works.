?? ROBOTIC ARM
Assembly, Software Setup, and Operating Instructions
These instructions will guide you through assembling your robotic arm, connecting the servos, installing the required software, and controlling the arm using your computer.
Please follow the steps in order to ensure everything works correctly.

PART 1: PREPARING THE ROBOTIC ARM
Step 1: Print and Prepare the Base
1. 3D-print the base of the robotic arm.
2. Install the Arduino UNO and the Servo Shield onto the base.
3. Connect the power connector to the Servo Shield.
4. Prepare your power adapter and set the output voltage to 7.2V.
IMPORTANT: Before connecting power, verify that your Servo Shield and servos support 7.2V and that the power supply polarity is correct.
Step 2: Connect All 8 Servos
Connect all 8 servo motors to the Servo Shield.
Use the following connections:
Servo NumberServo Shield PinServo 1Pin 0Servo 2Pin 1Servo 3Pin 2Servo 4Pin 3Servo 5Pin 4Servo 6Pin 5Servo 7Pin 6Servo 8Pin 7IMPORTANT: Make sure each servo connector is installed in the correct orientation. Check the signal, positive (+), and ground (–) connections.
Step 3: Prepare the Arduino Software
1. Make sure the Arduino IDE is installed on your computer.
2. Open the Arduino IDE.
3. Click File ? Open.
4. Browse to the folder containing the robotic arm project files.
5. Locate and open the following program:
Robotics_arm_servo_test1
6. Connect your Arduino UNO to the computer using a USB cable.
7. In the Arduino IDE, select the correct Arduino board and COM port.
8. Click the Upload button to upload the program to your Arduino.
Step 4: Center All Servo Motors
After the program has successfully uploaded, all 8 servo motors should move to their 90-degree center positions.
This is an important step because the servos must be centered before assembling the robotic arm.
IMPORTANT:
* Make sure all servos have reached their center positions.
* Do not manually force a servo to turn.
* Keep the servo positions centered while installing the robotic arm components.
Step 5: Prepare for Assembly
1. Disconnect the power before unplugging any servos.
2. Disconnect all servo motors except Servo 1 (Pin 0).
3. Begin assembling the robotic arm according to the assembly instructions.
VERY IMPORTANT:
Keep track of each servo motor and its assigned pin number.
You will need this information when reconnecting the servos after assembly.
TIP: Label each servo cable with its corresponding pin number (0–7). This will make reconnecting everything much easier.
Step 6: Complete the Robotic Arm Assembly
Once the robotic arm is fully assembled:
1. Make sure the power is disconnected.
2. Reconnect each servo motor to its original Servo Shield pin.
3. Double-check that all 8 servos are connected correctly.
4. Verify that no wires are pinched or interfering with the movement of the robotic arm.
Your robotic arm is now ready for software setup!

PART 2: INSTALLING THE REQUIRED SOFTWARE
To operate the robotic arm from your computer, you will need two programs:
1. Arduino IDE
Download and install the Arduino IDE from:
https://www.arduino.cc/en/software/
2. Processing
Download and install Processing from:
https://processing.org/download
Choose the version compatible with your computer. These instructions are written for Windows.
Once both programs are installed, continue with the following steps.

PART 3: LOADING THE ROBOTIC ARM PROGRAMS
Step 1: Open the Arduino Program
1. Start the Arduino IDE.
2. Click File ? Open.
3. Browse to the folder where you extracted (unzipped) the robotic arm project files.
4. Find and open the following program:
Robotics_arm_servo_withProcessor-Arduino
5. Make sure your Arduino UNO is connected to the computer using the USB cable.
6. Select the correct Arduino board and COM port.
7. Click Upload to upload the program to your Arduino.
Wait until the upload is complete before continuing.
Step 2: Open the Processing Program
1. Start Processing.
2. Click File ? Open.
3. Browse to the folder containing the robotic arm project files.
4. Find and open the following program:
RoboticArm_for_Processor
5. If Processing opens an additional empty window, close the empty window.
You should now have two programs open:
* Arduino IDE: Contains the Arduino program.
* Processing: Contains the graphical control program for the robotic arm.
Keep both programs open while setting up the robotic arm.
Step 3: Connect the Robotic Arm
1. Connect the 7.2V power supply to the robotic arm's servo power connector.
2. Connect the Arduino UNO to your computer using the USB cable.
3. Make sure all servo connections are secure.
4. In Processing, click the Run button to start the graphical control interface, if it is not already running.
The graphical control window should now appear.

PART 4: CONNECTING PROCESSING TO THE ARDUINO
Step 1: Check the COM Port Connection
Look at the upper-left corner of the Processing graphical control window.
On approximately the second line, you should see a message similar to:
Connected on COM3
Your COM port number may be different.
For example:
* Connected on COM3
* Connected on COM4
* Connected on COM5
If you see the connected message with the correct COM port, your Arduino and Processing programs are communicating successfully.
NOTE: The COM port number depends on your computer and the USB connection.
Step 2: What to Do if Processing Does Not Connect
If the robotic arm does not connect, you may need to change the COM port number in the Processing program.
Follow these steps:
1. Open the Arduino IDE.
2. Click Tools ? Port.
3. Find the COM port assigned to your Arduino UNO.
For example, your Arduino might be connected to COM4 instead of COM3.
4. Return to Processing.
5. Minimize or move the graphical control window so you can see the Processing code editor.
6. Near the beginning of the program (approximately the third line), locate:
final String PORT_NAME = "COM3";
7. Change COM3 to the COM port assigned to your Arduino.
For example, if your Arduino is connected to COM4, change the line to:
final String PORT_NAME = "COM4";
8. Save the changes.
9. Restart the Processing program if necessary.
10. In the graphical control window, click the blue Connect/Reconnect button located near the upper-right corner.
Now check the upper-left corner of the graphical window again.
You should see:
Connected on COM4
Or whichever COM port your Arduino is using.
IMPORTANT: Make sure the Arduino IDE Serial Monitor is closed, because it can prevent Processing from connecting to the same COM port.

PART 5: CONTROLLING THE ROBOTIC ARM
Once Processing successfully connects to your Arduino, you can begin controlling the robotic arm.
Step 1: Moving the Robotic Arm
In the Processing graphical control window, you will see several slider controls.
Each slider controls the position of a servo motor.
To move the robotic arm:
1. Locate one of the sliders.
2. Click and hold the slider control.
3. Slowly move the slider to the left or right.
4. Watch the robotic arm respond to your movements.
Moving a slider changes the position of its corresponding servo motor.
TIP: Start with small movements until you become familiar with how the robotic arm operates.
CAUTION: Do not force the robotic arm beyond its mechanical limits. If a servo begins to strain or the arm reaches an obstruction, stop moving the slider.

PART 6: RECORDING AND PLAYING BACK MOVEMENTS
The robotic arm control software also includes a Record and Playback feature.
This allows you to save up to 5 different robotic arm positions and play them back automatically.
Step 1: Recording Positions
1. Use the sliders to move the robotic arm to your desired position.
2. Locate the RECORD buttons on the right side of the graphical control window.
3. Press the appropriate RECORD button to save the current arm position.
4. Move the robotic arm to another position.
5. Record the next position.
6. Continue until you have recorded up to 5 different positions.
You can use this feature to create a simple sequence of robotic arm movements.
Step 2: Playing Back Recorded Positions
Once you have recorded your positions:
1. Locate the PLAY 1–5 button.
2. Click the button to start playback.
3. Watch as the robotic arm automatically moves through the 5 recorded positions.
The robotic arm will reproduce the positions you previously saved.
This feature is especially useful for demonstrating automated robotic movements.
TIP: Before starting playback, make sure the robotic arm has enough clearance to move safely through all recorded positions.

PART 7: QUICK TROUBLESHOOTING GUIDE
Problem: The Servos Do Not Move
Check the following:
* Is the 7.2V servo power supply connected and turned on?
* Is the Arduino connected to the computer?
* Are all servo connectors installed correctly?
* Has the Arduino program been uploaded successfully?
* Is Processing connected to the correct COM port?
Problem: Processing Cannot Connect to the Arduino
Try these steps:
1. Check the Arduino COM port in the Arduino IDE.
2. Make sure the COM port number in the Processing program matches.
3. Close the Arduino Serial Monitor.
4. Click Connect/Reconnect in Processing.
5. If necessary, disconnect and reconnect the USB cable.
Problem: A Servo Moves in the Wrong Direction or Does Not Respond
Check the following:
* Is the servo connected to the correct pin (0–7)?
* Is the servo connector installed in the correct orientation?
* Is the servo cable damaged or disconnected?
* Is the servo movement being blocked by a mechanical part?
Problem: The Robotic Arm Does Not Move Smoothly
* Make sure the power supply provides sufficient current for all servos.
* Check that the mechanical joints move freely.
* Verify that no wires are restricting movement.
* Avoid moving several heavily loaded servos too quickly.

?? CONGRATULATIONS!
Your robotic arm should now be fully assembled, connected, and ready to operate!
You can now:
* Control the robotic arm using the Processing sliders.
* Move individual servo motors.
* Record up to 5 different arm positions.
* Play back your recorded movements automatically.
* Experiment with different robotic arm movements and sequences.
Enjoy building, programming, and experimenting with your Robotic Arm!
Happy Robotics! ??

