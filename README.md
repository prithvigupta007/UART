# Parameterized UART IP Core

A synthesizable UART communication system implemented in Verilog HDL, featuring a dedicated baud-rate generator, FSM-based transmitter, and 16× oversampling receiver with two-stage input synchronization.

## Features

- Parameterized clock frequency and baud rate
- 8-bit UART communication
- FSM-based TX and RX controllers
- 16× RX oversampling
- Two-stage RX input synchronization
- LSB-first data transmission
- Start and stop bit detection
- TX busy and completion status
- RX completion indication
- Synthesizable Verilog RTL

## Architecture

```text
                         +------------------+
                         |     uart_top     |
                         +--------+---------+
                                  |
                         +--------v---------+
                         |     baud_gen     |
                         +----+--------+----+
                              |        |
                           tx_tick   rx_tick
                              |        |
                              v        v
                        +---------+ +---------+
                        | uart_tx | | uart_rx |
                        +----+----+ +----+----+
                             |           ^
                             |           |
                             +-----------+
                            serial_line
```

## Modules

### `baud_gen`

Generates the timing ticks required by the UART transmitter and receiver.

**Parameters:**
- `CLK_FREQ` – System clock frequency
- `BAUD_RATE` – UART baud rate

**Inputs:**
- `clk`
- `rst`

**Outputs:**
- `tx_tick` – Baud-rate tick for the transmitter
- `rx_tick` – 16× oversampling tick for the receiver

---

### `uart_tx`

Converts 8-bit parallel data into a UART serial stream using an FSM.

**Inputs:**
- `clk`
- `rst`
- `tx_tick`
- `tx_start`
- `tx_data[7:0]`

**Outputs:**
- `tx_serial`
- `tx_busy`
- `tx_done`

UART frame:

```text
Start | D0 D1 D2 D3 D4 D5 D6 D7 | Stop
  0   |       8-bit data          |  1
```

Data is transmitted LSB first.

---

### `uart_rx`

Converts the incoming UART serial stream into 8-bit parallel data.

The receiver uses **16× oversampling** and a **two-stage input synchronizer** for safe sampling of the asynchronous serial input.

**Internal Blocks:**
- Two-stage synchronizer
- FSM controller
- Sample counter
- Bit counter
- Shift register

**Inputs:**
- `clk`
- `rst`
- `rx_tick`
- `rx_serial`

**Outputs:**
- `rx_data[7:0]`
- `rx_done`

RX FSM:

```text
IDLE → START → DATA → STOP → IDLE
```

---

### `uart_top`

Top-level module that integrates the baud-rate generator, transmitter, and receiver.

**Inputs:**
- `clk`
- `rst`
- `tx_start`
- `tx_data[7:0]`

**Outputs:**
- `tx_busy`
- `tx_done`
- `rx_data[7:0]`
- `rx_done`

The transmitter and receiver are connected through the internal `serial_line`.

## Default Configuration

| Parameter | Value |
|---|---:|
| Clock Frequency | 50 MHz |
| Baud Rate | 115200 |
| Data Bits | 8 |
| Start Bits | 1 |
| Stop Bits | 1 |
| Parity | None |
| RX Oversampling | 16× |
| Data Order | LSB First |

## Data Flow

### Transmission

```text
tx_data
   ↓
uart_tx
   ↓
serial_line
```

### Reception

```text
serial_line
   ↓
uart_rx
   ↓
rx_data
```

## Project Structure

```text
UART/
├── rtl/
│   ├── uart_top.v
│   ├── baud_gen.v
│   ├── uart_tx.v
│   └── uart_rx.v
│
├── tb/
│   └── uart_tb.v
│
├── simulation/
│   └── uart_loopback_waveform.png
│
└── README.md
```

## Tools

- Verilog HDL
- ModelSim
- GitHub
