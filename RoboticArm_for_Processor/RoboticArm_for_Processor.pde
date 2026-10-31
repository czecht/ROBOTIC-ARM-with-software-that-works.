import processing.serial.*;
import java.io.File;

Serial port;

final String PORT_NAME = "COM3";

// Seven sliders control eight physical servos.
// Channel 2 is derived from channel 1.
final int[] SLIDER_CHANNELS = {0, 1, 3, 4, 5, 6, 7};

final String[] SLIDER_LABELS = {
  "Servo 0",
  "Pair 1+2",
  "Servo 3",
  "Servo 4",
  "Servo 5",
  "Servo 6",
  "Servo 7"
};

final int TRACK_LEFT = 165;
final int TRACK_RIGHT = 655;
final int FIRST_Y = 160;
final int ROW_GAP = 60;

int[] angles = new int[8];
int[][] poses = new int[5][8];
boolean[] used = new boolean[5];

boolean connected = false;
boolean syncing = false;
boolean moving = false;
boolean playing = false;
boolean pausing = false;
boolean dirty = false;
boolean dialogOpen = false;

int activeSlider = -1;
int activeID = -1;
int nextID = 1;
int playSlot = -1;

int moveTime = 2000;
int pauseTime = 1000;

int lastHello = 0;
int lastReply = 0;
int lastSend = 0;
int pauseStarted = 0;
int syncSent = 0;
int movementSent = 0;
int expectedDuration = 0;

String input = "";
String status = "Disconnected";
String lastMessage = "(none)";
String note = "Channels 1 and 2 share one mirrored slider.";

volatile String chosenSave = null;
volatile String chosenLoad = null;
volatile boolean chooserFinished = false;

JSONObject saveCopy;

void setup() {
  size(1120, 800);
  textFont(createFont("Arial", 16));

  for (int i = 0; i < 8; i++) {
    angles[i] = 90;
  }

  applyPair(angles);

  connectPort();
}

// Channel 1 is the master; channel 2 is its mirror.
void applyPair(int[] values) {
  values[1] = constrain(values[1], 0, 180);
  values[2] = 180 - values[1];
}

void connectPort() {
  connected = false;
  syncing = false;
  moving = false;
  playing = false;
  pausing = false;
  dirty = false;
  activeSlider = -1;
  activeID = -1;
  input = "";
  lastMessage = "(none)";

  if (port != null) {
    try {
      port.stop();
    }
    catch (Exception ignored) {
    }

    port = null;
  }

  println("Available ports:");
  printArray(Serial.list());

  try {
    port = new Serial(this, PORT_NAME, 115200);

    status = "Waiting for Arduino on " + PORT_NAME + "...";
    note = "Opening the port may reset the UNO. Allow a few seconds.";

    lastHello = millis();
  }
  catch (Exception e) {
    status = "Cannot open " + PORT_NAME;
    note = "Close Serial Monitor/Plotter and check the port.";

    println(e.getMessage());
  }
}

