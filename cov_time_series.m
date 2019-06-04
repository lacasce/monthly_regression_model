function time_series_cov = cov_time_series(log_returns,timestamps_daily,timestamps_monthly)
%CORRELATIONS Summary of this function goes here
%   Detailed explanation goes here

%Initiate required variables and empty matrixes
[days,stocks] = size(log_returns); 
[months,temp] = size(timestamps_monthly);
time_series_cov = zeros(months,stocks,stocks);

%Create indices of where every month ends in the daily timestamps
[month_end_indices, indice_success] = date_subsample_indices(timestamps_monthly,timestamps_daily);
if indice_success==false
    fprintf('\nError in finding all monthly timestamps in daily timestamps.\n')
end

for i = 1:months
    %First we find upper and lower date boundaries for months
    upper = month_end_indices(i);
    if i == 1
        lower=2;%first row of log returns is 0
    else
        lower=month_end_indices(i-1)+1;
    end
    month_returns = log_returns(lower:upper,:);
    time_series_cov(i,:,:) = cov(month_returns);
    
end
    
    
%{

initiation = initiation_matrix(log_returns,initial_sample_size); %A matrix that shows when a new firm is ready to be inserted

for t = initial_sample_size+2:T %Time variable used for indexing
   for i = 1:n
       if initiation(t,i)==1 %Code to insert new firms to the time series
            temp_cov = cov(log_returns(t-initial_sample_size:t,:));
            time_series_cov(:,i,t)=temp_cov(:,i);
            time_series_cov(i,:,t)=temp_cov(i,:);
       else
            for j = i:n
                if initiation(t,j)==0 %Only insert if not a initiation
                    time_series_cov(i,j,t)=lambda*time_series_cov(i,j,t-1)+(1-lambda)*log_returns(t,i)*log_returns(t,j);
                    time_series_cov(j,i,t)=time_series_cov(i,j,t);
                end
            end
       end
   end
end

%}


end

