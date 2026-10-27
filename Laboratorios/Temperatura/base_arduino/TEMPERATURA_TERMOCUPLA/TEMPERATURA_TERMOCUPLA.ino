#include <max6675.h>

// Definición de los pines solicitados para la ESP32-S3
int thermoDO  = 47; // SO (Salida de datos)
int thermoCS  = 48; // CS (Chip Select)
int thermoCLK = 45; // SCK (Reloj)

// Inicializar el objeto MAX6675 con los pines asignados
MAX6675 thermocouple(thermoCLK, thermoCS, thermoDO);

void setup() {
  // Inicializamos la comunicación serial a 115200 baudios (típico en ESP32)
  Serial.begin(115200);
  
  // Pequeña pausa para que el sensor se estabilice al encender
  delay(500); 
  
  Serial.println("Iniciando lectura de termocupla MAX6675...");
}

void loop() {
  // Leer y mostrar la temperatura en grados Celsius
  Serial.print("Temperatura: ");
  Serial.print(thermocouple.readCelsius());
  Serial.println(" °C");

  // Si también necesitas la lectura en Fahrenheit, puedes usar esta línea:
  // Serial.print("Fahrenheit: ");
  // Serial.println(thermocouple.readFahrenheit());

  // El chip MAX6675 necesita un tiempo de conversión mínimo de ~250ms.
  // Un retraso de 1 segundo es ideal para lecturas estables.
  delay(1000);
}