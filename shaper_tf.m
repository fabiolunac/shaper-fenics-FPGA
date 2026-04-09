clear all
close all

n_csp1 = [-7.4e-3];
d_csp1 = [1 2e8];

n_csp2 = [8.8e-2];
d_csp2 = [1 2e7];

n_csp3 = [-1.4e-2];
d_csp3 = [1 1e9];

csp1 = tf(n_csp1,d_csp1);
csp2 = tf(n_csp2,d_csp2);
csp3 = tf(n_csp3,d_csp3);

csp = csp1+csp2+csp3;

figure;
impulseplot(csp);

n_shp1 = [3e7];
d_shp1 = [1 2.4e7];

n_shp2 = [-2e7];
d_shp2 = [1 7.1e8];

n_shp3 = [-6.7e7];
d_shp3 = [1 2e8];

n_shp4 = [5.6e7];
d_shp4 = [1 4.7e8];

n_shp5 = [-2e3];
d_shp5 = [1 2e3];

shp1 = tf(n_shp1,d_shp1);
shp2 = tf(n_shp2,d_shp2);
shp3 = tf(n_shp3,d_shp3);
shp4 = tf(n_shp4,d_shp4);
shp5 = tf(n_shp5,d_shp5);

shp = shp1 + shp2 + shp3 + shp4 + shp5;

figure;
impulseplot(shp);

pulse_comp = shp * csp;

figure;
impulseplot(pulse_comp);



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

[num, den] = tfdata(pulse_comp, 'v');

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
        
        % Verificar se os polos ainda nÃ£o foram agrupados
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
impulseplot(pulse_frac_part)

%%

[y_cont_o, t_cont_o] = impulse(pulse_comp, [0:1e-12:1.3e-6]);  % Resposta contínua ao impulso


% Encontrar o valor máximo e o índice correspondente
[max_val, max_idx] = max(y_cont_o);

% Tempo correspondente ao valor máximo
t_max = t_cont_o(max_idx);

%%%%%%%%%%%%%%%%

s = tf('s');

delay = 0;

T_d = 75e-9 - t_max - delay*1e-9;


atraso_exp = exp(- T_d *s);

% PADE
atraso = pade(atraso_exp,2);


% Sistema total - exemplo: soma das funções de transferência

H_total_taylor = pulse_comp * atraso;

[num_taylor, den_taylor] = tfdata(H_total_taylor, 'v'); % Coeficientes em formato de vetor


freqi = 40e6;

[Znt_taylor, Zdt_taylor] = impinvar(num_taylor, den_taylor, freqi);

Znt_taylor = Znt_taylor * (freqi/max_val);

N = 50000;

[Xt_taylor, B] = impz(Znt_taylor, Zdt_taylor, N);



%% Amostrando os pontos em 25ns


% Obter resposta ao impulso contínua
[y_cont, t_cont] = impulse(pulse_comp, [0:1e-12:1.3e-6]);

y_cont = y_cont/max(y_cont);

% Encontrar o valor máximo e o índice correspondente
[max_val, max_idx] = max(y_cont);

% Tempo correspondente ao valor máximo
t_max = t_cont(max_idx);

% Intervalo de amostragem (25e-9 s)
delta_t = 25e-9;

% Criar os tempos deslocados
n_points_e = 3; % Quantidade de pontos para esquerda e direita
n_points_d = 10000; % Quantidade de pontos para esquerda e direita
t_amostrado = t_max + (-n_points_e:n_points_d) * delta_t;

% Interpolar os valores correspondentes do sinal contínuo
y_amostrado = interp1(t_cont, y_cont, t_amostrado, 'linear', 'extrap');


t_cont = t_cont + (50e-9 - t_max);
t_amostrado = t_amostrado + (50e-9 - t_max);
t_amostrado2 = t_amostrado + delay*1e-9;

t_cont = t_cont * 1e9;
t_amostrado = t_amostrado * 1e9;
t_amostrado2 = t_amostrado2 * 1e9;

y_amostrado_cut = y_amostrado(1:10000);

%y_amostrado_fir = round(y_amostrado * 2^15);


disp('Diferença entre o amostrado e a aproximação:');