void draw() {
  serviceSerial();
  serviceFiles();

  if (playing && pausing &&
      millis() - pauseStarted >= pauseTime) {
    pausing = false;
    nextPose();
  }

  if (canEdit() && dirty && millis() - lastSend >= 100) {
    dirty = false;
    lastSend = millis();

    moveArm(200);
  }

  background(24, 29, 39);

  fill(245);
  textAlign(LEFT, CENTER);
  textSize(25);
  text("Robotic Arm - Paired Joint / Five Poses", 25, 30);

  fill(
    connected ?
    color(100, 230, 150) :
    color(255, 195, 100)
  );

  textSize(15);
  text(status, 25, 65);

  fill(175, 195, 215);
  textSize(13);
  text("Last Arduino message: " + lastMessage, 25, 92);
  text(note, 25, 116);

  for (int row = 0; row < SLIDER_CHANNELS.length; row++) {
    drawSlider(row);
  }

  for (int i = 0; i < 5; i++) {
    int y = 160 + i * 82;

    fill(used[i] ? color(100, 230, 150) : color(160));

    textAlign(LEFT, CENTER);
    textSize(16);

    text(
      "Pose " + (i + 1) +
      (used[i] ? " - recorded" : " - empty"),
      800, y
    );

    button(
      800, y + 15, 125, 34,
      "Record", settled()
    );

    button(
      945, y + 15, 125, 34,
      "Go", canEdit() && used[i]
    );
  }

  fill(235);
  textAlign(LEFT, CENTER);
  textSize(16);

  text(
    "Move: " + nf(moveTime / 1000.0f, 1, 1) + " s",
    30, 617
  );

  text(
    "Pause: " + nf(pauseTime / 1000.0f, 1, 1) + " s",
    390, 617
  );

  boolean settings = !playing && !syncing && !dialogOpen;

  button(200, 600, 45, 34, "-", settings);
  button(255, 600, 45, 34, "+", settings);
  button(560, 600, 45, 34, "-", settings);
  button(615, 600, 45, 34, "+", settings);

  button(
    30, 660, 175, 45,
    "Play 1-5", settled() && anyPose()
  );

  button(
    220, 660, 175, 45,
    "STOP", connected
  );

  button(
    410, 660, 175, 45,
    "Park at 90", canEdit()
  );

  button(
    600, 660, 175, 45,
    "Save File",
    !playing && !syncing && !dialogOpen
  );

  button(
    790, 660, 175, 45,
    "Load File",
    !playing && !moving && !dirty &&
    !syncing && !dialogOpen
  );

  button(
    800, 32, 270, 42,
    "Connect / Reconnect", !dialogOpen
  );

  fill(170);
  textAlign(LEFT, CENTER);
  textSize(12);

  text(
    "Pair 1+2: channel 2 = 180 - channel 1. " +
    "Older pose files use channel 1 to set both servos.",
    30, 744
  );

  text(
    "STOP / space bar holds position. " +
    "Slider angles are targets, not measured positions.",
    30, 768
  );
}

boolean canEdit() {
  return connected && !syncing && !playing && !dialogOpen;
}

boolean settled() {
  return canEdit() && !moving && !dirty && activeSlider < 0;
}

boolean anyPose() {
  for (boolean value : used) {
    if (value) return true;
  }

  return false;
}

void button(
  int x, int y, int w, int h,
  String label, boolean enabled
) {
  noStroke();

  if (label.equals("STOP") && enabled) {
    fill(185, 50, 50);
  } else {
    fill(
      enabled ?
      color(50, 105, 150) :
      color(55, 62, 75)
    );
  }

  rect(x, y, w, h, 7);

  fill(enabled ? color(255) : color(135));
  textAlign(CENTER, CENTER);
  textSize(15);

  text(label, x + w / 2, y + h / 2);
}

boolean hit(int x, int y, int w, int h) {
  return mouseX >= x && mouseX <= x + w &&
         mouseY >= y && mouseY <= y + h;
}

void drawSlider(int row) {
  int channel = SLIDER_CHANNELS[row];
  int y = FIRST_Y + row * ROW_GAP;

  noStroke();
  fill(35, 42, 55);

  rect(25, y - 23, 735, 48, 7);

  fill(235);
  textAlign(LEFT, CENTER);
  textSize(16);

  text(SLIDER_LABELS[row], 40, y);

  float x = map(
    angles[channel], 0, 180,
    TRACK_LEFT, TRACK_RIGHT
  );

  strokeWeight(6);
  stroke(75, 90, 110);

  line(TRACK_LEFT, y, TRACK_RIGHT, y);

  stroke(65, 175, 240);
  line(TRACK_LEFT, y, x, y);

  noStroke();

  fill(
    canEdit() ?
    color(100, 205, 255) :
    color(130)
  );

  ellipse(x, y, 22, 22);

  fill(165);
  textSize(10);
  textAlign(CENTER, CENTER);

  text("0", TRACK_LEFT, y + 17);
  text("90", (TRACK_LEFT + TRACK_RIGHT) / 2, y + 17);
  text("180", TRACK_RIGHT, y + 17);

  fill(245);
  textAlign(RIGHT, CENTER);

  if (channel == 1) {
    textSize(13);

    text(
      "1: " + angles[1] + "\u00B0",
      745, y - 8
    );

    text(
      "2: " + angles[2] + "\u00B0",
      745, y + 9
    );
  } else {
    textSize(19);
    text(angles[channel] + "\u00B0", 740, y);
  }
}

