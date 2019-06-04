function ratio = volume_ratio(volume_small,volume_large)
%Calculates the ratio of the sum of one time series divided by another
%Used to calculate ETF equivalent trading volume

[T,n] = size(volume_small);
ratio = zeros(T,n);

for i = 1:n
    for t = 1:T
        ratio(t,i)=volume_small(t,i)/nansum(volume_large(t,:)); %volume large needs to be summed up because it contains trading volumes for multiple assets
    end
end

end

