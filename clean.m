function clean_series = clean(series,limit)
%CLEAN Summary of this function goes here
%   Detailed explanation goes here
clean_series = series;
[T,n] = size(series);

for t=1:T
    for i = 1:n
        if abs(series(t,i))>limit
            clean_series(t,i)=0;
        end
    end
        
end

end

