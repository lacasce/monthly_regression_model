function log_return = log_return(prices)
%Creates a matrice of log returns
%Note that the first row is zeros, so that matrix dimensions is same as
%other data

[T,n] = size(prices);
log_return = zeros(T,n);

for i = 1:n
	for j = 2:T
        log_return(j,i)=log(prices(j,i))-log(prices(j-1,i));
    end
end

end

