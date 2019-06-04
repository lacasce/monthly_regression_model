function [h,p_value] = RESET(y,y_hat,X,p,alpha)
%Ramsey's RESET test (1996)

[T,n]=size(X);
M=zeros(T,p); %create one column two many, for code readability in for loops
%M = [M X]; %append explanatory variables to the matrix with fitted variables

for i = 2:p
    for t = 1:T
        M(t,i)=y_hat(t)^i;
    end
end

M = M(:,2:end); %remove empty first column

aux_reg = fitlm(M,y,'linear');

R2 = aux_reg.Rsquared.Ordinary;

test_stat = T*R2;
cv = chi2inv(1-alpha,p-1);
p_value = 1 - chi2cdf(test_stat,p-1);

h = test_stat > cv;


end