void mousePressed() {
  if (mouseButton != LEFT) return;

  if (hit(220, 660, 175, 45) && connected) {
    stopArm();
    return;
  }

  if (dialogOpen) return;

  if (hit(800, 32, 270, 42)) {
    if (connected) send("STOP");

    connectPort();
    return;
  }

  if (!playing && !syncing) {
    if (hit(200, 600, 45, 34)) {
      moveTime = max(500, moveTime - 500);
      return;
    }

    if (hit(255, 600, 45, 34)) {
      moveTime = min(30000, moveTime + 500);
      return;
    }

    if (hit(560, 600, 45, 34)) {
      pauseTime = max(0, pauseTime - 500);
      return;
    }

    if (hit(615, 600, 45, 34)) {
      pauseTime = min(30000, pauseTime + 500);
      return;
    }

    if (hit(600, 660, 175, 45)) {
      saveCopy = createPoseFile();
      dialogOpen = true;

      selectOutput("Save pose file", "saveSelected");
      return;
    }

    if (hit(790, 660, 175, 45) && !moving && !dirty) {
      dialogOpen = true;

      selectInput("Load pose file", "loadSelected");
      return;
    }
  }

  if (!canEdit()) return;

  for (int i = 0; i < 5; i++) {
    int y = 160 + i * 82;

    if (hit(800, y + 15, 125, 34) && settled()) {
      applyPair(angles);
      arrayCopy(angles, poses[i]);

      used[i] = true;

      note =
        "Recorded pose " + (i + 1) +
        ". Save File keeps it on disk.";

      return;
    }

    if (hit(945, y + 15, 125, 34) && used[i]) {
      arrayCopy(poses[i], angles);
      applyPair(angles);

      dirty = false;
      moveArm(moveTime);

      note = "Moving to pose " + (i + 1);
      return;
    }
  }

  if (hit(30, 660, 175, 45) && settled() && anyPose()) {
    playing = true;
    pausing = false;
    playSlot = -1;

    nextPose();
    return;
  }

  if (hit(410, 660, 175, 45)) {
    for (int i = 0; i < 8; i++) {
      angles[i] = 90;
    }

    applyPair(angles);

    dirty = false;
    moveArm(moveTime);

    return;
  }

  for (int row = 0; row < SLIDER_CHANNELS.length; row++) {
    int y = FIRST_Y + row * ROW_GAP;

    if (
      mouseX >= TRACK_LEFT - 12 &&
      mouseX <= TRACK_RIGHT + 12 &&
      abs(mouseY - y) <= 22
    ) {
      activeSlider = row;
      updateSlider();

      return;
    }
  }
}

void mouseDragged() {
  if (canEdit()) updateSlider();
}

void mouseReleased() {
  if (canEdit()) updateSlider();

  activeSlider = -1;
}

void keyPressed() {
  if (key == ' ' && connected) stopArm();
}

void updateSlider() {
  if (activeSlider < 0) return;

  int channel = SLIDER_CHANNELS[activeSlider];

  float x = constrain(
    (float)mouseX,
    TRACK_LEFT,
    TRACK_RIGHT
  );

  int value = round(
    map(x, TRACK_LEFT, TRACK_RIGHT, 0, 180)
  );

  if (value != angles[channel]) {
    angles[channel] = value;

    applyPair(angles);
    dirty = true;
  }
}

void moveArm(int duration) {
  if (!connected || syncing) return;

  applyPair(angles);

  activeID = nextID++;
  moving = true;

  movementSent = millis();
  expectedDuration = duration;

  String command = "M," + activeID + "," + duration;

  for (int angle : angles) {
    command += "," + angle;
  }

  send(command);
}

