#include <Motoron.h>
#include <WiFiS3.h>
#include <Wire.h>
#include <LSM6.h>
#include <math.h>

// -------- WIFI --------
char ssid[] = "zilin";
char pass[] = "watermelon";

WiFiSSLClient client;
char HOST_NAME[] = "api.pushcut.io";
const int port = 443;

// -------- IMU --------
LSM6 imu;

// -------- MOTOR --------
MotoronI2C mc(0x10);
const int motorLeft = 1;
const int motorRight = 2;

int speed = 0;
const int maxSpeed = 800;
const int minStartSpeed = 600;

// -------- SENSORS --------
const int distancePin = A2;
const int ldrPin = A0;

// -------- DISTANCE TABLE --------
const int numPoints = 16;

float voltageTable[numPoints] = {
  2.60, 2.30, 1.63, 1.40, 1.15, 0.97, 0.90, 0.80,
  0.75, 0.70, 0.68, 0.63, 0.60, 0.57, 0.50, 0.40
};

float distanceTable[numPoints] = {
  0,2,3,4,5,6,7,8,9,10,11,12,13,14,15,18
};

float filteredVoltage = 0;

// -------- THRESHOLDS --------
const float obstacleThreshold = 4.3;
const float lightThreshold = 2.5;

// -------- TIMING --------
unsigned long lastNotification = 0;
unsigned long notificationInterval = 5000;
unsigned long lastMoveTime = 0;

// -------- NOTIFICATIONS --------
String notifications[] = {
  "/XqclO3hK_CIauvfDO63QQ/notifications/CHEESE",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Easy-Peasy",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Frenchie",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Good-God-Man",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Hey-Baby",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Hmm-Cheese",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Holy-Macaroni",
  "/XqclO3hK_CIauvfDO63QQ/notifications/I-Feel-Grate",
  "/XqclO3hK_CIauvfDO63QQ/notifications/I-Forgot",
  "/XqclO3hK_CIauvfDO63QQ/notifications/I-Gorgonzola",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Ain't-Easy",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Feta-Up",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Moo-FAHH",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Mr-Bombastic",
  "/XqclO3hK_CIauvfDO63QQ/notifications/Cheese-Touch",
  "/XqclO3hK_CIauvfDO63QQ/notifications/HELP"
};

// -------- SETUP --------
void setup() {
  Serial.begin(115200);
  Wire.begin();
  
  // IMU init FIRST (important)
  if (!imu.init()) {
    Serial.println("IMU FAIL");
    while (1);
  }
  imu.enableDefault();

  // Motor setup
  mc.reinitialize();
  mc.disableCrc();
  mc.clearResetFlag();

  mc.setMaxAcceleration(motorLeft, 200);
  mc.setMaxDeceleration(motorLeft, 300);
  mc.setMaxAcceleration(motorRight, 200);
  mc.setMaxDeceleration(motorRight, 300);

  // WiFi
  WiFi.begin(ssid, pass);
  Serial.print("Connecting");
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  Serial.println("\nWiFi ready");
}

// -------- LOOP --------
void loop() {

  // ===== IMU =====
  imu.read();

  double mag_acc = sqrt(imu.a.x * imu.a.x + imu.a.y * imu.a.y + imu.a.z * imu.a.z);
  double mag_gyro = sqrt(imu.g.x * imu.g.x + imu.g.y * imu.g.y + imu.g.z * imu.g.z);

  Serial.print("ACC: "); Serial.print(mag_acc);
  Serial.print(" | GYRO: "); Serial.println(mag_gyro);
  if (imu.a.x == -1){
    sendNotification(notifications[3]);
  }
  // ===== CRASH DETECTION =====
  if (mag_acc > 20000 || mag_gyro > 18000) {
    Serial.println("CRASH!");

    sendNotification(notifications[15]);

    // simple swerve (non-looping)
    mc.setSpeed(motorLeft, 500);
    mc.setSpeed(motorRight, 250);
    delay(500);

    lastNotification = millis();
    return;
  }

  // ===== RANDOM SOUND =====
  if (millis() - lastNotification > notificationInterval) {
    int index = random(0, 15);
    sendNotification(notifications[index]);

    lastNotification = millis();
    notificationInterval = random(5000, 7000);
  }

  // ===== SENSORS =====
  float distance = getFilteredDistance();
  float light = readLight();

  Serial.print("Dist: "); Serial.print(distance);
  Serial.print(" | Light: "); Serial.println(light);

  // ===== BEHAVIOUR =====
  if (distance < obstacleThreshold) {
  StopMotors();
  }
  else if (light < lightThreshold) {
    MoveForward();
  }
  else {
    StopMotors();
  }

  //ensureMovement();
  //updateMovementTimer();

  delay(50);
}

