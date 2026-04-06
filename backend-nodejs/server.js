const ModbusRTU = require('modbus-serial');
const mqtt = require('mqtt');
const admin = require('firebase-admin');
const { InfluxDB, Point } = require('@influxdata/influxdb-client');

// Инициализация Firebase
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Инициализация InfluxDB
const influxDB = new InfluxDB({
  url: process.env.INFLUXDB_URL,
  token: process.env.INFLUXDB_TOKEN,
});
const writeApi = influxDB.getWriteApi(process.env.INFLUXDB_ORG, process.env.INFLUXDB_BUCKET);

// Подключение к RS485
const client = new ModbusRTU();
client.connectRTUBuffered('/dev/ttyUSB0', { baudRate: 9600 });
client.setTimeout(1000);

// Подключение к MQTT
const mqttClient = mqtt.connect('mqtt://mosquitto:1883');

const NUM_SENSORS = 80;
const TEMP_THRESHOLD = 80;

async function readTemperature(id) {
  try {
    client.setID(id);
    const response = await client.readInputRegisters(0, 2);
    return response.buffer.readUInt16BE(0) / 10;
  } catch (err) {
    console.error(`Error reading sensor ${id}:`, err);
    return null;
  }
}

async function writeToInflux(sensorId, temp) {
  const point = new Point('temperature')
    .tag('sensor_id', sensorId.toString())
    .floatField('value', temp)
    .timestamp(new Date());
  writeApi.writePoint(point);
}

async function readAllSensors() {
  let sensors = [];
  for (let i = 1; i <= NUM_SENSORS; i++) {
    const temp = await readTemperature(i);
    if (temp !== null) {
      sensors.push({ id: i, temp });

      // Запись в InfluxDB
      writeToInflux(i, temp);

      if (temp > TEMP_THRESHOLD) {
        mqttClient.publish('temperature/alerts', JSON.stringify({
          sensor_id: i,
          temp: temp,
          timestamp: new Date().toISOString()
        }));

        // Отправка уведомления в Firebase
        const payload = {
          notification: {
            title: `Тревога: датчик ${i}`,
            body: `Температура: ${temp}°C`
          }
        };
        admin.messaging().sendToDevice(process.env.FIREBASE_DEVICE_TOKEN, payload)
          .catch(err => console.error('Firebase error:', err));
      }
    }
  }

  mqttClient.publish('temperature/sensors/all', JSON.stringify({
    timestamp: new Date().toISOString(),
    sensors
  }));
}

setInterval(() => {
  writeApi.flush(); // Flush every 5 seconds
  readAllSensors();
}, 5000);