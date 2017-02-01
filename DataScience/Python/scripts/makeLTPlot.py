# For 'traditional LT plot' use Subject_607_Running.csv.
data = np.genfromtxt('Subject_607_Running.csv', delimiter=',')
xs = data[:, 0]
ys = data[:, 1]
plt.plot(xs * 2.23694, ys, marker='*')
plt.xlabel('pace (mph)')
plt.ylabel('[lactate] (mmol/L)')
plt.title('Lactate Threshold Test - Running')
plt.axvline(5.8, color='green', label='LT1 = 5.8 mph')
plt.axvline(6.7, color='red', label='LT2 = 6.7 mph')
plt.legend()
plt.show()

data = np.genfromtxt('Subject_678_Running.csv', delimiter=',')
xs = data[:, 0]
ys = data[:, 1]
plt.plot(xs * 2.23694, ys, marker='*')
plt.xlabel('pace (mph)')
plt.ylabel('[lactate] (mmol/L)')
plt.title('Lactate Threshold Test - Running')
plt.axvline(6.4, color='green', label='LT1 = 6.4 mph')
plt.axvline(8.0, color='red', label='LT2 = 8.0 mph')
plt.legend()
plt.show()

data = np.genfromtxt('Subject_574_Cycling.csv', delimiter=',')
xs = data[1:, 0]
ys = data[1:, 1]
plt.plot(xs, ys, marker='*')
plt.xlabel('power (W)')
plt.ylabel('[lactate] (mmol/L)')
plt.title('Lactate Threshold Test - Cycling')
plt.axvline(160, color='green', label='LT1 = 160 W')
plt.axvline(200, color='red', label='LT2 = 200 W')
plt.legend()
plt.show()

data = np.genfromtxt('Subject_633_Cycling.csv', delimiter=',')
xs = data[1:, 0]
ys = data[1:, 1]
plt.plot(xs, ys, marker='*')
plt.xlabel('power (W)')
plt.ylabel('[lactate] (mmol/L)')
plt.title('Lactate Threshold Test - Cycling')
plt.axvline(300, color='green', label='LT1 = 300 W')
plt.axvline(360, color='red', label='LT2 = 360 W')
plt.legend()
plt.show()

# For plotting a line with a fill between 2 points on the x-axis. Slice
# the x and y data.
plt.ylim(0,8)
plt.xlim(75, 350)
plt.xlabel('power (W)')
plt.ylabel('[lactate] (mmol/L)')
plt.vlines(260, ymin=0, ymax=2.3, color='green', lw=3)
plt.vlines(320, ymin=0, ymax=5.1, color='red', lw=3)
plt.fill_between(xs[7:11], ys[7:11], color='yellow', alpha=0.5)
plt.plot(xs, ys, marker='o')
plt.show()
