function residuals = ARMA_residuals(y,p_max,q_max)
%Takes in a time series and returns the ARMA residuals of a p,q ARMA model


SBIC = zeros(p_max+1,q_max+1); %Note that index is 1 greater than number of lags due to indices starting at 1
[T,temp] = size(y);

%SBIC to decide number of lags
for p = 0:p_max
    for q = 0:q_max
        %Estimate with p and q
        na = p; %p
        nc = q;
        model = armax(y, [na nc]);
        sigma_hat = model.NoiseVariance;
        k = p+q+1; %A SBIC variable
        %calculate
        SBIC(p+1,q+1) = log(sigma_hat)+k*log(T)/T;
        
    end
end

%Find indices of minimum
[SBIC_row, p_star] = min(SBIC);
[temp, q_star] = min(SBIC_row);
p_star = p_star(q_star);
p_star = p_star-1;
q_star = q_star-1;

model = armax(y, [p_star q_star]);
res_model = resid(y,model);
residuals = res_model.y;

fprintf('\nSBIC gives p = %i and q = %i\n',p_star,q_star) 


end

