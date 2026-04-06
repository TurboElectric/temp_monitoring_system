## Подключение датчиков к Raspberry Pi

### Оборудование:
- Raspberry Pi 3B+
- USB-to-RS485 адаптер (например, FT232RL-based)
- 80 датчиков с поддержкой Modbus RTU
- Шина RS485 (A/B/GND)

### Подключение:
- A → A
- B → B
- GND → GND

### Проверка:
```bash
ls /dev/ttyUSB*
stty -F /dev/ttyUSB0 9600