void nextPose() {
  if (!playing || !connected) return;

  playSlot++;

  while (playSlot < 5 && !used[playSlot]) {
    playSlot++;
  }

  if (playSlot >= 5) {
    playing = false;
    pausing = false;

    note = "Playback complete.";
    return;
  }

  arrayCopy(poses[playSlot], angles);
  applyPair(angles);

  dirty = false;

  note = "Playing pose " + (playSlot + 1);
  moveArm(moveTime);
}

void stopArm() {
  playing = false;
  pausing = false;
  dirty = false;
  moving = false;

  activeSlider = -1;
  activeID = -1;

  syncing = true;
  syncSent = millis();

  note = "Requesting stop and held positions...";
  send("STOP");
}

void send(String command) {
  if (port == null) return;

  try {
    port.write(command + "\n");
  }
  catch (Exception e) {
    failConnection(e.getMessage());
  }
}

void serviceSerial() {
  if (port == null) return;

  try {
    while (port.available() > 0) {
      int value = port.read();

      if (value < 0) break;

      char c = (char)value;

      if (c == '\n') {
        String message = trim(input);

        input = "";
        handleMessage(message);
      } else if (c != '\r') {
        input += c;

        if (input.length() > 200) {
          input = "";
        }
      }
    }
  }
  catch (Exception e) {
    failConnection(e.getMessage());
    return;
  }

  if (millis() - lastHello >= 500) {
    lastHello = millis();
    send("HELLO");
  }

  if (connected && millis() - lastReply > 2500) {
    connected = false;
    syncing = false;
    playing = false;
    pausing = false;
    moving = false;
    dirty = false;

    activeSlider = -1;

    status =
      "Arduino stopped replying; waiting for reconnection.";
  }

  if (connected && syncing && millis() - syncSent > 600) {
    syncSent = millis();
    send("STOP");
  }

  if (
    connected && moving &&
    millis() - movementSent > expectedDuration + 2000
  ) {
    stopArm();

    note = "Movement completion missing; stop requested.";
  }
}

void handleMessage(String message) {
  if (message.length() == 0) return;

  lastMessage = message;
  println("Arduino > " + message);

  if (
    message.equals("READY") ||
    message.startsWith("READY,")
  ) {
    lastReply = millis();

    if (!connected) {
      connected = true;
      status = "Connected on " + PORT_NAME;

      stopArm();
    }

    return;
  }

  if (message.startsWith("BOOT:")) {
    connected = false;
    syncing = false;
    moving = false;
    playing = false;
    pausing = false;
    dirty = false;

    activeSlider = -1;

    status = "Arduino startup received; waiting for READY...";
    return;
  }

  try {
    String[] fields = split(message, ',');

    if (fields[0].equals("POS") && fields.length == 9) {
      int[] received = new int[8];

      for (int i = 0; i < 8; i++) {
        received[i] = Integer.parseInt(fields[i + 1]);

        if (received[i] < 0 || received[i] > 180) return;
      }

      applyPair(received);

      if (syncing) {
        arrayCopy(received, angles);

        syncing = false;
        moving = false;
        dirty = false;

        note =
          "Synchronized. Seven sliders enabled; " +
          "channels 1+2 are paired.";
      }

      lastReply = millis();
      return;
    }

    if (fields[0].equals("ACK") && fields.length == 2) {
      lastReply = millis();
      return;
    }

    if (fields[0].equals("DONE") && fields.length == 2) {
      lastReply = millis();

      if (
        Integer.parseInt(fields[1]) == activeID &&
        !syncing
      ) {
        moving = false;

        if (playing) {
          pausing = true;
          pauseStarted = millis();

          note =
            "Pose " + (playSlot + 1) +
            " reached; pausing.";
        } else {
          note = "Movement complete. You can record a pose.";
        }
      }

      return;
    }

    if (message.startsWith("ERROR:")) {
      if (connected && !syncing) stopArm();

      note = message;
    }
  }
  catch (Exception e) {
    println("Could not parse: " + message);
  }
}

