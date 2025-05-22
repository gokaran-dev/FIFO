# Synchronous and Asynchronous FIFO in Verilog

A Verilog-based implementation of parameterized Synchronous and Asynchronous FIFO (First In, First Out) memory buffers, suitable for use in various digital systems. Includes waveform verification and synthesized schematics.

---

## 📚 Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Project Structure](#project-structure)
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

## ✨ Features

- Fully parameterized
- Synchronous and asynchronous support
- Overflow and underflow protection
- Proper Gray code pointer synchronization in asynchronous FIFO
- Comprehensive testbenches
- Synthesizable and simulation-ready
