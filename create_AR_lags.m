function X = create_AR_lags(y,number_of_lags)

[T,temp]=size(y);
X = zeros(T,number_of_lags);

for i = 1:number_of_lags
    for t = i+1:T
        X(t,i)=y(t-i);
    end
end



end

