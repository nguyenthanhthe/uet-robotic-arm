---
name: robot-firmware
description: Use when working on the robot arm firmware or control electronics — Arduino/ESP32/STM32 code, servo PWM over I2C (PCA9685), serial protocol between PC and MCU, pin mapping, or the MCU selection notes. Covers the firmware/ tree.
---

# Robot Firmware & Control Electronics

Scope: every maintained file under `firmware/`. This tree holds the embedded control
layer (Arduino `.ino` sketch and its README/plan). The control architecture splits a
PC/laptop master (vision + inverse kinematics) from an MCU slave (PWM, ADC, replay).

## Folder → owner map

| Path | Contents |
|---|---|
| `firmware/v2rad_code/v2rad_code.ino` | v2RAD reference sketch for Arduino Nano ESP32 (I2C PCA9685, 4 arm servos + gripper) |
| `firmware/README.md` | Firmware status, Uno + PCA9685 hardware table, channel map and to-do list |

## Task → first file

| You want to… | Open first | Also |
|---|---|---|
| Read/modify the Arduino control code | `firmware/v2rad_code/v2rad_code.ino` | `firmware/README.md` |
| Change servo channel/pin mapping | `firmware/README.md` | `docs/ke-hoach-dieu-khien-ai-robot.md` |
| Plan an ESP32/STM32 migration | `docs/chuyen-mcu-esp32-stm32.md` | `firmware/README.md` |
| Check the PC↔MCU serial protocol | `firmware/README.md` | `matlab/kuka_gui_control.m` |

Full file inventory: [references/files.json](references/files.json).
Related: `robot-simulation` (host-side GUI/serial), `project-docs` (MCU notes).
