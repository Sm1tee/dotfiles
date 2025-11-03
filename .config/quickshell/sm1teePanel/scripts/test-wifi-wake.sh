#!/bin/bash
# Скрипт для тестирования обновления WiFi после пробуждения

echo "=== WiFi Wake Test ==="
echo "Текущее состояние WiFi:"
nmcli radio wifi
echo ""
echo "Активные соединения:"
nmcli connection show --active
echo ""
echo "Состояние устройств:"
nmcli device status
echo ""
echo "Текущая WiFi сеть:"
nmcli -t -f ACTIVE,SSID,SIGNAL device wifi list | grep "^yes:"