// -------- MOVEMENT --------
void MoveForward() {
  //Kickstart();
  speed = 700;
  mc.setSpeed(motorLeft, speed);
  mc.setSpeed(motorRight, -speed);
}

// void Kickstart(){
//   if (speed > 0 && speed < minStartSpeed) speed = minStartSpeed;

//   // kickstart
//   mc.setSpeed(motorLeft, 700);
//   mc.setSpeed(motorRight, 700);
//   delay(50);
// }

void MoveBackwards() {
  //Kickstart();
  mc.setSpeed(motorLeft, -700);
  mc.setSpeed(motorRight, 700);
}

void TurnLeft(int s) {
  //Kickstart();
  mc.setSpeed(motorLeft, s);
  mc.setSpeed(motorRight, s);
}

void TurnRight(int s) {
  //Kickstart();
  mc.setSpeed(motorLeft, -s);
  mc.setSpeed(motorRight, -s);
}

void StopMotors() {
  speed = 0;
  mc.setSpeed(motorLeft, 0);
  mc.setSpeed(motorRight, 0);
}

// -------- BEHAVIOURS --------
void avoidObstacle() {
  StopMotors();
  delay(100);

  // if (random(0, 2) == 0) TurnLeft(700);
  // else TurnRight(700);

  // delay(300);
}

void searchForLight() {
  TurnRight(700);
  delay(100);
}

void moveTowardLight(float lightValue) {
  //speed = motor_control(lightValue);
  speed = 700;
  MoveForward();
}

// -------- SENSORS --------
// float getDistance() {
//   int raw = analogRead(distancePin);
//   float voltage = raw * (5.0 / 1023.0);
//   return voltage * 10; // simplified for now
// }

float readVoltage() {
  int raw = analogRead(distancePin);
  return raw * (5.0 / 1023.0);
}

float getDistanceFromTable(float volts) {
  if(volts >= voltageTable[0]) return distanceTable[0];
  if(volts <= voltageTable[numPoints-1]) return distanceTable[numPoints-1];

  for(int i = 0; i < numPoints - 1; i++) {
    if(volts <= voltageTable[i] && volts >= voltageTable[i+1]) {
      float ratio = (volts - voltageTable[i+1]) /
                    (voltageTable[i] - voltageTable[i+1]);

      return distanceTable[i+1] +
             ratio * (distanceTable[i] - distanceTable[i+1]);
    }
  }
  return -1;
}

float getFilteredDistance() {
  float volts = readVoltage();
  filteredVoltage = 0.8 * filteredVoltage + 0.2 * volts;
  return getDistanceFromTable(filteredVoltage);
}

// Light

float readLight() {
  int raw = analogRead(ldrPin);
  float voltage = raw * (5.0 / 1023.0);
  voltage = 5-voltage;
  return voltage * 10;
}

// -------- MOTOR CONTROL --------
int motor_control(float lightValue) {
  float computed = maxSpeed * (lightValue / 60.0);
  return constrain((int)computed, 0, maxSpeed);
}

// -------- SAFETY --------
void ensureMovement() {
  if (speed > 0 && speed < minStartSpeed) {
    speed = minStartSpeed;
  }

  if (speed > 0) {
    mc.setSpeed(motorLeft, 700);
    mc.setSpeed(motorRight, 700);
    delay(30);
  }
}

void updateMovementTimer() {
  if (speed > 0) lastMoveTime = millis();

  if (millis() - lastMoveTime > 3000) {
    MoveBackwards();
    delay(300);
    TurnLeft(700);
    delay(400);
    lastMoveTime = millis();
  }
}

// -------- WIFI --------
void sendNotification(String path) {
  if (!client.connect(HOST_NAME, port)) return;

  client.println("GET " + path + " HTTP/1.1");
  client.println("Host: " + String(HOST_NAME));
  client.println("Connection: close");
  client.println();

  delay(50);
  client.stop();
}