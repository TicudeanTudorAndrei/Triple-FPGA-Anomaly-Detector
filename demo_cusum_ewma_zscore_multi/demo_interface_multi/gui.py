import tkinter as tk
from tkinter import scrolledtext, ttk, filedialog
import csv
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


# MATPLOTLIB

plt.style.use("dark_background")


# CONFIG

STREAMS = 4

DETECTORS = {
    "zscore": 0x01,
    "ewma":  0x02,
    "cusum": 0x04
}

app_started = False
start_button = None
stop_event = threading.Event()

ser = None


# STATE

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


# GUI ROOT

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


# TOP CONTROLS

top = tk.Frame(root, bg=BG)
top.pack(pady=5)

tk.Label(top, text="COM", bg=BG, fg=FG, font=DEFAULT_FONT).pack(side=tk.LEFT)

com_entry = tk.Entry(top, width=8, bg=ENTRY_BG, fg=FG,
                     insertbackground=FG, font=DEFAULT_FONT)
com_entry.insert(0, "COM8")
com_entry.pack(side=tk.LEFT, padx=5)

tk.Label(top, text="Baud", bg=BG, fg=FG, font=DEFAULT_FONT).pack(side=tk.LEFT)

baud_entry = tk.Entry(top, width=8, bg=ENTRY_BG, fg=FG,
                      insertbackground=FG, font=DEFAULT_FONT)
baud_entry.insert(0, "115200")
baud_entry.pack(side=tk.LEFT, padx=5)


# PLOTS

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

# LOG

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


# SERIAL + LOGIC


def send_value(value):
    if not ser:
        return

    det = selected_detector.get()
    sid = selected_stream.get()
    flag = DETECTORS[det]

    if det == "cusum":
        if value == int(value):
            scaled_val = int(value)
        else:
            scaled_val = int(round(value * 100))
        packet = struct.pack(">BHiB", 0, sid, scaled_val, flag)
        state[det][sid]["sent"].append(value)
        log(f"TX [{det.upper()}][S{sid}] value={value:.2f} (int={scaled_val})")
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
    set_stream_titles([f"Stream {i}" for i in range(STREAMS)])
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

zscore_csv_init = {
    0: ([8.38]*3 + [8.37] + [8.38] + [8.36]*17 + [8.35] + [8.34]*8 + [8.33]*2 + [8.34] + [8.33]*4 +
        [8.34]*5 + [8.36] + [8.34]*2 + [8.35]*4 + [8.36] + [8.35] + [8.36]*6 + [8.37]*2 + [8.38]*4 +
        [8.39] + [8.4]*12 + [8.39]*5 + [8.38] + [8.39]*3 + [8.38]*6 + [8.39]*3 + [8.4] + [8.39]*18 +
        [8.38] + [8.39] + [8.38]*2 + [8.39] + [8.38] + [8.39] + [8.38] + [8.39] + [8.38]*2 + [8.39] + [8.38]*2),  # pH
    1: [755.0]*47 + [756.0]*2 + [755.0]*79,  # Redox
    2: ([232.0]*6 + [235.0] + [232.0]*2 + [235.0] + [232.0]*5 + [235.0] + [232.0] + [235.0] +
        [232.0]*2 + [235.0]*8 + [232.0]*3 + [235.0]*97),  # Leit
    3: ([0.11] + [0.111] + [0.113] + [0.111]*2 + [0.114] + [0.111]*2 + [0.113]*2 + [0.114]*2 +
        [0.113] + [0.111]*7 + [0.113] + [0.111] + [0.113]*2 + [0.11] + [0.111]*2 + [0.113] +
        [0.112] + [0.114]*2 + [0.113] + [0.114] + [0.113] + [0.114]*2 + [0.117] + [0.114] +
        [0.116]*2 + [0.117]*2 + [0.118] + [0.117] + [0.118] + [0.117] + [0.118]*3 + [0.117] +
        [0.118] + [0.117] + [0.118]*2 + [0.117]*2 + [0.116] + [0.117]*2 + [0.114]*4 + [0.113] +
        [0.114] + [0.113] + [0.111] + [0.113]*4 + [0.111] + [0.113] + [0.11] + [0.111]*2 +
        [0.113]*5 + [0.114]*7 + [0.116]*2 + [0.114]*2 + [0.116] + [0.114] + [0.116]*2 +
        [0.114]*10 + [0.116] + [0.114] + [0.113]*3 + [0.114]*2 + [0.113]*2 + [0.111] +
        [0.114] + [0.113] + [0.114] + [0.113]*3 + [0.114] + [0.113] + [0.114]*4),  # Cl_2
}

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

CSV_STREAM_NAMES = ["pH", "Redox", "Leit", "Cl_2"]

