#include <LiquidCrystal_I2C.h>
#include <FireBase32.h>

#define FORCE_SENSOR_PIN 35
#define PIN_RED    13 
#define PIN_GREEN  34 
#define PIN_BLUE   14
#define DISTANCE_SENSOR 33 

int fsrReading;
int valDistance = 0;
int lotacao;
int counterReserva;
String reserveName;
int counter;
boolean first = true;

LiquidCrystal_I2C lcd(0x27, 16, 2); 

FireBase32 db("https://scmu-3a5ac-default-rtdb.europe-west1.firebasedatabase.app/", "rVCKHQIf49T0HudAJ1165T0dV6PCP1o3R6cAmJCi");

void setup() {
  //Serial.begin(9600);  //Para o distance sensor
  Serial.begin(115200); //Para firebase
  db.wifi("NOS-17D4", "ZYGN4AJZ");
  
  pinMode(PIN_RED,   OUTPUT);
  pinMode(PIN_GREEN, OUTPUT);
  pinMode(PIN_BLUE,  OUTPUT);
  lcd.init();
  lcd.backlight();
  counter = 11; 
  counterReserva = 0;
}

void loop() {
  valDistance = analogRead(DISTANCE_SENSOR);
  
  db.GetData("/lotacao/atual", &lotacao);
  if(valDistance > 1500 && counter <0 && lotacao > 0) {
    lotacao--;
    db.WriteData(lotacao, "/lotacao/atual");
    counter = 11;
  }

  db.GetString("/maquina1/nomeReserva", &reserveName);
  if (!reserveName.equals("null")) {
    analogWrite(PIN_RED,   0);
    analogWrite(PIN_GREEN, 0);
    analogWrite(PIN_BLUE,  255);
    lcd.clear();
    lcd.setCursor(0,0);
    lcd.print("Reservado por   " );
    lcd.setCursor(0,1);
    lcd.print(reserveName);
    db.WriteData(1, "/maquina1/estado"); //maquina1
    if (first == true) {
      counterReserva = 70;
      first = false;
    }
    if (counterReserva == 0) {
      db.WriteString ("null", "/maquina1/nomeReserva");
      first = true;
    }
  } else {
     fsrReading = analogRead(FORCE_SENSOR_PIN);
    if(fsrReading > 100) {
      analogWrite(PIN_RED,   0);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE,  255);
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Busy ");
      db.WriteData(1, "/maquina1/estado"); //maquina1
    }
    else {
      analogWrite(PIN_RED,   255);
      analogWrite(PIN_GREEN, 0);
      analogWrite(PIN_BLUE,  0);
      lcd.clear();
      lcd.setCursor(0,0);
      lcd.print("Livre");
      db.WriteData(0, "/maquina1/estado"); //maquina1
    }
  }
  counter--;
  if (!reserveName.equals("null")) {
    counterReserva--;
  }
}
