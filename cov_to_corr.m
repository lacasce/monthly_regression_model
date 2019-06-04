function [corr_series] = cov_to_corr(cov_series)
%COV_TO_CORR Summary of this function goes here
%   Detailed explanation goes here

%Transform covariance matrix into correlation matrix
[T,n, temp] = size(cov_series);
corr_series = cov_series;

for t = 1:T
   for i = 1:n
       for j = i:n
           corr_series(t,i,j) = cov_series(t,i,j)/(sqrt(cov_series(t,i,i))*sqrt(cov_series(t,j,j)));
           corr_series(t,j,i) = corr_series(t,i,j);
       end
   end
end


end

