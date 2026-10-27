const int PIN_ENTRADA = A0;
const bool CALIBRACION_CARGADA = false;
// Sustituir por resultados propios ANTES de habilitar la conversión.
const float I_BAJA = 4.0f;    // Corriente real medida, mA
const float I_ALTA = 20.0f;   // Corriente real medida, mA
const float ADC_BAJO = 0.0f;  // Promedio experimental inferior
const float ADC_ALTO = 0.0f;  // Promedio experimental superior
const float T_MIN = 0.0f;
const float T_MAX = 50.0f;

float leerPromedio() {
  long suma = 0;
  for (int k = 0; k < 50; ++k) {
    suma += analogRead(PIN_ENTRADA);
    delay(2);
  }
  return suma / 50.0f;
}

void setup() {
  Serial.begin(9600);
  analogReference(DEFAULT);
}

void loop() {
  const float adc = leerPromedio();
  Serial.print("ADC=");
  Serial.print(adc, 2);
  if (CALIBRACION_CARGADA && ADC_ALTO > ADC_BAJO && I_ALTA > I_BAJA) {
    const float corriente = I_BAJA + (adc - ADC_BAJO)
      * (I_ALTA - I_BAJA) / (ADC_ALTO - ADC_BAJO);
    Serial.print("; mA=");
    Serial.print(corriente, 3);
    if (corriente >= 4.0f && corriente <= 20.0f) {
      const float temperatura = T_MIN + (corriente - 4.0f)
        * (T_MAX - T_MIN) / 16.0f;
      Serial.print("; T_C=");
      Serial.print(temperatura, 2);
    } else {
      Serial.print("; FUERA_DEL_INTERVALO_NOMINAL_4_20_mA");
    }
  } else {
    Serial.print("; registrar ADC y corriente del multimetro");
  }
  Serial.println();
  delay(500);
}
