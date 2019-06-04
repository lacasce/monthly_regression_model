function [indices,success] = date_subsample_indices(small,large)
%Find a vector of all locations of elements of small vector in large vector

[n_s,temp]=size(small);
[n_l,temp]=size(large);
indices = zeros(n_s,1);
counter = 1;
success = false; %True if every element in small is found in large

for i = 1:n_l
    for j = 1:n_s
        if large{i}==small{j}
            indices(counter) = i;
            counter = counter + 1;
        end
    end
end

if counter == n_s+1 %counter should be one larger than dimension of small
    success=true;
end


end

