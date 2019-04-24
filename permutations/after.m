
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

