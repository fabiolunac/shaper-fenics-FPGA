clc
clear
close all

Ts = 25e-9; % sample frequency

%% ===================== Generation TF (s) =====================
% Charge Sensitive Preamplifier (CSP)
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

% Pulse Shaper Circuit (PSC)
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

%% ===================== Decomposing in Partial Fractions =====================
pulse_terms = [];

csp_list = {csp1, csp2, csp3};
shp_list = {shp1, shp2, shp3, shp4, shp5};

k = 1;
for i = 1:length(csp_list)
    for j = 1:length(shp_list)
        pulse_terms{k} = csp_list{i} * shp_list{j};
        k = k + 1;
    end
end

[num, den] = tfdata(pulse_shp, 'v');

[r, p, k] = residue(num, den);

expressao = "";

processado = [];

num_proc = 1;

% Agrupando polos complexos conjugados e mantendo as fraÃ§Ãµes de ordem 1
for i = 1:length(p)
    % Se o polo tem uma parte imaginÃ¡ria diferente de zero
    if imag(p(i)) ~= 0
        % Encontrar o Ã­ndice do polo conjugado
        [~, idx_conjugate] = min(abs(p - conj(p(i))));
        
        % Verificar se os polos ainda não foram agrupados
        if ~ismember(p(i), processado)
            
            processado = [processado, conj(p(i))];
            % Soma dos resÃ­duos dos polos conjugados
            r_combined = real(conv(r(i),[1 -conj(p(i))]) + conv(r(idx_conjugate),[1 -p(i)]));
            p_combined = conv([1 -p(i)],[1 -conj(p(i))]);
            
            Hs{1,num_proc}.Numerator = r_combined;
            Hs{1,num_proc}.Denominator = p_combined;
            
            expressao_num = strcat(" H", num2str(num_proc), "(z) = ( ", num2str(r_combined(1))," + ", num2str(r_combined(2)),"z^-1 )");
            expressao_den = strcat(" / ( ", num2str(p_combined(1))," + ", num2str(p_combined(2)),"z^-1 + ", num2str(p_combined(3)),"z^-2 )");
            
            expressao(num_proc) = strcat(expressao_num,expressao_den);
            
            num_proc = num_proc + 1;
            
           
        end
    else
        % Caso seja um polo simples (real), adiciona diretamente
        
        r_sozinho = r(i);
        p_sozinho = [ 1 -p(i)];
        
        Hs{1,num_proc}.Numerator = r_sozinho;
        Hs{1,num_proc}.Denominator = p_sozinho;
        
        expressao_num = strcat(" H", num2str(num_proc), "(z) = ( ", num2str(r_sozinho(1))," )");
        expressao_den = strcat(" / ( ", num2str(p_sozinho(1))," + ", num2str(p_sozinho(2)),"z^-1 )");
            
        expressao(num_proc) = strcat(expressao_num,expressao_den);
        
        num_proc = num_proc + 1;
        
        
    end
end


pulse_frac_part = tf(Hs{1,1}.Numerator,Hs{1,1}.Denominator) + tf(Hs{1,2}.Numerator,Hs{1,2}.Denominator) + tf(Hs{1,3}.Numerator,Hs{1,3}.Denominator) + tf(Hs{1,4}.Numerator,Hs{1,4}.Denominator) + tf(Hs{1,5}.Numerator,Hs{1,5}.Denominator) + tf(Hs{1,6}.Numerator,Hs{1,6}.Denominator) + tf(Hs{1,7}.Numerator,Hs{1,7}.Denominator);

figure;
impulseplot(pulse_frac_part);

%% ===================== Digitalization =====================
[y_cont, t_cont] = impulse(pulse_shp, 0:1e-9:350e-9); 

% figure;
% plot(t_cont, y_cont);

[max_val, max_idx] = max(y_cont);
t_max = t_cont(max_idx);

% PADE DELAY
s = tf('s');
delay = 0;
T_d = 75e-9 - t_max - delay*1e-9;

atraso_exp = exp(-T_d*s);

atraso = pade(atraso_exp, 2);

H_total_taylor = pulse_shp * atraso;
[num_taylor, den_taylor] = tfdata(H_total_taylor, 'v');

% Invariant Impulse Method
fs = 1/Ts;
[Zn, Zd] = impinvar(num_taylor, den_taylor, fs);
% % Zn = Zn * (fs/max_val);

