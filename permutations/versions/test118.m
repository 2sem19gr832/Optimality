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
Q_A_out_min*onesL <= Q_A_out <= Q_A_out_max*onesL;
Q_bp >= 0;
%Energy contraints for the accumulator input and output
E_A_min*onesL <= E_A <= E_A_max*onesL;

%Energy contraints for waste and gas, respectively.
E_A(1) == E_A_sys(k)
%Equality constraint for energy leaving the plant


Q_E == Q_A_out + Q_bp;
Q_W_min*onesL <= Q_W <= Q_W_max*onesL;
%Accumulator Energy storage Dynamics
Q_A_in_min*onesL  <= Q_A_in  <= Q_A_in_max*onesL;
E_A(2:L) == E_A(1:L-1) + (Q_A_in(1:L-1) - Q_A_out(1:L-1));
Q_G_min*onesL <= Q_G <= Q_G_max*onesL;

%Equality contraint for energy produced
Q_G + Q_W == Q_bp + Q_A_in

%Contraint for the energy leaving the plant     


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

%Creat revenue vector as rolling sum via for loop
for i=1:length(revenue)
   r_sum(i)=sum(revenue(1:i)); 
end

save('results_118', 'r_sum', 'E_A_sys', 'Q_E_sys', 'Q_G_sys') 