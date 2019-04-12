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
figure
hold on
stairs(P_E)
stairs(P_G,'r')
stairs(P_W,'g')
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

for k = 1:M-L+1 % The main loop     191 iteration when L = 10
    
cvx_begin quiet % The begining of the optimization problem

% Define the variables 
variables Q_W(L,1) Q_G(L,1) Q_E(L,1) Q_bp(L,1) Q_A_in(L,1) Q_A_out(L,1) E_A(L,1) % Where L is the control horizon

% Specify the optimization of cost
maximize(P_E(k:k+L-1)' * Q_E(1:L) - (P_G(k:k+L-1)' * Q_G(1:L) + P_W(k:k+L-1)' * Q_W(1:L))) % Multiply by Ts, but Ts = 1.

% constraints 
subject to 
    
    % Accumulator dynamics: 
    E_A(1:end) == [E_A_sys(k); E_A(1:end-1)] + (Q_A_in(1:end) - Q_A_out(1:end))*Ts;
    
    % Accumulator constraints:
    E_A <= E_A_max;
    E_A >= E_A_min;
    
    % Power feed into the accumulator contstraints:
    Q_A_in <= Q_A_in_max*ones(L,1);
    Q_A_in >= Q_A_in_min*ones(L,1);

    % Power leaving the accumulator constraints:
    Q_A_out <= Q_A_out_max*ones(L,1);
    Q_A_out >= Q_A_out_min*ones(L,1);

    % Power produced by the waste burner constarints:
    Q_W <= Q_W_max*ones(L,1);
    Q_W >= Q_W_min*ones(L,1);

    % Power produced by the gas turbine constraints:
    Q_G <= Q_G_max*ones(L,1);
    Q_G >= Q_G_min*ones(L,1);
    
    % flow constraints
    Q_W + Q_G == Q_bp + Q_A_in;
    Q_E == Q_bp + Q_A_out;

cvx_end % The end of the optimization problem
%cvx_status % Tells whether the problem is solved. 
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

close all
figure
hold on
stairs(E_A_sys)
stairs(P_E)
legend('state of the charge in the accumulator','Power Price')
title('The state of charge in the accumulator')
ylabel('[MWh]')
xlabel('Sample [hour]')

figure
stairs(Q_W_sys)
title('Power from using waste')
ylabel('[MW]')
xlabel('Sample [hour]')

figure
stairs(Q_G_sys)
title('Power from using gas')
ylabel('[MW]')
xlabel('Sample [hour]')

figure
hold on
stairs(Q_E_sys,'r')
stairs(P_E)
legend('Electrical Power','Power Price')
title('Comparing Power production with power price')
ylabel('[MW]')
xlabel('Sample [hour]')

figure
stairs(Q_bp_sys)
title('Power that bybasses the accumulator')
ylabel('[MW]')
xlabel('Sample [hour]')

figure
stairs(Q_A_out_sys)
title('Power that comes out of the accumulator')
ylabel('[MW]')
xlabel('Sample [hour]')

figure
stairs(revenue)
title('revenue')
ylabel('[DKK]')
xlabel('Sample [hour]')

figure
hold on
stairs(P_E)
stairs(P_G,'r')
stairs(P_W,'g')
title('price data')
legend('Price Electricity','Price for gas','Price of burning waste')
ylabel('[DKK/MWh]')
xlabel('Sample [hour]')

% %Creat revenue vector as rolling sum via for loop
% for i=1:length(revenue)
%    r_sum(i)=sum(revenue(1:i)); 
% end
% 
% figure
% hold on
% stairs(r_sum)
% title('Total revenue generated over time');
% ylabel('Revenue [DKK]')
% xlabel('Sample [hour]')
% grid

%%
%Creat revenue vector as rolling sum via for loop
for i=1:length(revenue)
   r_sum(i)=sum(revenue(1:i)); 
end
figure('Name', 'Total revenue generated over time')
hold on
stairs(r_sum,'LineWidth',2)
ax = gca;
ax.FontSize = 20;
title('Total revenue generated over time', 'FontSize',24)
xlabel('Sample [hour]','FontSize',20)
ylabel('Revenue [DKK]','FontSize',20)
grid


figure('Name', 'The state of charge in the accumulator')
hold on
stairs(E_A_sys, 'LineWidth',2)
stairs(P_E, 'LineWidth',2)
ax = gca;
ax.FontSize = 20;
title('State of the charge in the accumulator', 'FontSize',24)
legend('State of the charge in the accumulator','Power Price')
xlabel('Sample [hour]','FontSize',20)
ylabel('[MWh]','FontSize',20)
grid

%%
%comparing revenues:

% for i=1:length(revenueL50)
%    r_sumL3(i)=sum(revenueL3(1:i)); 
%    r_sumL10(i)=sum(revenueL10(1:i)); 
%    r_sumL20(i)=sum(revenueL20(1:i)); 
%    r_sumL50(i)=sum(revenueL50(1:i)); 
% end
% figure('Name', 'Total revenue generated over time')
% hold on
% stairs(r_sumL3,'LineWidth',2)
% stairs(r_sumL10,'LineWidth',2)
% stairs(r_sumL20,'LineWidth',2)
% stairs(r_sumL50,'LineWidth',2)
% ax = gca;
% ax.FontSize = 20;
% title('Total revenue generated over time', 'FontSize',24)
% legend('revenue L = 3','revenue L = 10','revenue L = 50')
% xlabel('Sample [hour]','FontSize',20)
% ylabel('Revenue [DKK]','FontSize',20)
% grid