disp(max(y_amostrado(1:50)-Xt_taylor(1:50)'./y_amostrado(1:50)))

% Plotar os resultados
figure('DefaultAxesFontSize',24)
plot(t_cont, y_cont, 'k', 'DisplayName', 'FENICS Circuit Shaper');
hold on;
stem(t_amostrado, y_amostrado, 'r', 'LineWidth', 1.5, 'DisplayName', 'Sampled Points');
legend;
xlabel('Time (ns)');
xlim([0,350]);
ylim([-0.1,1.05]);
ylabel('Normalized Amplitude [ADC Count]');
title('Transfer Function');
grid on;


figure('DefaultAxesFontSize',24)
plot(t_cont, y_cont, 'k', 'DisplayName', 'FENICS Circuit Shaper');
hold on;
stem(t_amostrado, y_amostrado, 'r', 'LineWidth', 1.5, 'DisplayName', 'Sampled Points');
stem(t_amostrado2(1:50), Xt_taylor(1:50), 'b', 'filled', 'DisplayName', 'Digitalized Transfer Function');  % Resposta discreta
legend;
xlabel('Time (ns)');
ylabel('Normalized Amplitude [ADC Count]');
xlim([0,350]);
ylim([-0.1,1.05]);
title('Transfer Function');
grid on;


%% Achando a função de transferência digitalizada em componentes

% DecomposiÃ§Ã£o usando a funÃ§Ã£o residue
[r, p, k] = residuez(Znt_taylor, Zdt_taylor);

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


%% Calorimentro

%Normalizado

N = 200000;


Gx = 2^32;

%x(1) = 2^0;

%y[n] = Zn1(1)*x[n] + Zn1(2)*x[n-1] - Zd1(2)*y[n-1]

Gy  = 2^15;


X_f = zeros(N,length(Hz));
X = zeros(N,length(Hz));

%for i=1:length(Hz)
for i=1:length(Hz)
    Zn = Hz{1,i}.Numerator;
    Zd = Hz{1,i}.Denominator;
    [X_f(:,i), Zn_q, Zd_q] = iir_generico(Zn, Zd, N, Gx, Gy);
    [X_temp, B] = impz (Zn, Zd, N); 
    
    X(:,i) = X_temp;
    
    Hz_quant{1,i}.Numerator = Zn_q;
    Hz_quant{1,i}.Denominator = Zd_q;
end


h = sum(X,2);

h_f = sum(X_f,2);


% Plotar a resposta filtrada
figure
stem(h_f/(Gy*Gx));
hold on;
stem(h);
title('Resposta ao Impulso');
legend("Sinal Quantizado","Sinal Original");
xlabel('Amostras');
ylabel('Amplitude');
grid on;



% % Plotar a resposta filtrada
% figure
% stem(X(1,:)/Gy);
% hold on;
% stem(X_f(1,:));
% title('Resposta ao Impulso');
% legend("Sinal Quantizado","Sinal Original");
% xlabel('Amostras');
% ylabel('Amplitude');
% grid on;


% Plotar a resposta filtrada
figure('DefaultAxesFontSize',24)
stem((h_f)/(Gy*Gx));
%legend("Sinal Quantizado","Sinal Original");
xlim([0,1200]);
ylim([-0.015,0.01]);
xlabel('Samples');
ylabel('Normalized Amplitude [ADC Count]');
grid on;



nome_arquivo = 'weight_shaper_fir.mif';

quant = Gy;

w_10bits = round(y_amostrado_cut*quant);

w_10bits_bin = dec2bin(typecast(int32(w_10bits),'uint32'));

w_10bits_bin_10 = w_10bits_bin(:,16:32);
%w_10bits_bin_10 = w_10bits_bin;

% Abra o arquivo para escrita
fid = fopen(nome_arquivo, 'w');

% Verifique se o arquivo foi aberto com sucesso
if fid == -1
    error('Não foi possível abrir o arquivo para escrita.');
end

% Escreva as strings no arquivo
for i = 0:length(w_10bits_bin_10)-1
    fprintf(fid, '%s\n', w_10bits_bin_10(end-i,:));
end

% Feche o arquivo
fclose(fid);

disp('Arquivo criado com sucesso.');