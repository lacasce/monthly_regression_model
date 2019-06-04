function initiation = initiation_matrix(log_returns,initial_sample_size)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[T,n] = size(log_returns);
initiation = zeros(T,n);

for t = initial_sample_size+2:T
    for i = 1:n
        if isnan(log_returns(t-initial_sample_size-1,i)) && ~isnan(log_returns(t-initial_sample_size,i))
            initiation(t,i)=1;
        end
    end
end
end

