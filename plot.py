import matplotlib.pyplot as plt
from datetime import datetime

DELTA_T_TYPING = 3

def to_epoch(timestamp):
	dt = datetime.strptime(timestamp, "%Y-%m-%d %H:%M:%S")
	return (int(dt.timestamp()))

def from_epoch(epoch_time):
	dt = datetime.fromtimestamp(epoch_time)
	return dt.strftime("%Y-%m-%d %H:%M:%S")

def time_diff(left, right):
	return to_epoch(right) - to_epoch(left)

def average_typing_speed(timestamps, char_counts, files, start_timestamp, end_timestamp):
	activities = []
	iter = 0
	while(iter < len(timetamps)):
		if(time_diff(left, time_stamps[iter]) < 0):
			if(time_diff(timestamps[iter], right) < 0):	
				if(last_stamp):
					if(time_diff(last_stamp, timestamps[iter]) > 1):
						total_activity += activity
						activity = 0
						last_stamp = timestamps[iter]
					else:					
						increment += (char_count[iter] - char_count[iter-1])
						if( increment < 0):
							increment  *= -1
						activity += increment
				last_time = timestamps[iter]
				last_char_count = char_counts[iter]
				last_file = files[iter]
			else:
				total_activity += activity
				activities.append(total_activity)
				left = right
				right = from_epoch(DELTA_T_TYPING+to_epoch(start_timestamp)
				activity = 0
				total_activity = 0
				last_stamp = ""
				last_char_count = 0
				last_file = ""
		iter+=1
print(activitites)
			
						





with open('log.txt', 'r') as log_file:
	data = log_file.readlines()

timestamps = []
files = []
char_counts = []
saves = {}
opens = {}	


for line in data:
	arr = line.strip().split(" : ")
	print(arr)
	if(arr[2] == "saved"):
		saves[arr[0]] = arr[1]
	elif(arr[2] == "opened"):
		opens[arr[0]] = arr[1]
	else:
		timestamps.append(arr[0])
		files.append(arr[1])
		char_counts.append(arr[2])














plt.figure(figsize=(120, 10))  # wide and reasonable height for horizontal stretch

plt.plot(timestamps, char_counts)

# Rotate x-axis labels to avoid overlap
plt.gcf().autofmt_xdate()

# Make layout fit well
plt.tight_layout()

plt.xticks(fontsize=1)
plt.yticks(fontsize=1)

for label in plt.gca().get_xticklabels():
    label.set_rotation(90)

plt.tick_params(axis='both', width=0.1)  # thin ticks

# Save higher-resolution image
plt.savefig("fixed_plot.png", dpi=300)
