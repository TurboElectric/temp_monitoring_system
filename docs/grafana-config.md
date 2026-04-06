
#### 📄 `temp-monitoring-system/docs/grafana-config.md`

```markdown
## Настройка Grafana

1. Откройте `http://raspberry-ip:3000`
2. Войдите: `admin/admin`
3. Добавьте источник данных:
   - Type: InfluxDB
   - HTTP URL: `http://influxdb:8086`
   - Token: `influx_token`
   - Organization: `myorg`
4. Создайте дашборд:
   - Query: `SELECT * FROM temperature GROUP BY sensor_id`