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
% figure
% hold on
% stairs(P_E)
% stairs(P_G,'r')
% stairs(P_W,'g')
% title('price data')
% legend('Price Electricity','Price for gas','Price of burning waste')
% ylabel('[DKK/MWh]')
% xlabel('Sample [hour]')
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
k
cvx_begin quiet % The begining of the optimization problem
%cvx_solver mosek


% Define the variables %%% FILL IN %%%
variables Q_W(L,1) Q_G(L,1) Q_E(L,1) Q_A_in(L,1) Q_A_out(L,1) E_A(L,1) Q_bp(L,1) Ptot

% Specify the optimization of cost %%% FILL IN %%%
Ptot == (P_E(k:k+L-1)'*Q_E(1:L) - (P_G(k:k+L-1)'*Q_G(1:L) + P_W(k:k+L-1)'*Q_W(1:L)))*Ts; %Total profit in DKK

%Ptot = sum(Pot);
maximize(Ptot); %We want to maximize the profit subject to the energy contraints seen below

% constraints %%% FILL IN %%%
subject to
