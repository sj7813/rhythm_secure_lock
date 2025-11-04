<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## Project: Rhythm-Based Secure Access Controller

### Overview
This project implements a hardware rhythm-based authentication system
that requires the user to input both the correct password and match the LED rhythm sequence.  
Unlike conventional password systems that verify only numeric input, this design adds a timing and pattern dimension
— the user must press each key when a specific LED is illuminated according to a cyclic rhythm pattern.  
Even when all digits are entered correctly, the system does not immediately unlock;
 a final confirmation input is required to activate the unlock signal, enhancing security.

---

### How It Works

#### 1. LED Rhythm Sequencer
- The system drives three LEDs labeled `[0]`, `[1]`, and `[2]`.  
- They blink in a repeating pattern that cycles as follows:  
[0] -> [1] -> [2] -> [1] -> [0] -> [1] -> [2] -> [1] -> [0] ->.. 

#### 2. Password and LED Mapping
A 5-digit password (e.g., 12345) is stored along with a corresponding LED activation sequence (e.g., [2], [1], [2], [0], [1]).  
- To be recognized as valid, each number must be entered exactly when its corresponding LED is ON:
- `1` must be pressed during LED `[2]`  
- `2` during LED `[1]`  
- `3` during LED `[2]`  
- `4` during LED `[0]`  
- `5` during LED `[1]`

If even one digit is entered at the wrong LED timing, the input sequence resets and the user must restart.

#### 3️⃣. Timing Window
- Each LED blink corresponds to one **beat window**, defined by ±TOL\_MS (e.g., ±60 ms).  
- Button inputs (`btn_pulse`) are only valid inside this window.  
- This ensures rhythm accuracy — pressing slightly early or late invalidates the attempt.

#### 4. Progress and Feedback
- Every correctly timed input advances a **progress counter**, and the system provides real-time visual feedback through LEDs:
- Beat LED: indicates current rhythm step  
- Window LED: ON during valid timing window  
- Error LED: blinks briefly on mistake  
- Unlock LED: lights when all steps are completed and confirmed  

#### 5. Final Confirmation Unlock
- After all digits are entered correctly (sequence complete), the system enters a“ready-to-unlock" state.  
- It remains locked until a final confirmation button press is detected.  
- Once confirmed, the `unlocked` signal goes HIGH and the `led_unlocked` remains ON.

---

### I/O Summary

| Signal | Direction | Description |
|:--------|:-----------|:-------------|
| `clk` | Input | System clock |
| `rstn` | Input | Active-low reset |
| `btn_raw` | Input | Main input button (debounced internally) |
| `confirm_btn` | Input | Confirmation input for final unlock |
| `sw_code[3:0]` | Input | 4-bit numeric input (0–9) |
| `led[2:0]` | Output | LED rhythm indicators (0, 1, 2) |
| `led_window` | Output | Timing window indicator |
| `led_error` | Output | Blinks on error or invalid timing |
| `led_unlocked` | Output | Lights when system unlocks |
| `cfg_we`, `cfg_addr[3:0]`, `cfg_wdata[15:0]` | Input | Configuration interface for password digits, LED sequence, BPM, tolerance, and blink speed |

---

### Example Operation

1. System initializes (BPM = 120, tolerance = ±60 ms, password = 12345, LED sequence = [2,1,2,0,1]).  
2. LEDs start cycling: `[0] → [1] → [2] → [1] → [0] ...`  
3. User watches the rhythm and presses:
 - `1` when LED `[2]` is ON  
 - `2` when LED `[1]` is ON  
 - `3` when LED `[2]` is ON  
 - `4` when LED `[0]` is ON  
 - `5` when LED `[1]` is ON  
4. If all are entered at correct beats → system waits in “ready” state.  
5. User presses **confirm button** → system unlocks and `led_unlocked` lights ON.

---

### Simulation
- Simulated with **Icarus Verilog (iverilog)** and visualized in **GTKWave**.  
- Waveforms confirm:
- LED sequence generation (0–1–2–1)  
- Correct and incorrect timing responses  
- Reset and progress logic  
- Final confirmation unlock transition

---

### Applications
- Secure access control (doors, safes, or equipment) requiring dual verification (data + rhythm)  
- Behavioral authentication systems (timing-based human interaction)  
- Educational demonstration of FSMs, timing verification, and user feedback design  
- Gamified authentication or rhythm-based input interfaces

---

### Summary
The **Rhythm-Based Secure Access Controller** merges hardware design, timing control, and behavioral security into a single Verilog system.  
By combining password correctness with rhythmic precision and LED guidance, this project demonstrates an innovative form of **time-dependent, user-interactive authentication** suitable for both educational and industrial applications.

---

*Designed by sj7813 — Rhythm Secure Lock Project (2025)*
