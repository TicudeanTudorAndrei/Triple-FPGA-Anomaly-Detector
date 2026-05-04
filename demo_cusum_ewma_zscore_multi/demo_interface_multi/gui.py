import tkinter as tk
from tkinter import scrolledtext, ttk
import serial
import struct
import threading
import time
import random
import numpy as np

import matplotlib
matplotlib.use("TkAgg")
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D

# ======================
# MATPLOTLIB
# ======================
plt.style.use("dark_background")

# ======================
# CONFIG
# ======================
STREAMS = 4

DETECTORS = {
    "zscore": 0x01,
    "ewma":  0x02,
    "cusum": 0x04
}

app_started = False
start_button = None
zinit_button = None
zinit_blinking = False
stop_event = threading.Event()

ser = None

# ======================
# STATE
# ======================
state = {}
for d in DETECTORS:
    state[d] = {}
    for sid in range(STREAMS):
        state[d][sid] = {
            "sent": [],
            "recv": [],
            "anomalies": [],
            "predicted": [],
            "ground_truth": []
        }

# ======================
# GUI ROOT
# ======================
root = tk.Tk()
root.title("UART FPGA - Multi-Stream Viewer")
root.geometry("1200x850")

BG = "#121212"
FG = "#E0E0E0"
ENTRY_BG = "#1E1E1E"
LINE_COLOR = "#B0BEC5"

DEFAULT_FONT = ("Segoe UI", 11, "bold")
BUTTON_FONT = ("Segoe UI", 11, "bold")
LOG_FONT = ("Segoe UI", 10, "bold")

root.configure(bg=BG)

style = ttk.Style()
style.theme_use("default")

style.configure("TButton",
                background="#2A2A2A",
                foreground=FG,
                font=BUTTON_FONT,
                padding=6)

style.map("TButton",
          background=[("active", "#3A3A3A")])

style.configure("TLabel", background=BG, foreground=FG, font=DEFAULT_FONT)
style.configure("TRadiobutton", background=BG, foreground=FG, font=DEFAULT_FONT)

# ======================
# TOP CONTROLS
# ======================
top = tk.Frame(root, bg=BG)
top.pack(pady=5)

tk.Label(top, text="COM", bg=BG, fg=FG, font=DEFAULT_FONT).pack(side=tk.LEFT)

com_entry = tk.Entry(top, width=8, bg=ENTRY_BG, fg=FG,
                     insertbackground=FG, font=DEFAULT_FONT)
com_entry.insert(0, "COM5")
com_entry.pack(side=tk.LEFT, padx=5)

tk.Label(top, text="Baud", bg=BG, fg=FG, font=DEFAULT_FONT).pack(side=tk.LEFT)

baud_entry = tk.Entry(top, width=8, bg=ENTRY_BG, fg=FG,
                      insertbackground=FG, font=DEFAULT_FONT)
baud_entry.insert(0, "115200")
baud_entry.pack(side=tk.LEFT, padx=5)

# ======================
# PLOTS
# ======================
plot_frame = tk.Frame(root, bg=BG)
plot_frame.pack(fill=tk.BOTH, expand=True)

plots = {}

colors = {
    "zscore": "#00B0FF",
    "ewma":   "#39FF14",
    "cusum":  "#FF1744"
}

markers = {
    "zscore": "x",
    "ewma": "s",
    "cusum": "^"
}

