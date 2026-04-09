clc
clear
close all

% ===================== Charge Sensitive Preamplifier (CSP) =====================
num_csp1 = -7.4e-3;
den_csp1 = [1 2e8];

num_csp2 = 8.8e-2;
den_csp2 = [1 2e7];

num_csp3 = -1.4e-2;
den_csp3 = [1 1e9];

csp1 = tf(num_csp1, den_csp1);
csp2 = tf(num_csp2, den_csp2);
csp3 = tf(num_csp3, den_csp3);

csp = csp1 + csp2 + csp3;

t = linspace(0, 0.2e-6, 1000);

[y_csp1, t] = impulse(csp1, t);
[y_csp2, ~] = impulse(csp2, t);
[y_csp3, ~] = impulse(csp3, t);
[y_csp , ~] = impulse(csp , t);

figure;
subplot(2, 1, 1)
plot(t, y_csp1, 'LineWidth', 1, LineStyle='--'); hold on;
plot(t, y_csp2, 'LineWidth', 1, LineStyle='--');
plot(t, y_csp3, 'LineWidth', 1, LineStyle='--');
plot(t, y_csp , 'k', 'LineWidth', 2);

legend('csp1', 'csp2', 'csp3', 'Total Response (sum)');
title('Charge Sensitive Preamplifier');
grid on;

% ===================== Pulse Shaper Circuit (PSC) =====================
num_shp1 = 3e7;
den_shp1 = [1 2.4e7];

num_shp2 = -2e7;
den_shp2 = [1 7.1e8];

num_shp3 = -6.7e7;
den_shp3 = [1 2e8];

num_shp4 = 5.6e7; 
den_shp4 = [1 4.7e8];

num_shp5 = -2e3; 
den_shp5 = [1, 2e3];

shp1 = tf(num_shp1, den_shp1);
shp2 = tf(num_shp2, den_shp2);
shp3 = tf(num_shp3, den_shp3);
shp4 = tf(num_shp4, den_shp4);
shp5 = tf(num_shp5, den_shp5);

shp = shp1 + shp2 + shp3 + shp4 + shp5;

[y_shp1, ~] = impulse(shp1, t);
[y_shp2, ~] = impulse(shp2, t);
[y_shp3, ~] = impulse(shp3, t);
[y_shp4, ~] = impulse(shp4, t);
[y_shp5, ~] = impulse(shp5, t);
[y_shp, ~] = impulse(shp, t);


subplot(2, 1, 2)
plot(t, y_shp1, 'LineWidth', 1, LineStyle='--'); hold on;
plot(t, y_shp2, 'LineWidth', 1, LineStyle='--');
plot(t, y_shp3, 'LineWidth', 1, LineStyle='--');
plot(t, y_shp4, 'LineWidth', 1, LineStyle='--');
plot(t, y_shp5, 'LineWidth', 1, LineStyle='--');
plot(t, y_shp, 'k', 'LineWidth', 2);

xlabel('Time (s)');
ylabel('Response Amplitude');
legend('Shaper 1', 'Shaper 2', 'Shaper 3', 'Shaper 4', 'Shaper 5', 'Total Response (sum)')
title('Pulse Shaper Circuit');
grid on;

% ===================== Convolution =====================
pulse_shp = csp * shp;

figure;
impulseplot(pulse_shp);
