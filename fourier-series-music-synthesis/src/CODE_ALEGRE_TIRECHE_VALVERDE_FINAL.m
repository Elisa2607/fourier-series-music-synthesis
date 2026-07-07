%[x, Fs] = audioread('guitar.mp3');
%[x, Fs] = audioread('saxo.mp3');
[x,Fs] = audioread('piano.mp3');


% cas stéréo, convertir en mono
if size(x, 2) > 1
    x = x(:, 1);
end

N = length(x);             
t = (0:N-1) / Fs;           

%affichage
figure('Name', 'Analyse du signal Piano');

% Premier graphique : le signal entier
subplot(2, 1, 1);           
plot(t, x);
title('Signal complet (Piano)');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;


%Nos zones de "maintien"

%guitare
%t_debut = 1.0;
%t_fin = 1.05;

%saxo
%t_debut = 1.0;
%t_fin = 1.05;

%piano
t_debut = 0.400;
t_fin = 0.450;

indices = find(t >= t_debut & t <= t_fin);

% Deuxieme graphique : le zoom
subplot(2, 1, 2);         
plot(t(indices), x(indices));
title('Zoom sur la partie stable (Périodique)');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;



%% étape : estimation CN à partir de la fréquence f0

%on se focus sur la zone de maintien défini en fonction de l'instrument
% voir partie 1 (ligne 26)

X = x(indices);          
t_seg = t(indices)';     
N_points = length(X);    

K = 20;  % nb d'harmoniques
n_vector = -K:K;  

%Méthode 1 : F0 donnée
f_fixe = 440;

%Méthode 2 : Une grille
%on doit trouver notre f0
disp('recherche de f0 en cours...');
f_grille = 260:1:580; %nos notes sont comprises dans cette zone 
err_min = 1e9;        
f0_estime = 0;

for f_test = f_grille
    % matrice temporaire (chaque test)
    R_tmp = zeros(N_points, length(n_vector));
    for i = 1:length(n_vector)
        R_tmp(:, i) = exp(1j * 2 * pi * n_vector(i) * f_test * t_seg);
    end

    % calcul rapide
    c_tmp = (R_tmp' * R_tmp) \ (R_tmp' * X);
    X_rec = R_tmp * c_tmp;   

    % erreur sur notre test
    err = sum(abs(X - X_rec).^2);
    
    %condition pour à la fin trouver la bonne fréquence
    % celle avec le moins d'erreur.
    if err < err_min
        err_min = err;
        f0_estime = f_test;
    end
end

fprintf('f0 estimé : %d Hz\n', f0_estime);


%notre f0 pour la suite du code
f0 = f0_estime; %ou f_fixe, selon méthode


% coefficient Cn à partir de notre f0 estimé

R = zeros(N_points, length(n_vector));
for i = 1:length(n_vector)
    n = n_vector(i);
    R(:, i) = exp(1j * 2 * pi * n * f0 * t_seg);
end

Rh = R';      
A = Rh * R;           
B = Rh * X;       

c_estimes = (A \ B); 

%zone graphe 

figure('Name', 'Spectre des coefficients Cn');
stem(n_vector * f0, abs(c_estimes), 'LineWidth', 1.5);
title('Coefficients Cn estimés (Amplitude du Timbre)');
xlabel('Fréquence (Hz)');
ylabel('|Cn|');
grid on;

fprintf('Estimation terminée pour %d harmoniques.\n', K);

%pour montrer que sans hilbert, ça rend pas excellent
t_long = 0:1/Fs:2; 
R_long = exp(1j * 2 * pi * t_long' * (n_vector * f0));
x_test = real(R_long * c_estimes); 
x_test = x_test / max(abs(x_test)); % normalisation

figure('Name', 'Notre timbre sans "corps")');
plot(t_long, x_test);
title('Son de synthése brut');
xlabel('Temps (s)');
ylabel('Amplitude');
grid on;


%écoute du timbre

%soundsc(x_test, Fs);
audiowrite('timbrepiano.wav', x_test, Fs); %pour la présentation



%% étape 3 : hilbert / butterworth
z = abs(hilbert(x)); %vue en TP IA

%Butterworth utilisé (idée lors des réunions TPs)
fc = 20; 
[b, a] = butter(4, fc/(Fs/2), 'low'); 
An_lisse = filtfilt(b, a, z); % filtrage sans déphasage
An_norm = An_lisse / max(An_lisse); %on normalise pour être entre 0/1

% Affichage de l'enveloppe extraite
figure('Name', 'Extraction de l''enveloppe temporelle');
plot(t, x, 'Color', [0.7 0.7 0.7]); hold on;
plot(t, An_norm * max(x), 'r', 'LineWidth', 2); 
title('Enveloppe temporelle extraite');
legend('Signal original', 'Enveloppe normalisée');
xlabel('Temps (s)');
ylabel('Amplitude')
grid on;


%% étape 4 : notre synthése sur une note
x_synthese = zeros(size(t));
C0 = real(c_estimes(n_vector == 0)); %notre composante continue

% on fait somme des harmoniques modulées par l'enveloppe
for i = 1:length(n_vector)
    n = n_vector(i);
    if n > 0 %cas où c positif
        Cn = c_estimes(i);
        amplitude = 2 * abs(Cn);
        phase = angle(Cn);

        % Mult par l'enveloppe normalisée
        x_synthese = x_synthese + An_norm' .* (amplitude * cos(2*pi*n*f0*t + phase));
    end
end


x_synthese = x_synthese + C0; % et on ajoute notre composante continue

%lecture du résultat
soundsc(x_synthese, Fs);
audiowrite('synthesepiano.wav', x_synthese, Fs); %pour la présentation

%comparaison finale
figure('Name', 'Résultat de la synthése');
subplot(2,1,1); plot(t, x); title('Signal Original'); xlabel('Temps (s)'); ylabel('Amplitude');
subplot(2,1,2); plot(t, x_synthese); title('Signal Synthétisé'); xlabel('Temps (s)'); ylabel('Amplitude');


%% étape finale : Gammes

f_gamme = [261.6, 293.7, 329.6, 349.2, 392.0, 440.0, 493.9, 523.3]; %référence cours Mr.Carfantan 3eme octave  
t_n = (0:1/Fs:1); % 1 seconde par note
gamme = [];

% Enveloppe en fonction de la durée
An_g = interp1(linspace(0,1,length(An_norm)), An_norm, linspace(0,1,length(t_n)))';

for f = f_gamme
    note = zeros(size(t_n));
    for i = find(n_vector > 0) % Uniquement harmoniques positives
        note = note + An_g' .* (2*abs(c_estimes(i)) * cos(2*pi*n_vector(i)*f*t_n + angle(c_estimes(i))));
    end
    gamme = [gamme, note]; 
end

soundsc(gamme/max(abs(gamme)), Fs); % normalisation et lecture
audiowrite('gammepiano.wav', gamme, Fs); %pour la présentation
%% Bonus : Métrique

x_orig = x(:);
x_synth = x_synthese(:);

% RMSE -> ecart moyen amplitude
mse_val = mean((x_orig - x_synth).^2);

% Pearson (demande encadrant) -> Quand score proche de 1, excellent
z_synth = abs(hilbert(x_synth));
An_lisse_synth = filtfilt(b, a, z_synth);
An_norm_synth = An_lisse_synth / max(An_lisse_synth);

R_matrix_env = corrcoef(An_norm, An_norm_synth);
r_pearson_enveloppe = R_matrix_env(1,2);

fprintf("\n Nos métriques");
fprintf("\n MSE %e", mse_val);
fprintf("\n Pearson %.4f\n", r_pearson_enveloppe); 