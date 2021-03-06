clear all
close all
clc

%% CVX exercise 
% To complete the exercise you need to fill in the missing part of the cvx
% proceedure (from cvx_begin to cvx_end) GOOD LUCK

L = 10; % Window size of the mpc proplem (Control horizon = Prediction horizon)
M = 200; % The duration of the control process
Ts = 1; % Time step (1 hour)

onesL = ones(L,1); % one vector of length L
zerosL = zeros(L,1); % zero vector of length L

% Defining vectors of the system parameters
E_A_sys = zeros(M-L+2,1);
Q_W_sys = zeros(M-L+1,1);
Q_G_sys = zeros(M-L+1,1);
Q_A_in_sys = zeros(M-L+1,1);
Q_A_out_sys = zeros(M-L+1,1);
Q_E_sys = zeros(M-L+1,1);
Q_bp_sys = zeros(M-L+1,1);
revenue = zeros(M-L+1,1);

% Generates the data (Low pass filtered white gaussian noise)
price_data_generator %(OBS: There is a rand seed = 1 in the file)

%% Plot price vectors
figure(1)
hold on
stairs(P_E)     %electricity
stairs(P_G,'r') %gas
stairs(P_W,'g') %waste
title('price data')
legend('Price Electricity','Price for gas','Price of burning waste')
ylabel('[DKK/MWh]')
xlabel('Sample [hour]')
%%

% Define the linear inequalities for the variables
Q_W_min = 0;
Q_W_max = 40;
Q_G_min = 0;
Q_G_max = 20;
E_A_min = 0;
E_A_max = 200;
Q_A_in_min = 0;
Q_A_in_max = 50;
Q_A_out_min = 0;
Q_A_out_max = 25;

E_A_sys(1) = 0; %Initial condition

for k = 1:M-L+1 % The main loop

cvx_begin quiet % The begining of the optimization problem
% Define the variables %%% FILL IN %%%
variables Q_W(L,1) Q_G(L,1) Q_E(L,1) Q_bp(L,1) Q_A_in(L,1) Q_A_out(L,1) E_A(L,1) %P_E P_G P_W
% Specify the optimization of cost %%% FILL IN %%% 
maximize(P_E(k:k+9)'*Q_E(1:L)-(P_G(k:k+9)'*Q_G(1:L)+P_W(k:k+9)'*Q_W(1:L)))*Ts

% constraints %%% FILL IN %%%
subject to 
    %Accumulator dynamics
    E_A(k+1) == E_A(k)+(Q_A_in(k)-Q_A_out(k))*Ts
    %Accumulator dynamics constraints
    E_A <= E_A_max
    E_A >= E_A_min
    %Waste constraints
    Q_W >= Q_W_min
    Q_W <= Q_W_max
    %Gas constraints
    Q_G <= Q_G_min
    Q_G >= Q_G_max
    %accumulator input/output
    Q_A_in <= Q_A_in_max
    Q_A_in >= Q_A_in_min
    Q_A_out <= Q_A_out_max
    Q_A_out >= Q_A_out_min
    %Flow constraints
    Q_W+Q_G == Q_bp+Q_A_in
    Q_E == Q_bp+Q_A_out
cvx_end % The end of the optimization problem
cvx_status % Tells whether the problem is solved. 
%Does not tell you whether the problem is posed correctly. 

% Calculate the system (The first entry of the vectors)
% Save the data for analysis
E_A_sys(k+1) = E_A_sys(k) + (Q_A_in(1) - Q_A_out(1))*Ts; % The real system
Q_W_sys(k) = Q_W(1); 
Q_G_sys(k) = Q_G(1); 
Q_A_in_sys(k) = Q_A_in(1);
Q_A_out_sys(k) = Q_A_out(1);
Q_E_sys(k) = Q_E(1);
Q_bp_sys(k) = Q_bp(1);
revenue(k) = [-P_G(k); -P_W(k); P_E(k)]'*[Q_G(1); Q_W(1); Q_E(1)];
end
%% Plot the results

% I got you started! Make some more plots and investigate the results
%close all
figure(2)
stairs(E_A_sys)
title('The state of charge in the accumulator')
ylabel('[MWh]')
xlabel('Sample [hour]')

figure(3)
stairs(Q_W_sys)
title('Power from using waste')
ylabel('[MW]')
xlabel('Sample [hour]')

figure(4)
stairs(Q_G_sys)
title('Power from using gas')
ylabel('[MW]')
xlabel('Sample [hour]')

figure(5)
hold on
stairs(Q_E_sys,'r')
stairs(P_E)
legend('Electrical Power','Power Price')
title('Comparing Power production with power price')
ylabel('[MW]')
xlabel('Sample [hour]')

%Creat revenue vector as rolling sum via for loop
for i=1:length(revenue)
   r_sum(i)=sum(revenue(1:i)); 
end

figure(6)
hold on
stairs(r_sum)
title('Total revenue generated over time');
ylabel('Revenue [DKK]')
xlabel('Sample [hour]')
grid


