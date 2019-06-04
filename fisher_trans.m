function corr_series = fisher_trans(corr_series)
[T,n,temp] = size(corr_series);

%first make all non nan diagonal elements 0
for t=1:T
    for i = 1:n
        if ~isnan(corr_series(t,i,i))
            corr_series(t,i,i)=0;
        end
    end
end

%fisher transformation on non-diagonal and non-nan elements
for t=1:T
    for i = 1:n-1
        for j = i+1:n
            if ~isnan(corr_series(t,i,j))
                e = corr_series(t,i,j);
                corr_series(t,i,j) = 0.5*log((1+e)/(1-e));
                corr_series(t,j,i) = corr_series(t,i,j);
            end
        end
    end
end

end