void failConnection(String reason) {
  connected = false;
  syncing = false;
  moving = false;
  playing = false;
  pausing = false;
  dirty = false;

  activeSlider = -1;

  status = "Serial connection error. Use Connect / Reconnect.";
  note = reason;

  if (port != null) {
    try {
      port.stop();
    }
    catch (Exception ignored) {
    }
  }

  port = null;
}

// ---------- Pose files ----------

JSONObject createPoseFile() {
  JSONObject root = new JSONObject();

  // Keep the same file structure for compatibility.
  root.setInt("version", 1);
  root.setInt("moveMs", moveTime);
  root.setInt("pauseMs", pauseTime);
  root.setBoolean("pairedChannels1And2", true);

  JSONArray slots = new JSONArray();

  for (int i = 0; i < 5; i++) {
    applyPair(poses[i]);

    JSONObject slot = new JSONObject();
    slot.setBoolean("recorded", used[i]);

    JSONArray values = new JSONArray();

    for (int j = 0; j < 8; j++) {
      values.setInt(j, poses[i][j]);
    }

    slot.setJSONArray("angles", values);
    slots.setJSONObject(i, slot);
  }

  root.setJSONArray("poses", slots);

  return root;
}

void saveSelected(File selection) {
  if (selection != null) {
    chosenSave = selection.getAbsolutePath();
  }

  chooserFinished = true;
}

void loadSelected(File selection) {
  if (selection != null) {
    chosenLoad = selection.getAbsolutePath();
  }

  chooserFinished = true;
}

void serviceFiles() {
  if (!chooserFinished) return;

  chooserFinished = false;

  String saveName = chosenSave;
  String loadName = chosenLoad;

  chosenSave = null;
  chosenLoad = null;

  try {
    if (saveName != null) {
      if (!saveName.toLowerCase().endsWith(".json")) {
        saveName += ".json";
      }

      if (!saveJSONObject(saveCopy, saveName)) {
        throw new RuntimeException("Could not save file");
      }

      note = "Saved: " + new File(saveName).getName();
    }

    if (loadName != null) {
      JSONObject root = loadJSONObject(loadName);

      if (root == null || root.getInt("version") != 1) {
        throw new RuntimeException("Unsupported pose file");
      }

      int newMove = root.getInt("moveMs");
      int newPause = root.getInt("pauseMs");

      if (
        newMove < 500 || newMove > 30000 ||
        newPause < 0 || newPause > 30000
      ) {
        throw new RuntimeException("Invalid timing");
      }

      JSONArray slots = root.getJSONArray("poses");

      if (slots.size() != 5) {
        throw new RuntimeException("Expected five poses");
      }

      int[][] loadedPoses = new int[5][8];
      boolean[] loadedUsed = new boolean[5];

      for (int i = 0; i < 5; i++) {
        JSONObject slot = slots.getJSONObject(i);

        loadedUsed[i] = slot.getBoolean("recorded");

        JSONArray values = slot.getJSONArray("angles");

        if (values.size() != 8) {
          throw new RuntimeException(
            "Expected eight angles per pose"
          );
        }

        for (int j = 0; j < 8; j++) {
          int angle = values.getInt(j);

          if (angle < 0 || angle > 180) {
            throw new RuntimeException(
              "Angle outside 0-180"
            );
          }

          loadedPoses[i][j] = angle;
        }

        // Old files may contain an independent channel 2.
        // Channel 1 now determines both paired positions.
        applyPair(loadedPoses[i]);
      }

      poses = loadedPoses;
      used = loadedUsed;

      moveTime = newMove;
      pauseTime = newPause;

      note =
        "Poses loaded with channels 1+2 mirrored. " +
        "Click Go or Play to move.";
    }
  }
  catch (Exception e) {
    note = "File error: " + e.getMessage();
    println(note);
  }

  saveCopy = null;
  dialogOpen = false;
}
