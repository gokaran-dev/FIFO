# Synchronous and Asynchronous FIFO in Verilog

---

## 📚 Table of Contents
- [Overview](#overview)
- [Synchronous FIFO](#synchronous-fifo)
  - [Design Description](#design-description-sync)
  - [Waveform](#waveform-sync)
  - [Synthesized Schematic](#synthesized-schematic-sync)
- [Asynchronous FIFO](#asynchronous-fifo)
  - [Design Description](#design-description-async)
  - [Waveform](#waveform-async)
  - [Synthesized Schematic](#synthesized-schematic-async)
- [Testbench Strategy](#testbench-strategy)
- [Simulation and Synthesis Tools](#simulation-and-synthesis-tools)
- [How to Run](#how-to-run)
- [Author](#author)

---

## 🧠 Overview

This project demonstrates the design and verification of two types of FIFOs in Verilog:
- A Synchronous FIFO using a single clock domain
- An Asynchronous FIFO handling two different clock domains

Each design is fully parameterized for:
- Data Width
- FIFO Depth

---

### 🧠 Design Description (Synchronous FIFO) <a name="design-description-sync"></a>

The **Synchronous FIFO** operates entirely within a single clock domain and uses a circular buffer structure. It consists of a memory array, two pointers (`read_ptr` and `write_ptr`), and a **counter** that tracks how many data entries are currently stored in the FIFO.

The **counter** is central to managing FIFO status:
- It increments on a valid write operation.
- It decrements on a valid read operation.
- It remains unchanged when both operations happen simultaneously or when neither is valid.

This logic ensures the FIFO never overflows or underflows, while enabling concurrent read/write support when the FIFO is neither full nor empty.

#### Operation Encoding

| `write_en` | `fifo_full` | `read_en` | `fifo_empty` | Vector | Interpretation                             |
|------------|-------------|-----------|--------------|--------|--------------------------------------------|
| 1          | 0           | 0         | X            | 2'b10  | Write only (counter increments)            |
| 0          | X           | 1         | 0            | 2'b01  | Read only (counter decrements)             |
| 1          | 0           | 1         | 0            | 2'b11  | Write + Read (counter remains the same)    |
| Any        | 1           | Any       | 1            | 2'b00  | No valid operation (counter unchanged)     |

