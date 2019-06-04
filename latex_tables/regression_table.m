function regression_table(filename,lm_agg,lm_sep,p_agg,p_sep,index)

%Create table of significance levels
star_agg = cell(size(lm_agg.Coefficients(:,4)));
star_sep = cell(size(lm_sep.Coefficients(:,4)));
for i = 1:length(star_agg)
    if lm_agg.Coefficients{i,4}<0.01
        star_agg{i} = "**";
    elseif lm_agg.Coefficients{i,4}<0.05
        star_agg{i} = "*";
    else
        star_agg{i} = "";
    end
end
for i = 1:length(star_sep)
    if lm_sep.Coefficients{i,4}<0.01
        star_sep{i} = "**";
    elseif lm_sep.Coefficients{i,4}<0.05
        star_sep{i} = "*";
    else
        star_sep{i} = "";
end

fileID = fopen(filename,'w');

beta_names = {"{total}^{ff}","{\Delta total}^{etf}","{large}^{ff}","{mid}^{ff}","{small}^{ff}","{\Delta large}^{etf}","{\Delta mid}^{etf}","{\Delta small}^{etf}","{other}^{etf}","{intercept}","{\Delta VIX}","{recession}","{AR1}","{AR2}","{AR3}"};

fprintf(fileID,'\\begin{table}[]\n');
fprintf(fileID,'\\begin{tabular}{lll}\n');

if index == 'large'
    fprintf(fileID,'S\\&P 500 (Large cap)  & Aggregated model & Split model \\\\ \\hline\n');
elseif index == 'mid'
    fprintf(fileID,'S\\&P 400 (Mid cap)  & Aggregated model & Split model \\\\ \\hline\n');
else
    fprintf(fileID,'S\\&P 500 (Small cap)  & Aggregated model & Split model \\\\ \\hline\n');
end


for i = 1:2 %rows including total ff/etf
    fprintf(fileID,'$\\beta_%s$  & %.4f  & \\\\\n',beta_names{i},lm_agg.Coefficients{i+1,1});
    fprintf(fileID,'                      & %s(%.4f)         &  \\\\\n',star_agg{i+1}, lm_agg.Coefficients{i+1,4});
end

for i = 3:9 %rows including split ff/etf
    fprintf(fileID,'$\\beta_%s$  &        & %.4f \\\\\n',beta_names{i},lm_sep.Coefficients{i-1,1});
    if i ~=9
        fprintf(fileID,'                      &         & %s(%.4f) \\\\\n',star_sep{i-1}, lm_sep.Coefficients{i-1,4});
    else
        fprintf(fileID,'                      &         & %s(%.4f) \\\\ \\hline \n',star_sep{i-1}, lm_sep.Coefficients{i-1,4});
    end
    
end

%intercept
fprintf(fileID,'$\\beta_%s$  & %.4f  & %.4f \\\\\n',beta_names{10},lm_agg.Coefficients{1,1},lm_sep.Coefficients{1,1});
fprintf(fileID,'                      & %s(%.4f)          & %s(%.4f) \\\\\n',star_agg{1}, lm_agg.Coefficients{1,4},star_sep{1},lm_sep.Coefficients{1,4});

%five last explanatory variables
for i = 11:15
    fprintf(fileID,'$\\beta_%s$  & %.4f  & %.4f \\\\\n',beta_names{i},lm_agg.Coefficients{i-7,1},lm_sep.Coefficients{i-2,1});
    if i~=15
        fprintf(fileID,'                      & %s(%.4f)          & %s(%.4f) \\\\\n',star_agg{i-7}, lm_agg.Coefficients{i-7,4},star_sep{i-2},lm_sep.Coefficients{i-2,4});
    else %add hline for last row
        fprintf(fileID,'                      & %s(%.4f)          & %s(%.4f) \\\\ \\hline\n',star_agg{i-7}, lm_agg.Coefficients{i-7,4},star_sep{i-2},lm_sep.Coefficients{i-2,4});
    end 
end

fprintf(fileID,' $R^2_{adjusted}$      & %.4f  & %.4f \\\\ \\hline\n', lm_agg.Rsquared.Adjusted,lm_sep.Rsquared.Adjusted);
fprintf(fileID,'& Regression test p-values  &  \\\\ \\hline\n');


%tests
test_names = {"F-test vs constant model","JB test (normality)","White's test (Homoscedasticity)","BG test(Autocorrelation)","RESET test (correct functional form)"};


%[temp,p_f_agg]=fTest(lm_agg);
%[temp,p_f_sep]=fTest(lm_sep);
fprintf(fileID,'%s & 0.0000 & 0.0000  \\\\ \n',test_names{1});%,p_f_agg,p_f_sep);

%Significance for tests
star_tests_agg = cell(size(p_agg));
star_tests_sep = cell(size(p_sep));
for i = 1:length(star_tests_agg)
    if p_agg(i)<0.01
        star_tests_agg{i}="**";
    elseif p_agg(i)<0.05
        star_tests_agg{i}="*";
    else
        star_tests_agg{i}="";
    end
end
for i = 1:length(star_tests_sep)
    if p_sep(i)<0.01
        star_tests_sep{i}="**";
    elseif p_sep(i)<0.05
        star_tests_sep{i}="*";
    else
        star_tests_sep{i}="";
    end
end


for i = 2:5
    fprintf(fileID,'%s& %s%.4f & %s%.4f  \\\\ \n',test_names{i},star_tests_agg{i-1},p_agg(i-1),star_tests_sep{i-1},p_sep(i-1));
end

fprintf(fileID,'\\end{tabular}\n')
fprintf(fileID,'\\caption{Estimated coefficients,$R^2$ and assumption test p-values. Estimated coefficients  are given along with t-test p-values. P-values significant at a significance level of 5\\%% are highlighted with one star, and those significant at a 1\\%% significance level are highlighted with two stars.}\n',index)
fprintf(fileID,'\\label{tab:%s_cap}\n',index)
fprintf(fileID,'\\end{table}\n')

end

