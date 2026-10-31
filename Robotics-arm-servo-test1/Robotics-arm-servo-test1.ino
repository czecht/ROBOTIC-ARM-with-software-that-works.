#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

// Default PCA9685 I2C address.
Adafruit_PWMServoDriver pwm(0x40);

const uint8_t SERVO_COUNT = 8;  // Channels 0 through 7
const uint16_t SERVO_FREQ = 50;

// Nominal pulse range for the TD-8120MG 180-degree model.
// Adjust these if a servo hits its mechanical stop or buzzes.
const uint16_t MIN_PULSE_US = 500;   // 0 degrees
const uint16_t MAX_PULSE_US = 2500;  // 180 degrees

const uint16_t STEP_DELAY_MS = 20;  // Larger = slower sweep
const uint16_t HOLD_DELAY_MS = 500;

void setServoAngle(uint8_t channel, int angle) {
  angle = constrain(angle, 0, 180);

  uint16_t pulseUs =
      MIN_PULSE_US +
      ((uint32_t)(MAX_PULSE_US - MIN_PULSE_US) * angle) / 180;

  pwm.writeMicroseconds(channel, pulseUs);
}

void sweepServo(uint8_t channel, int fromAngle, int toAngle) {
  int step = (toAngle >= fromAngle) ? 1 : -1;

  for (int angle = fromAngle; ; angle += step) {
    setServoAngle(channel, angle);
    delay(STEP_DELAY_MS);

    if (angle == toAngle) {
      break;
    }
  }
}

void setup() {
  Serial.begin(115200);

  if (!pwm.begin()) {
    Serial.println(F("PCA9685 not found. Check power and I2C wiring."));
    while (true) {
      delay(1000);
    }
  }

  pwm.setPWMFreq(SERVO_FREQ);
  delay(100);

  // Initially park every servo at 90 degrees.
  // The initial movement depends on its existing physical position.
  Serial.println(F("Parking servos at 90 degrees..."));

  for (uint8_t channel = 0; channel < SERVO_COUNT; channel++) {
    setServoAngle(channel, 90);
    delay(300);
  }

  delay(1000);

  // Test each servo individually, then leave it at 90 degrees.
  for (uint8_t channel = 0; channel < SERVO_COUNT; channel++) {
    Serial.print(F("Testing channel "));
    Serial.println(channel);

    sweepServo(channel, 90, 0);
    delay(HOLD_DELAY_MS);

    sweepServo(channel, 0, 180);
    delay(HOLD_DELAY_MS);

    sweepServo(channel, 180, 90);
    delay(HOLD_DELAY_MS);
  }

  Serial.println(F("Test complete. All servos parked at 90 degrees."));
}

void loop() {
  // PCA9685 continues generating pulses to hold all servos at 90.
  // Press RESET to run the test again.
}