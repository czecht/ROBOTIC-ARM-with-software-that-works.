A) Print the base of the Robotic Arm so you can install the Arduino UNO and the Servo Shield with the power connector and the power adapter set to 7.2V.
B) Next you need to connect all 8 servos (Start at pin #0,1,2,3,4,5,6,7.
C) Make sure your Arduino IDE is installed
D) Click on FILE and OPEN and open file called: Robotics_arm_servo_test1 (It should be in the same place where the other programs are for this project).
E) Upload the Robotics-arm-servo-test1 to the Arduino
F) At the end of the upload, all servos should be set to 90 degrees
G) You should unplug all but the first servos, so you can build the robotic arm.
H) (Keep track what servo is where, because you will need to know at the end of the assembly where to plug the servo).

Once you have the arm assembled, plug in the appropriate servos the rest of the pins.

1) Install Arduino IDE -  https://www.arduino.cc/en/software/
2) Download Processing  -  https://processing.org/download
3) Install Arduino IDE
4) Install Processing for Windows
5) Open Arduino IDE
6) Click on FILE and on OPEN (and browse to where you unzipped the Arduino files) and select the file called: Robotics_arm_servo_withProcessor-Arduino
7) Open Processing and click on FILE and OPEN (and browse to where you unzipped the Arduino files) and select the file called: RoboticArm_for_Processor
8) Close the empty Processing window, so you see only the two windows you have open (Both Arduino IDE and the PROCESSING windows should be open at the same time)
9) Plug in the 7.2V power and also plug in the USB cable to the computer
10) Make sure that in the PROCESSING window, second line on left upper corner, it states: "Connected on COM3 (or your COM port number)
11) When all is working, you can slide the sliding points from the middle position to the left or right and your robotic arm should respond accordingly. 

In case your Arduino port number is different, minimize the graphical windows of the Processing window, so you can see the blue window that has some code in it.
About third line states: final String PORT_NAME = "COM3"; change the COM3 to COM4 or 5.... to match your COM port of the Arduino! 
Than click on the blue button, right upper side of the Processor graphical windows called Connect/Reconnect and see if in the PROCESSING window, second line on left upper corner, it states: "Connected on COM3 (or your COM port number).

There are also buttons on the right side called RECORD, you can record up to 5 different positions and when you push button called PLAY 1-5, the Robotic Arm will play all 5 positions back to you, just like if you did before.

Enjoy the Robotics Arm.
