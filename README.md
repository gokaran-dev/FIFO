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

## Overview

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

This logic ensures the FIFO never overflows or underflows, while enabling *potential* concurrent read/write support when the FIFO is neither full nor empty.

#### Operation Encoding

| `write_en` | `fifo_full` | `read_en` | `fifo_empty` | Vector | Interpretation                             |
|------------|-------------|-----------|--------------|--------|--------------------------------------------|
| 1          | 0           | 0         | X            | 2'b10  | Write only (counter increments)            |
| 0          | X           | 1         | 0            | 2'b01  | Read only (counter decrements)             |
| 1          | 0           | 1         | 0            | 2'b11  | Write + Read (counter remains the same)    |
| Any        | 1           | Any       | 1            | 2'b00  | No valid operation (counter unchanged)     |

---

### Waveform <a name="waveform-sync"></a>

Below is the simulation waveform for the Synchronous FIFO. It demonstrates:
- Sequential writes until the FIFO is full
- Valid read operations after writes
- Correct operation of the `fifo_full` and `fifo_empty` flags

![Synchronous FIFO Waveform](results/sync_fifo_output.png)

---

### Synthesized Schematic <a name="synthesized-schematic-sync"></a>

This schematic is generated after synthesis using Vivado, showcasing the overall structure of the synchronous FIFO logic.

![Synchronous FIFO Synthesized Schematic](results/synthesized_schematic_sync.png)

---

### 🧠 Design Description (Asynchronous FIFO) <a name="design-description-async"></a>

The **Asynchronous FIFO** is designed to allow seamless data transfer between two **independent clock domains.** 

Unlike a synchronous FIFO that shares a single clock, the asynchronous FIFO accepts `write_clk` and `read_clk` separately. This makes it **safe and reliable for clock domain crossing (CDC)**, eliminating the risk of metastability and ensuring data integrity.

#### Key Benefits
- Enables **simultaneous read and write operations**, each governed by its own clock.
- Essential in **clock-domain-crossing applications**, such as communication between processor and peripheral blocks running at different speeds.
- Provides **full** and **empty** flags through synchronized comparisons of pointer values across domains.

---

#### Design Architecture

![Design Architecture](results/async_fifo_modules.png)

To manage the complexities of asynchronous operation, the design is modularized into several functional blocks:

1. **Async_FIFO(Top Module)**  
   - A register array used as shared memory for data storage.  
   - Can be accessed concurrently for reading and writing.
   - Responsible for wiring all the submodules.  

2. **Write Controller**  
   - Operates in the `write_clk` domain.  
   - Manages `write_address`, detects FIFO full condition, and controls memory write access.

3. **Read Controller**  
   - Operates in the `read_clk` domain.  
   - Manages `read_address`, detects FIFO empty condition, and handles memory reads.

4. **Gray Code Encoders/Decoders**  
   - Both read and write pointers are **converted to Gray code** before crossing domains.  
   - Gray coding ensures that only one bit changes at a time, minimizing the chance of metastability.

5. **Synchronizers**  
   - Used to safely transfer the Gray-coded pointers between clock domains.  
   - Implemented as **two-stage flip-flop synchronizers** to ensure timing closure and CDC safety.



