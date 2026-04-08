import pandas as pd
import matplotlib.pyplot as plt

data = pd.read_csv('iladata.csv')

print(data.columns.to_list())

adc_out               = pd.to_numeric(data['adc_out_reg[11:0]'], errors='coerce')
pzc_out               = pd.to_numeric(data['pzc_out_reg[12:0]'], errors='coerce')
pedestal_in           = pd.to_numeric(data['pedestal_in_reg[12:0]'], errors='coerce')
pedestal_compensation = pd.to_numeric(data['pedestal_out_reg[12:0]'], errors='coerce')


plt.figure()
plt.plot(adc_out              , drawstyle='steps-post', label='ADC Signal')
plt.plot(pzc_out              , drawstyle='steps-post', label='PZC Output (13 bits)')
plt.plot(pedestal_in          , drawstyle='steps-post', label='Pedestal Input')
plt.plot(pedestal_compensation, drawstyle='steps-post', label='Pedestal Compensation')

plt.axhline(0, color="black", linewidth=0.8)
plt.axvline(0, color='black', linewidth=0.8)

plt.ylabel('Amplitude [ADC Counts]')
plt.xlabel('Samples')

plt.grid(alpha=.2)
plt.legend()
plt.show()
