clc
clear
close all

T = readtable("iladata.csv");

adc_out               = T.adc_out_reg_11_0_;
pzc_out               = T.pzc_out_reg_12_0_;
pedestal_in           = T.pedestal_in_reg_12_0_;
pedestal_compensation = T.pedestal_out_reg_12_0_;
eng_truth             = T.event_bt_reg_12_0_;
occ                   = T.occupancy_reg_6_0_;

occupancy = mean(occ);
occupancyRate = occupancy/128*100;


%% ADC and PZC Comparison
figure;
plot(adc_out);
hold on;
plot(pzc_out);
plot(pedestal_in);
plot(pedestal_compensation);

legend('ADC Output', 'PZC Output (13 bits)', 'Pedestal', 'Pedestal Compensation');

title(sprintf('ADC and PZC Comparison, occupancy = %.0f%%', occupancyRate));
xlabel('Sample');
ylabel('Amplitude [ADC Counts]');
grid on;
hold off;