function weighted_avg = weighted_avg(corr,mcap)
%WEIGHTED_AVG_CORR Summary of this function goes here
%   Detailed explanation goes here

[T,n,temp] = size(corr);
weighted_avg = zeros(T,1);

for t=1:T
    mcap_tot=nansum(mcap(t,:));
    for i = 1:n
        for j = 1:n
            if not(isnan(corr(t,i,j))) && not(isnan(mcap(t,i))) && not(isnan(mcap(t,j)))
                weight_i = mcap(t,i)/mcap_tot;
                weight_j = mcap(t,j)/mcap_tot;
                weighted_avg(t) = weighted_avg(t)+corr(t,i,j)*weight_i*weight_j;
            end
        end
    end
end
            


end

