function time_series_diff = differences(time_series)
%DIFFERENCES Summary of this function goes here
%   Detailed explanation goes here
[T,n] = size(time_series);
time_series_diff = time_series;
time_series_diff(1)=0;
for t = 2:T
    for i = 1:n
        time_series_diff(t,i) = time_series(t,i)-time_series(t-1,i);
    end
end

end