def set_stream_titles(names):
    for sid in range(STREAMS):
        plots[sid]["ax"].set_title(names[sid], color=FG)
        plots[sid]["canvas"].draw_idle()


def _csv_worker(rows):
    # stream 0=pH, 1=Redox, 2=Leit, 3=Cl_2
    detectors_order = ["zscore", "ewma", "cusum"]
    stream_values = [None] * STREAMS

    for row in rows:
        if stop_event.is_set():
            log("CSV transmission stopped")
            return

        ph, redox, leit, cl2, gt = row
        stream_values[0] = ph
        stream_values[1] = redox
        stream_values[2] = leit
        stream_values[3] = cl2

        for sid in range(STREAMS):
            if stop_event.is_set():
                log("CSV transmission stopped")
                return

            value = stream_values[sid]

            for det in detectors_order:
                if stop_event.is_set():
                    log("CSV transmission stopped")
                    return

                selected_stream.set(sid)
                selected_detector.set(det)
                send_value(value)
                state[det][sid]["ground_truth"].append(gt)
                time.sleep(0.2)


def send_csv_data():
    filepath = filedialog.askopenfilename(
        title="Select CSV file",
        filetypes=[("CSV files", "*.csv"), ("All files", "*.*")]
    )
    if not filepath:
        return

    rows = []
    try:
        with open(filepath, newline='', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            skipped = 0
            for row in reader:
                try:
                    ph    = float(row["pH"])
                    redox = float(row["Redox"])
                    leit  = float(row["Leit"])
                    cl2   = float(row["Cl_2"])
                    gt    = row["EVENT"].strip().upper() == "TRUE"
                    rows.append((ph, redox, leit, cl2, gt))
                except (ValueError, KeyError):
                    skipped += 1
    except Exception as e:
        log(f"CSV error: {e}")
        return
    if skipped:
        log(f"CSV: skipped {skipped} rows with missing/invalid values")

    log(f"CSV loaded: {len(rows)} rows from {filepath.split('/')[-1]}")
    set_stream_titles(CSV_STREAM_NAMES)
    stop_event.clear()
    threading.Thread(target=_csv_worker, args=(rows,), daemon=True).start()


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


# Config presets sent to FPGA at startup
# Param IDs match HDL: 1=CUSUM_THR, 2=CUSUM_DRIFT, 3=ALPHA, 4=P, 5=S0
# Packet: 0x01 | param_id(1B) | stream_id(1B) | value(4B) | 0x00  = 8 bytes
# cusum_thr and cusum_drift are signed ints (value * 100 integer space)
# alpha, p, s0 are IEEE 754 floats
# Each value is a list of STREAMS entries, one per stream [pH, Redox, Leit, Cl_2]
PRESETS = {
    "random": {
        "cusum_thr":   [struct.pack(">i", 400)]   * STREAMS,
        "cusum_drift": [struct.pack(">i", 100)]   * STREAMS,
        "alpha":       [struct.pack(">f", 0.01)]  * STREAMS,
        "p":           [struct.pack(">f", 2.5)]   * STREAMS,
        "s0":          [struct.pack(">f", 1.5)]   * STREAMS,
    },
    "csv": {
        "cusum_thr":   [struct.pack(">i",  10), struct.pack(">i",  50), struct.pack(">i",  20), struct.pack(">i",   5)],
        "cusum_drift": [struct.pack(">i",   5), struct.pack(">i",  15), struct.pack(">i",   8), struct.pack(">i",   2)],
        "alpha":       [struct.pack(">f", 0.01)] * STREAMS,
        "p":           [struct.pack(">f", 0.3), struct.pack(">f", 0.15),
                        struct.pack(">f", 0.08), struct.pack(">f", 0.3)],
        "s0":          [struct.pack(">f", 8.37187), struct.pack(">f", 755.01562),
                        struct.pack(">f", 234.55469), struct.pack(">f", 0.11382)],
    },
}
PARAM_IDS = {"cusum_thr": 1, "cusum_drift": 2, "alpha": 3, "p": 4, "s0": 5}

def _auto_zinit_worker(preset_name, popup, ewma_s0_vals=None, ewma_alpha_bytes=None):
    time.sleep(1)

    # EWMA warmup: the feedback FIFO is pre-seeded at reset with the HDL default
    # S0=1.5, not the UART-configured value. With alpha=0.01 it takes ~500 samples
    # to converge. Fix: temporarily set alpha=0.5, send 10 warmup packets per stream
    # at the correct S0 value (0.5^10 < 0.001 residual error), then restore alpha.
    if ewma_s0_vals is not None and ewma_alpha_bytes is not None:
        log("EWMA warmup: setting alpha=0.5 for fast S0 convergence")
        alpha_warmup = struct.pack(">f", 0.5)
        for sid in range(STREAMS):
            ser.write(struct.pack(">BBB4sB", 0x01, PARAM_IDS["alpha"], sid, alpha_warmup, 0x00))
            time.sleep(0.02)
        time.sleep(0.2)
        log("EWMA warmup: sending 10 warmup samples per stream")
        for _ in range(10):
            for sid in range(STREAMS):
                ser.write(struct.pack(">BHfB", 0, sid, ewma_s0_vals[sid], DETECTORS["ewma"]))
                time.sleep(0.1)
        time.sleep(0.2)
        log("EWMA warmup: restoring alpha")
        for sid in range(STREAMS):
            ser.write(struct.pack(">BBB4sB", 0x01, PARAM_IDS["alpha"], sid, ewma_alpha_bytes[sid], 0x00))
            time.sleep(0.02)
        time.sleep(0.3)
        log("EWMA warmup complete")

    if preset_name == "csv":
        log("Z-Init: sending CSV hardcoded sequence")
        for i in range(len(zscore_csv_init[0])):
            for sid in range(STREAMS):
                packet = struct.pack(">BHfB", 0, sid, float(zscore_csv_init[sid][i]), DETECTORS["zscore"])
                ser.write(packet)
                time.sleep(0.1)
    else:
        log("Z-Init: sending random sequence")
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
                time.sleep(0.1)
    log("Z-Init complete")
    root.after(0, popup.destroy)

def start_serial():
    global ser, app_started
    try:
        ser = serial.Serial(com_entry.get(), int(baud_entry.get()), timeout=0)
        log("Serial started")
        root.after(10, receive_value)
    except Exception as e:
        log(f"Serial error: {e}")
        return

    # Config dialog: per-stream grid of editable fields
    dialog = tk.Toplevel(root)
    dialog.title("Detector configuration")
    dialog.configure(bg="#1F1F1F")
    dialog.resizable(False, False)
    dialog.transient(root)
    dialog.grab_set()

    root.update_idletasks()
    dw, dh = 680, 360
    x = root.winfo_x() + root.winfo_width() // 2 - dw // 2
    y = root.winfo_y() + root.winfo_height() // 2 - dh // 2
    dialog.geometry(f"{dw}x{dh}+{x}+{y}")

    DLABEL = {"bg": "#1F1F1F", "fg": FG, "font": DEFAULT_FONT, "anchor": "w"}
    DENTRY = {"bg": "#2A2A2A", "fg": FG, "insertbackground": FG,
              "font": DEFAULT_FONT, "relief": "flat", "width": 10}

    PARAMS = ["cusum_thr", "cusum_drift", "alpha", "p", "s0"]
    PARAM_LABELS = ["CUSUM Thr", "CUSUM Drift", "EWMA Alpha", "EWMA P", "EWMA S0"]

    # vars[param][stream] = StringVar
    vars_ = {}
    for param in PARAMS:
        vars_[param] = [tk.StringVar() for _ in range(STREAMS)]

    def _decode_val(key, val_bytes):
        if key in ("cusum_thr", "cusum_drift"):
            return str(struct.unpack(">i", val_bytes)[0])
        else:
            return str(round(struct.unpack(">f", val_bytes)[0], 6))

    def fill(preset_name):
        p = PRESETS[preset_name]
        for param in PARAMS:
            for sid in range(STREAMS):
                vars_[param][sid].set(_decode_val(param, p[param][sid]))

    # Preset buttons row
    prow = tk.Frame(dialog, bg="#1F1F1F")
    prow.pack(fill=tk.X, padx=16, pady=(12, 6))
    tk.Label(prow, text="Preset:", **DLABEL).pack(side=tk.LEFT)
    tk.Button(prow, text="Random", font=BUTTON_FONT, bg="#1565C0", fg="white",
              relief="flat", padx=8, pady=3,
              command=lambda: fill("random")).pack(side=tk.LEFT, padx=(8, 4))
    tk.Button(prow, text="CSV", font=BUTTON_FONT, bg="#00695C", fg="white",
              relief="flat", padx=8, pady=3,
              command=lambda: fill("csv")).pack(side=tk.LEFT, padx=4)

    tk.Frame(dialog, bg="#333333", height=1).pack(fill=tk.X, padx=16, pady=6)

    # Grid: row=param, col=stream
    grid = tk.Frame(dialog, bg="#1F1F1F")
    grid.pack(fill=tk.X, padx=16)

    # Header row
    tk.Label(grid, text="", bg="#1F1F1F", fg=FG, font=DEFAULT_FONT, width=12).grid(row=0, column=0)
    for sid, name in enumerate(CSV_STREAM_NAMES):
        tk.Label(grid, text=f"St.{sid} / {name}", bg="#1F1F1F", fg="#90CAF9",
                 font=DEFAULT_FONT, width=10).grid(row=0, column=sid+1, padx=4)

    for row_idx, (param, label) in enumerate(zip(PARAMS, PARAM_LABELS), start=1):
        tk.Label(grid, text=label+":", **DLABEL, width=12).grid(row=row_idx, column=0, sticky="w", pady=3)
        for sid in range(STREAMS):
            tk.Entry(grid, textvariable=vars_[param][sid], **DENTRY).grid(
                row=row_idx, column=sid+1, padx=4, pady=3)

    # Pre-fill with random preset
    fill("random")

    confirmed = [False]

    def on_send():
        confirmed[0] = True
        dialog.destroy()

    tk.Frame(dialog, bg="#333333", height=1).pack(fill=tk.X, padx=16, pady=8)
    tk.Button(dialog, text="Send & Start", font=BUTTON_FONT,
              bg="#2E7D32", fg="white", activebackground="#1B5E20",
              activeforeground="white", relief="flat", padx=14, pady=7,
              command=on_send).pack(pady=(0, 12))

    root.wait_window(dialog)

    if not confirmed[0]:
        return

    # Build config and send — one packet per (param, stream) pair
    # Packet: 0x01 | param_id(1B) | stream_id(1B) | value(4B) | 0x00
    try:
        for param in PARAMS:
            pid = PARAM_IDS[param]
            for sid in range(STREAMS):
                raw = vars_[param][sid].get()
                if param in ("cusum_thr", "cusum_drift"):
                    val_bytes = struct.pack(">i", int(raw))
                else:
                    val_bytes = struct.pack(">f", float(raw))
                ser.write(struct.pack(">BBB4sB", 0x01, pid, sid, val_bytes, 0x00))
                time.sleep(0.02)
    except (ValueError, struct.error) as e:
        log(f"Config error: {e}")
        return

    ser.write(struct.pack(">BHiB", 0xFF, 0, 0, 0))
    log("Config sent")

    # Z-Init source: csv if s0 for stream 0 matches the csv preset value, else random
    csv_s0_0 = str(round(struct.unpack(">f", PRESETS["csv"]["s0"][0])[0], 6))
    zinit_src = "csv" if vars_["s0"][0].get() == csv_s0_0 else "random"

    # Collect the configured S0 floats and alpha bytes for EWMA warmup
    ewma_s0_vals = [float(vars_["s0"][sid].get()) for sid in range(STREAMS)]
    ewma_alpha_bytes = [struct.pack(">f", float(vars_["alpha"][sid].get())) for sid in range(STREAMS)]

    popup = tk.Toplevel(root)
    popup.title("Z-Init")
    popup.configure(bg="#1F1F1F")
    popup.resizable(False, False)
    popup.transient(root)
    popup.grab_set()
    root.update_idletasks()
    pw, ph = 300, 100
    popup.geometry(f"{pw}x{ph}+{root.winfo_x() + root.winfo_width()//2 - pw//2}+{root.winfo_y() + root.winfo_height()//2 - ph//2}")
    tk.Label(popup, text="Running Z-Init...\nPlease wait",
             bg="#1F1F1F", fg=FG, font=DEFAULT_FONT, justify="center").pack(expand=True)
    threading.Thread(target=_auto_zinit_worker,
                     args=(zinit_src, popup, ewma_s0_vals, ewma_alpha_bytes),
                     daemon=True).start()


def stop_serial():
    global ser
    stop_event.set()

    if ser:
        ser.close()
        ser = None
        log("Serial stopped")


def send_rand_stream_batch():
    set_stream_titles([f"Stream {i}" for i in range(STREAMS)])
    stop_event.clear()
    threading.Thread(target=_rand_stream_batch_worker, daemon=True).start()

# INPUT UI

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
    global app_started

    app_started = True
    start_button.config(bg="#1B5E20")
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

tk.Button(input_frame, text="Send CSV", font=BUTTON_FONT,
          bg="#00695C", fg="white",
          activebackground="#004D40",
          activeforeground="white",
          relief="flat",
          padx=10, pady=6,
          command=send_csv_data).pack(side=tk.LEFT, padx=5)

toggle_log_button = tk.Button(top, text="Hide Log", font=BUTTON_FONT,
          bg="#37474F", fg="white",
          activebackground="#263238",
          relief="flat",
          padx=10, pady=6,
          command=toggle_log)
toggle_log_button.pack(side=tk.LEFT, padx=5)



# MAIN

top.pack(pady=5)
plot_frame.pack(fill=tk.BOTH, expand=True)
log_frame.pack(fill=tk.X, pady=5)
input_frame.pack(pady=5)

pulse_start_button()
root.mainloop()