#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>
#include <stdlib.h>
#include <string.h>

Adafruit_PWMServoDriver pwm(0x40);

const byte SERVO_COUNT = 8;
const int MIN_US = 500;
const int MAX_US = 2500;

float position[8];
float beginning[8];
int destination[8];

bool shieldOK = false;
bool moving = false;

long movementID = 0;
unsigned long startedAt = 0;
unsigned long durationMs = 2000;
unsigned long lastUpdate = 0;
unsigned long lastContact = 0;
unsigned long lastAnnouncement = 0;

char lineBuffer[150];
byte lineLength = 0;
bool overflow = false;

void writeServo(byte channel, float angle) {
  angle = constrain(angle, 0.0f, 180.0f);

  int pulse = MIN_US +
    (int)((MAX_US - MIN_US) * angle / 180.0f + 0.5f);

  pwm.writeMicroseconds(channel, pulse);
}

void sendPositions() {
  Serial.print(F("POS"));

  for (byte i = 0; i < SERVO_COUNT; i++) {
    Serial.print(',');
    Serial.print((int)(position[i] + 0.5f));
  }

  Serial.println();
}

void sendReady() {
  if (shieldOK) {
    // Keep the handshake simple.
    Serial.println(F("READY"));
  } else {
    Serial.println(F("ERROR:PCA9685 not found at 0x40"));
  }
}

void stopMovement() {
  moving = false;

  // Leave the PCA9685 generating its latest position pulses.
  sendPositions();
}

void updateMovement() {
  if (!moving || !shieldOK) return;

  float t = (float)(millis() - startedAt) / durationMs;
  if (t > 1.0f) t = 1.0f;

  float smooth = t * t * (3.0f - 2.0f * t);

  for (byte i = 0; i < SERVO_COUNT; i++) {
    position[i] =
      beginning[i] + (destination[i] - beginning[i]) * smooth;

    writeServo(i, position[i]);
  }

  if (t >= 1.0f) {
    moving = false;
    Serial.print(F("DONE,"));
    Serial.println(movementID);
  }
}

bool getNumber(char* text, long &value) {
  if (text == NULL || *text == '\0') return false;

  char* end;
  value = strtol(text, &end, 10);

  return end != text && *end == '\0';
}

void processLine(char* command) {
  if (strcmp(command, "HELLO") == 0) {
    lastContact = millis();
    sendReady();
    return;
  }

  if (!shieldOK) {
    sendReady();
    return;
  }

  if (strcmp(command, "STOP") == 0) {
    lastContact = millis();
    stopMovement();
    return;
  }

  // Format: M,id,duration,angle0,...,angle7
  char* token = strtok(command, ",");

  if (token == NULL || strcmp(token, "M") != 0) {
    Serial.println(F("ERROR:Unknown command"));
    return;
  }

  long newID;
  long newDuration;
  long angles[8];

  if (!getNumber(strtok(NULL, ","), newID) ||
      !getNumber(strtok(NULL, ","), newDuration) ||
      newID < 1 || newDuration < 100 || newDuration > 30000) {
    Serial.println(F("ERROR:Invalid movement"));
    return;
  }

  for (byte i = 0; i < SERVO_COUNT; i++) {
    if (!getNumber(strtok(NULL, ","), angles[i]) ||
        angles[i] < 0 || angles[i] > 180) {
      Serial.println(F("ERROR:Invalid angle"));
      return;
    }
  }

  if (strtok(NULL, ",") != NULL) {
    Serial.println(F("ERROR:Too many angles"));
    return;
  }

  updateMovement();

  for (byte i = 0; i < SERVO_COUNT; i++) {
    beginning[i] = position[i];
    destination[i] = (int)angles[i];
  }

  movementID = newID;
  durationMs = (unsigned long)newDuration;
  startedAt = millis();
  lastContact = millis();
  moving = true;

  Serial.print(F("ACK,"));
  Serial.println(movementID);
}

void setup() {
  Serial.begin(115200);
  Serial.println(F("BOOT:ARM5"));

  shieldOK = pwm.begin();

  for (byte i = 0; i < SERVO_COUNT; i++) {
    position[i] = 90;
    beginning[i] = 90;
    destination[i] = 90;
  }

  if (shieldOK) {
    pwm.setPWMFreq(50);
    delay(100);

    for (byte i = 0; i < SERVO_COUNT; i++) {
      writeServo(i, 90);
      delay(200);
    }
  }

  lastContact = millis();
  sendReady();
}

void loop() {
  if (millis() - lastUpdate >= 20) {
    lastUpdate = millis();
    updateMovement();
  }

  while (Serial.available() > 0) {
    char c = (char)Serial.read();

    if (c == '\r') continue;

    if (c == '\n') {
      if (!overflow && lineLength > 0) {
        lineBuffer[lineLength] = '\0';
        processLine(lineBuffer);
      }

      lineLength = 0;
      overflow = false;
    } else if (!overflow) {
      if (lineLength < sizeof(lineBuffer) - 1) {
        lineBuffer[lineLength++] = c;
      } else {
        overflow = true;
      }
    }
  }

  // Repeat READY so a missed startup message cannot prevent connection.
  if (millis() - lastAnnouncement >= 1000) {
    lastAnnouncement = millis();
    sendReady();
  }

  if (moving && millis() - lastContact > 3000) {
    stopMovement();
    Serial.println(F("NOTICE:Communication timeout; holding"));
  }
}