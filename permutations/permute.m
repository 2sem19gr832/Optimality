%Accumulator Energy storage Dynamics
E_A(1) == E_A_sys(k)
E_A(2:L) == E_A(1:L-1) + (Q_A_in(1:L-1) - Q_A_out(1:L-1));


%Energy contraints for waste and gas, respectively.
Q_W_min*onesL <= Q_W <= Q_W_max*onesL;
Q_G_min*onesL <= Q_G <= Q_G_max*onesL;

%Energy contraints for the accumulator input and output
Q_A_in_min*onesL  <= Q_A_in  <= Q_A_in_max*onesL;
Q_A_out_min*onesL <= Q_A_out <= Q_A_out_max*onesL;

%Equality constraint for energy leaving the plant
Q_E == Q_A_out + Q_bp;
%Equality contraint for energy produced
Q_G + Q_W == Q_bp + Q_A_in

%Contraint for the energy leaving the plant     
Q_bp >= 0;
E_A_min*onesL <= E_A <= E_A_max*onesL;