for sid in range(STREAMS):
    sub = tk.Frame(plot_frame, bg=BG)
    sub.grid(row=sid // 2, column=sid % 2, sticky="nsew")

    fig, ax = plt.subplots(figsize=(5, 2.5))
    fig.patch.set_facecolor(BG)
    ax.set_facecolor("#1A1A1A")

    plots[sid] = {}

    for det in DETECTORS:
        line, = ax.plot([], [], lw=1, color=LINE_COLOR, alpha=0.7)

        if det == "zscore":
            scatter = ax.scatter([], [], marker=markers[det],
                                 color=colors[det], s=40, zorder=4)
        else:
            scatter = ax.scatter([], [], marker=markers[det],
                                 facecolors='none',
                                 edgecolors=colors[det],
                                 linewidths=1.5,
                                 s=50, zorder=3)

        plots[sid][det] = {
            "line": line,
            "scatter": scatter
        }

    ax.set_title(f"Stream {sid}", color=FG)
    ax.tick_params(colors=FG)
    ax.grid(True, color="#333333")
    
    legend_elements = [
        Line2D([0], [0],
           marker=markers["zscore"],
           color='none',
           label='ZSCORE',
           markerfacecolor=colors["zscore"],
           markeredgecolor=colors["zscore"],
           markersize=8),

        Line2D([0], [0],
           marker=markers["ewma"],
           color='none',
           label='EWMA',
           markerfacecolor='none',
           markeredgecolor=colors["ewma"],
           markersize=8),

        Line2D([0], [0],
           marker=markers["cusum"],
           color='none',
           label='CUSUM',
           markerfacecolor='none',
           markeredgecolor=colors["cusum"],
           markersize=8),
    ]

    ax.legend(handles=legend_elements,
          facecolor="#1E1E1E",
          edgecolor="#444444")

    canvas = FigureCanvasTkAgg(fig, master=sub)
    canvas.draw()
    canvas.get_tk_widget().pack(fill=tk.BOTH, expand=True)

    plots[sid]["ax"] = ax
    plots[sid]["canvas"] = canvas

plot_frame.rowconfigure((0, 1), weight=1)
plot_frame.columnconfigure((0, 1), weight=1)

def pulse_start_button():
    if app_started:
        return

    current = start_button.cget("bg")
    new_color = "#43A047" if current == "#2E7D32" else "#2E7D32"
    start_button.config(bg=new_color)

    root.after(600, pulse_start_button)

def blink_zinit_button():
    global zinit_blinking

    if not zinit_blinking:
        return

    current = zinit_button.cget("bg")

    new_color = "#FF7043" if current == "#D84315" else "#D84315"
    zinit_button.config(bg=new_color)

    root.after(500, blink_zinit_button)

# ======================
# LOG
# ======================
log_frame = tk.Frame(root, bg=BG)

output_textbox = scrolledtext.ScrolledText(
    log_frame,
    width=140,
    height=10,
    state=tk.DISABLED,
    bg="#1E1E1E",
    fg=FG,
    insertbackground=FG,
    font=LOG_FONT
)
output_textbox.pack(fill=tk.X)

def log(msg):
    output_textbox.config(state=tk.NORMAL)
    output_textbox.insert(tk.END, msg + "\n")
    output_textbox.yview(tk.END)
    output_textbox.config(state=tk.DISABLED)

# ======================
# SERIAL + LOGIC
# ======================

def send_value(value):
    if not ser:
        return

    det = selected_detector.get()
    sid = selected_stream.get()
    flag = DETECTORS[det]

    if det == "cusum":
        scaled_val = int(round(value * 100))
        packet = struct.pack(">BHiB", 0, sid, scaled_val, flag)
        state[det][sid]["sent"].append(value)
        log(f"TX [{det.upper()}][S{sid}] value={value:.2f}")
    else:
        packet = struct.pack(">BHfB", 0, sid, float(value), flag)
        state[det][sid]["sent"].append(float(value))
        log(f"TX [{det.upper()}][S{sid}] value={float(value):.3f}")

    ser.write(packet)


def on_send():
    try:
        v = float(input_entry.get())
        send_value(v)
    except ValueError:
        log("Invalid input")
    input_entry.delete(0, tk.END)


def send_rand_sequence():
    stop_event.clear()
    threading.Thread(target=_rand_unified_worker, daemon=True).start()


def _generate_sequence():
    seq = []
    for _ in range(300):
        v = random.gauss(1.5, 0.5)
        if random.random() < 0.03:
            v += random.choice([-1, 1]) * random.uniform(15, 30)
        v = round(v, 2)
        seq.append(v)
    return seq

def send_zscore_init_with_loading():
    global zinit_blinking

    zinit_blinking = False
    zinit_button.config(bg="#BF360C")

    loading_popup = show_loading_popup()

    def worker():
        _zscore_init_worker()

        root.after(0, loading_popup.destroy)
        root.after(0, hide_zinit_button)

    threading.Thread(target=worker, daemon=True).start()

def _rand_unified_worker():
    stream_sequences = [_generate_sequence() for _ in range(STREAMS)]
    detectors_order = ["zscore", "ewma", "cusum"]

    for i in range(300):
        if stop_event.is_set():
            log("Random transmission stopped")
            break

        for sid in range(STREAMS):
            if stop_event.is_set():
                log("Random transmission stopped")
                break

            value = stream_sequences[sid][i]

            for det in detectors_order:
                if stop_event.is_set():
                    log("Random transmission stopped")
                    break

                selected_stream.set(sid)
                selected_detector.set(det)
                send_value(value)
                time.sleep(0.2)

def _rand_stream_batch_worker():
    stream_sequences = [_generate_sequence() for _ in range(STREAMS)]
    detectors_order = ["zscore", "ewma", "cusum"]

    for sid in range(STREAMS):
        if stop_event.is_set():
            log("Batch transmission stopped")
            return

        selected_stream.set(sid)

        seq = stream_sequences[sid]

        for i in range(300):
            if stop_event.is_set():
                log("Batch transmission stopped")
                return

            value = seq[i]

            for det in detectors_order:
                if stop_event.is_set():
                    log("Batch transmission stopped")
                    return

                selected_detector.set(det)
                send_value(value)
                time.sleep(0.2)

def receive_value():
    if ser and ser.in_waiting >= 5:
        frame = ser.read(5)
        unused, sid, flags = struct.unpack(">HHB", frame)
        anomaly = (flags & 0x80) >> 7

        if flags & 0x01:
            det = "zscore"
        elif flags & 0x02:
            det = "ewma"
        elif flags & 0x04:
            det = "cusum"
        else:
            root.after(10, receive_value)
            return

        if sid >= STREAMS:
            root.after(10, receive_value)
            return

        s = state[det][sid]
        idx = len(s["predicted"])

        if idx < len(s["sent"]):
            value = s["sent"][idx]
            
            s["recv"].append(value)
            s["predicted"].append(anomaly)

            if anomaly:
                s["anomalies"].append((idx, value))

            update_plot(det, sid)
            log(f"RX [{det.upper()}][S{sid}] value={value} anomaly={anomaly}")

    root.after(10, receive_value)


def update_plot(det, sid):
    ax = plots[sid]["ax"]

    has_data = False
    all_values = []

    for d in DETECTORS:
        s = state[d][sid]
        p = plots[sid][d]

        if not s["recv"]:
            continue

        has_data = True

        x_vals = list(range(len(s["recv"])))
        y_vals = s["recv"]

        p["line"].set_data(x_vals, y_vals)
        all_values.extend(y_vals)

        if len(s["anomalies"]) > 0:
            arr = np.array(s["anomalies"], dtype=float)
            p["scatter"].set_offsets(arr)
        else:
            p["scatter"].set_offsets(np.empty((0, 2)))

    if not has_data:
        return

    max_len = max(len(state[d][sid]["recv"]) for d in DETECTORS)
    ax.set_xlim(0, max(50, max_len))

    ymin = min(all_values)
    ymax = max(all_values)
    ax.set_ylim(ymin - 5, ymax + 5)

    plots[sid]["canvas"].draw_idle()


def start_serial():
    global ser
    try:
        ser = serial.Serial(com_entry.get(), int(baud_entry.get()), timeout=0)
        log("Serial started")
        root.after(10, receive_value)
    except Exception as e:
        log(f"Serial error: {e}")


def stop_serial():
    global ser
    stop_event.set()

    if ser:
        ser.close()
        ser = None
        log("Serial stopped")


def send_zscore_init_with_loading():
    loading_popup = show_loading_popup()

    def worker():
        _zscore_init_worker()

        root.after(0, loading_popup.destroy)
        root.after(0, hide_zinit_button)

    threading.Thread(target=worker, daemon=True).start()

def send_rand_stream_batch():
    stop_event.clear()
    threading.Thread(target=_rand_stream_batch_worker, daemon=True).start()

def _zscore_init_worker():
    seq = (
        [1.5]*20 + [1.3]*20 + [1.4]*20 +
        [1.2]*4 + [1.1]*10 + [1.2]*10 +
        [1.4]*10 + [1.3]*10 + [1.6]*10 +
        [1.7]*10 + [1.1]*4
    )

    for v in seq:
        for sid in range(STREAMS):
            packet = struct.pack(">BHfB", 0, sid, float(v), DETECTORS["zscore"])
            ser.write(packet)
            time.sleep(0.05)


def show_loading_popup():
    popup = tk.Toplevel(root)
    popup.title("Loading...")
    popup.configure(bg="#1F1F1F")

    width = 320
    height = 140

    root.update_idletasks()

    root_x = root.winfo_x()
    root_y = root.winfo_y()
    root_width = root.winfo_width()
    root_height = root.winfo_height()

    x = root_x + (root_width // 2) - (width // 2)
    y = root_y + (root_height // 2) - (height // 2)

    popup.geometry(f"{width}x{height}+{x}+{y}")

    frame = tk.Frame(popup, bg="#2A2A2A", padx=20, pady=20)
    frame.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)

    popup_label = tk.Label(
        frame,
        text="⚙ Running Z-Init...\nPlease wait",
        bg="#2A2A2A",
        fg="white",
        font=("Segoe UI", 12, "bold"),
        justify="center"
    )
    popup_label.pack(expand=True)

    popup.transient(root)
    popup.grab_set()

    return popup

# ======================
# INPUT UI
# ======================
input_frame = tk.Frame(root, bg=BG)
input_frame.pack(pady=5)

tk.Label(input_frame, text="Value", bg=BG, fg=FG, font=DEFAULT_FONT).pack(side=tk.LEFT)

input_entry = tk.Entry(input_frame, width=10,
                       bg=ENTRY_BG, fg=FG,
                       insertbackground=FG,
                       font=DEFAULT_FONT)
input_entry.pack(side=tk.LEFT, padx=5)

selected_detector = tk.StringVar(value="zscore")
for d in DETECTORS:
    tk.Radiobutton(input_frame, text=d.upper(),
                   variable=selected_detector, value=d,
                   bg=BG, fg=FG, selectcolor="#333333",
                   font=DEFAULT_FONT).pack(side=tk.LEFT)

selected_stream = tk.IntVar(value=0)
for sid in range(STREAMS):
    tk.Radiobutton(input_frame, text=f"S{sid}",
                   variable=selected_stream, value=sid,
                   bg=BG, fg=FG, selectcolor="#333333",
                   font=DEFAULT_FONT).pack(side=tk.LEFT)

def on_start_click():
    global app_started, zinit_blinking

    app_started = True

    start_button.config(bg="#1B5E20")

    zinit_button.config(state="normal", bg="#D84315")

    # start blinking Z-Init
    zinit_blinking = True
    blink_zinit_button()

    start_serial()

def toggle_log():
    if log_frame.winfo_ismapped():
        log_frame.pack_forget()
        toggle_log_button.config(text="Show Log")
    else:
        log_frame.pack(fill=tk.X, pady=5)
        toggle_log_button.config(text="Hide Log")

start_button = tk.Button(top, text="Start", font=BUTTON_FONT,
          bg="#2E7D32", fg="white",
          activebackground="#1B5E20",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=lambda: on_start_click())
start_button.pack(side=tk.LEFT, padx=5)

tk.Button(top, text="Stop", font=BUTTON_FONT,
          bg="#C62828", fg="white",
          activebackground="#8E0000",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=stop_serial).pack(side=tk.LEFT, padx=5)

tk.Button(top, text="Quit", font=BUTTON_FONT,
          bg="#424242", fg="white",
          activebackground="#616161",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=root.quit).pack(side=tk.LEFT, padx=5)

tk.Button(input_frame, text="Send", font=BUTTON_FONT,
          bg="#2A2A2A", fg=FG,
          activebackground="#3A3A3A",
          relief="flat",
          padx=10, pady=6,
          command=on_send).pack(side=tk.LEFT, padx=5)

tk.Button(input_frame, text="Random Circular", font=BUTTON_FONT,
          bg="#1565C0", fg="white",
          activebackground="#0D47A1",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=send_rand_sequence).pack(side=tk.LEFT, padx=5)

tk.Button(input_frame, text="Random Batch", font=BUTTON_FONT,
          bg="#6A1B9A", fg="white",
          activebackground="#4A148C",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=send_rand_stream_batch).pack(side=tk.LEFT, padx=5)

toggle_log_button = tk.Button(top, text="Hide Log", font=BUTTON_FONT,
          bg="#37474F", fg="white",
          activebackground="#263238",
          relief="flat",
          padx=10, pady=6,
          command=toggle_log)
toggle_log_button.pack(side=tk.LEFT, padx=5)

def hide_zinit_button():
    zinit_button.pack_forget()

zinit_button = tk.Button(input_frame, text="Z-Init", font=BUTTON_FONT,
                         bg="#555555", fg="white",
                         activebackground="#BF360C",
                         activeforeground="white",
                         relief="flat",
                         padx=12, pady=6,
                         state="disabled",
                         command=lambda: send_zscore_init_with_loading())
zinit_button.pack(side=tk.LEFT, padx=5)

# ======================
# MAIN
# ======================
top.pack(pady=5)
plot_frame.pack(fill=tk.BOTH, expand=True)
log_frame.pack(fill=tk.X, pady=5)
input_frame.pack(pady=5)

pulse_start_button()
root.mainloop()