N = 50000;
[Xt_taylor, B] = impz(Zn, Zd, N);

% Normalização
Xt_taylor = Xt_taylor/max(Xt_taylor);




% ---------- Comparação de amostragem ----------
y_cont = y_cont/max(y_cont);

ne = 3; % Quantidade de pontos para esquerda e direita
nd = 10000; % Quantidade de pontos para esquerda e direita
t_sample = t_max + (-ne:nd) * Ts;
y_sample = interp1(t_cont, y_cont, t_sample, "linear", "extrap");

% alinhar o eixo do contínuo para o pico ficar em 50 ns
t_cont_plot   = (t_cont   + (50e-9 - t_max)) * 1e9;
t_sample_plot = (t_sample + (50e-9 - t_max)) * 1e9;

t_dig_plot = t_sample_plot + delay;

% pegar do sinal digital a mesma quantidade de amostras
y_dig = Xt_taylor(1:length(t_sample));

figure;
subplot(2, 1, 1)
plot(t_cont_plot, y_cont, 'k', 'LineWidth',2);
hold on;
stem(t_sample_plot, y_sample, 'b', 'filled');
xlabel('Tempo (ns)')
ylabel('Amplitude (normalizada)')
legend('Sinal Contínuo', 'Amostragem Ideal')
grid on;
xlim([0 350])
ylim([-0.1 1.05])


subplot(2, 1, 2)
plot(t_cont_plot, y_cont, 'k', 'LineWidth',2);
hold on;
stem(t_dig_plot, y_dig, 'r', 'filled');
xlabel('Tempo (ns)')
ylabel('Amplitude (normalizada)')
legend('Sinal Contínuo', 'Amostragem Digital')
grid on;
xlim([0 350])
ylim([-0.1 1.05])

%% Achando a função de transferência digitalizada em componentes

% DecomposiÃ§Ã£o usando a funÃ§Ã£o residue
[r, p, k] = residuez(Zn, Zd);

% Exibindo os resÃ­duos e polos
%disp('Resíduos:');
%disp(r);
%disp('Pólos:');
%disp(p);

% InicializaÃ§Ã£o das variÃ¡veis para armazenar os coeficientes das fraÃ§Ãµes parciais
fractions_numerators = [];
fractions_denominators = [];

expressao_z = "";

processado = [];

num_proc = 1;

% Agrupando polos complexos conjugados e mantendo as fraÃ§Ãµes de ordem 1
for i = 1:length(p)
    % Se o polo tem uma parte imaginÃ¡ria diferente de zero
    if imag(p(i)) ~= 0
        % Encontrar o Ã­ndice do polo conjugado
        [~, idx_conjugate] = min(abs(p - conj(p(i))));
        
        % Verificar se os polos ainda nÃ£o foram agrupados
        if ~ismember(p(i), processado)
            
            processado = [processado, conj(p(i))];
            % Soma dos resÃ­duos dos polos conjugados
            r_combined = real(conv(r(i),[1 -conj(p(i))]) + conv(r(idx_conjugate),[1 -p(i)]));
            p_combined = conv([1 -p(i)],[1 -conj(p(i))]);
            
            Hz{1,num_proc}.Numerator = r_combined;
            Hz{1,num_proc}.Denominator = p_combined;
            
            expressao_num = strcat(" H", num2str(num_proc), "(z) = ( ", num2str(r_combined(1))," + ", num2str(r_combined(2)),"z^-1 )");
            expressao_den = strcat(" / ( ", num2str(p_combined(1))," + ", num2str(p_combined(2)),"z^-1 + ", num2str(p_combined(3)),"z^-2 )");
            
            expressao_z(num_proc) = strcat(expressao_num,expressao_den);
            
            num_proc = num_proc + 1;
            

        end
    else
        % Caso seja um polo simples (real), adiciona diretamente
        
        r_sozinho = r(i);
        p_sozinho = [ 1 -p(i)];
        
        Hz{1,num_proc}.Numerator = r_sozinho;
        Hz{1,num_proc}.Denominator = p_sozinho;
       
        
        expressao_num = strcat(" H", num2str(num_proc), "(z) = ( ", num2str(r_sozinho(1))," )");
        expressao_den = strcat(" / ( ", num2str(p_sozinho(1))," + ", num2str(p_sozinho(2)),"z^-1 )");
            
        expressao_z(num_proc) = strcat(expressao_num,expressao_den);
        
        num_proc = num_proc + 1;
    end
end


