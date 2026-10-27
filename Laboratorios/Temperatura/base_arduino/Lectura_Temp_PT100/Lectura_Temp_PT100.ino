// ===== PINES =====
const int pinSensor1 = A0;   // II1: 0 a 200°C
const int pinSensor2 = A1;   // II2: 0 a 400°C

// ===== CALIBRACIÓN ADC (Común para ambos si usan el mismo circuito) =====
float adc_4mA  = 205.0;      
float adc_20mA = 820.0;      

// ===== RANGOS DE TEMPERATURA =====
float T1_Min = 0.0; float T1_Max = 200.0;
float T2_Min = 0.0; float T2_Max = 150.0;

const int muestras = 20;

// --- Funciones de Procesamiento ---

float leerPromedioADC(int pin, int n) {
  long suma = 0;
  for (int i = 0; i < n; i++) {
    suma += analogRead(pin);
    delay(5); // Reducido un poco para no saturar el loop
  }
  return (float)suma / n;
}

float adcToCorriente_mA(float adc) {
  return 4.0 + ((adc - adc_4mA) * (20.0 - 4.0) / (adc_20mA - adc_4mA));
}

// Nueva función que acepta rango dinámico
float corrienteToTemperatura(float mA, float tMin, float tMax) {
  return tMin + ((mA - 4.0) * (tMax - tMin) / (20.0 - 4.0));
}

void imprimirLectura(String nombre, float adc, float mA, float temp) {
  Serial.print(nombre + " -> ");
  if (mA < 3.6 || mA > 21.0) {
    Serial.println("ADC: " + String(adc, 1) + " | mA: " + String(mA, 2) + " | ERROR");
  } else {
    Serial.println("ADC: " + String(adc, 1) + " | mA: " + String(mA, 2) + " | Temp: " + String(temp, 2) + " C");
  }
}

void setup() {
  Serial.begin(9600);
  analogReference(DEFAULT); 
  Serial.println("Lectura Dual PT100 (4-20mA)");
  Serial.println("----------------------------");
}

void loop() {
  // --- Procesar Sensor 1 (II1) ---
  float adc1 = leerPromedioADC(pinSensor1, muestras);
  float ma1  = adcToCorriente_mA(adc1);
  float temp1 = corrienteToTemperatura(ma1, T1_Min, T1_Max);
  imprimirLectura("II1 (200C)", adc1, ma1, temp1);

  // --- Procesar Sensor 2 (II2) ---
  float adc2 = leerPromedioADC(pinSensor2, muestras);
  float ma2  = adcToCorriente_mA(adc2);
  float temp2 = corrienteToTemperatura(ma2, T2_Min, T2_Max);
  imprimirLectura("II2 (400C)", adc2, ma2, temp2);

  Serial.println("----------------------------");
  delay(1000); // Pausa entre lecturas generales
}