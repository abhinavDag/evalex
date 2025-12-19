#!/usr/bin/env python3

import datetime as dt
import matplotlib.pyplot as plt
import os
from collections import defaultdict

LOG_FILE = "log.txt"
IDLE_THRESHOLD = 5
PASTE_THRESHOLD = 15
OUT_DIR = "plots"

def compute_figsize(times, height=6, inches_per_hour=10, min_width=10):
    if len(times) < 2:
        return (min_width, height)

    duration_sec = (times[-1] - times[0]).total_seconds()
    duration_hours = duration_sec / 3600

    width = max(min_width, duration_hours * inches_per_hour)
    return (width, height)

def parse_log(path):
    events = []
    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            # 2025-12-19 11:52:10 : hi.cpp : 7
            parts = line.split(" : ")
            ts = dt.datetime.strptime(parts[0], "%Y-%m-%d %H:%M:%S")
            fname = parts[1]
            val = parts[2]

            if val.isdigit():
                events.append((ts, fname, int(val)))

    return events


def analyze(events):
    times = []
    chars = []
    speed = []
    files = []
    idle_periods = []

    prev_ts = None
    prev_chars = None

    for ts, fname, ch in events:
        times.append(ts)
        chars.append(ch)
        files.append(fname)

        if prev_ts is None:
            speed.append(0.0)
        else:
            dt_sec = (ts - prev_ts).total_seconds()
            dch = ch - prev_chars

            if dt_sec > 0 and 0 <= dch <= PASTE_THRESHOLD:
                speed.append(dch / dt_sec)
            else:
                speed.append(0.0)

            if dt_sec >= IDLE_THRESHOLD:
                idle_periods.append((prev_ts, ts, dt_sec))

        prev_ts = ts
        prev_chars = ch

    return times, chars, speed, files, idle_periods


def plot_and_save(times, chars, speed, files):
    os.makedirs(OUT_DIR, exist_ok=True)

    # -------- Character count (colored by file) --------
    file_data = defaultdict(lambda: ([], []))

    for t, c, f in zip(times, chars, files):
        file_data[f][0].append(t)
        file_data[f][1].append(c)

    figsize = compute_figsize(times)
    plt.figure(figsize=figsize)
    for fname, (t_list, c_list) in file_data.items():
        plt.plot(t_list, c_list, marker="o", label=fname)

    plt.xlabel("Time")
    plt.ylabel("Character Count")
    plt.title("Raw Character Count (Per File)")
    plt.legend()
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/character_count_by_file.png")
    plt.close()

    # -------- Typing speed --------
    figsize = compute_figsize(times)
    plt.figure(figsize=figsize)
    plt.plot(times, speed, marker="o")
    plt.xlabel("Time")
    plt.ylabel("Chars / Second")
    plt.title("Typing Speed (Forward Typing Only)")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig(f"{OUT_DIR}/typing_speed.png")
    plt.close()


def main():
    events = parse_log(LOG_FILE)
    times, chars, speed, files, idle_periods = analyze(events)

    print("Idle periods (>= {}s):".format(IDLE_THRESHOLD))
    for s, e, g in idle_periods:
        print(f"  {s} → {e} ({int(g)}s)")

    plot_and_save(times, chars, speed, files)
    print(f"Plots saved in ./{OUT_DIR}/")


if __name__ == "__main__":
    main()

