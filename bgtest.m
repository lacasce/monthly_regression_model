function [output,pvalue] = bgtest(number_of_lags,alpha,residuals, X)
%Breusch–Godfrey test

[T,temp]=size(X);
lags = zeros(T,number_of_lags);

for i = 1:number_of_lags
    for t = i+1:T
        lags(t,i)=residuals(t-i);
    end
end

%Add all explanatory variables and lags to regression

X = [X lags]; 

%Run regression
lm1 = fitlm(X(number_of_lags+1:end,:),residuals(number_of_lags+1:end),'linear');

%Get stat value
R_squared = lm1.Rsquared.Ordinary;
chi_sq_stat = R_squared*(T-number_of_lags);
comp = chi2inv(1-alpha,number_of_lags);
pvalue = 1-chi2cdf(chi_sq_stat,number_of_lags);

output = chi_sq_stat > comp;

end

