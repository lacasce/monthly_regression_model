clear
close all
clc
tic

%%
%SECTION:-------PARAMETERS----------

%Decision variables for what code to execute:
index = "mid";%large mid or small
split_fund_flow=false;
load_excel_files=false;
run_sbic_armax_test=false;
include_AR_lags=true;
split_ETF_trading_ratio=split_fund_flow;%split both or neither
include_VIX = true;
use_fisher_transformation = false;

%maximum values for ARMA lags
p_max = 4;
q_max = 4;

alpha=0.05; %significance level for statistical tests
reset_order = 5; %Number of higher orders to test for in Ramsey's RESET test
bg_lags = 5; %Number of lags to test for in Breusch Godfrey test
diff_taken=0; %Is changed to 1 in script if diff is taken at some point


%%
%SECTION:------LOAD_DATA----------

%first loads directories to path
addpath('daily_raw_data')
addpath('monthly_raw_data')
addpath('MS_Regress')
addpath('output')
addpath('MS_regress\data_files')
addpath('MS_regress\m_Files')
addpath('ARMAX_GARCH_K_SK_Toolbox')

%Read excel files or load from .mat
if load_excel_files
    [sp500_prices,sp400_prices,sp600_prices,sp500_market_cap,sp400_market_cap,sp600_market_cap,ETF_volume,sp500_volume,fund_flow,sp500_names,sp400_names,sp600_names,VIX,timestamps_daily,timestamps_monthly,GSPC_prices] = read_excel_monthly();
else
    load('monthly_raw_data/monthly_raw_data.mat')
end
    
fprintf('\nData loading complete. ')
toc


%%
%SECTION:------CHOOSE_DEPENDENT_VARIABLE----------
if index == "large"
    stock_prices=sp500_prices;
    stock_market_cap=sp500_market_cap;
elseif index == "mid"
    stock_prices=sp400_prices;
    stock_market_cap=sp400_market_cap;
elseif index == "small"
    stock_prices=sp600_prices;
    stock_market_cap=sp600_market_cap;
else
    fprintf('Invalid choice of index.')
end

clear sp500_prices
clear sp400_prices
clear sp600_prices
clear sp500_market_cap
clear sp400_market_cap
clear sp600_market_cap

%%
%SECTION:------CALCULATE_LOG_RETURNS----------

%Find log returns
log_returns = log_return(stock_prices);
GSPC_log_returns = log_return(GSPC_prices);
clear sp500_prices %no longer needed
fprintf('\nLog return calculation complete. ')
toc

%%
%SECTION:------SPLIT_FUND_FLOW----------

if split_fund_flow
    fund_flow = fund_flow(:,2:end)/max(max(fund_flow(:,2:end)));
else
    fund_flow = fund_flow(:,1)/(max(fund_flow(:,1)));
end

%%
%SECTION:------SPLIT_ETF_TRADING_RATIO----------

if split_ETF_trading_ratio
    ETF_volume = ETF_volume(:,2:end);
else
    ETF_volume = ETF_volume(:,1);%/(max(fund_flow(:,1)));
end



%%
%SECTION:------CALCULATE_CORRELATIONS----------

%make time series correlation matrix (3-dim vector), co,co,time
covariance_time_series = cov_time_series(log_returns,timestamps_daily,timestamps_monthly);
fprintf('\nCovariance calculation complete. ')
toc
correlation_time_series = cov_to_corr(covariance_time_series);
fprintf('\nCorrelation calculation complete. ')
toc
clear covariance_time_series %no longer needed

if use_fisher_transformation
    correlation_time_series = fisher_trans(correlation_time_series);
    fprintf('\nFisher transformation calculation complete. ')
    toc
end

%make 1-dim vector of weighted average correlation over time'

weighted_avg_corr = weighted_avg(correlation_time_series,stock_market_cap);
fprintf('\nWeighted average correlation calculation complete. ')
toc
clear correlation_time_series

%%
%SECTION:------CALCULATE_TRADING_RATIO----------

%ETF trading volume divided by sp500 trading volume over time
ETF_trading_ratio = volume_ratio(ETF_volume,sp500_volume);
fprintf('\nEquivalent trading volume calculation complete. ')
toc

%%
%SECTION:------ADF_TESTS---------

fprintf('ADF tests:\n')
if adftest(weighted_avg_corr)
    fprintf('\nweighted_avg_corr is stationary')
else
    fprintf('\nweighted_avg_corr is not stationary')
end
if adftest(VIX)
    fprintf('\nVIX is stationary')
else
    fprintf('\nVIX is not stationary')
end
%If fund flow is split must run adf for every subset
if split_fund_flow
    if adftest(fund_flow(:,1))
        fprintf('\nLarge cap fund flow is stationary')
    else
        fprintf('\nLarge cap fund flow is not stationary')
    end
    if adftest(fund_flow(:,2))
        fprintf('\nMid cap fund flow is stationary')
    else
        fprintf('\nMid cap fund flow is not stationary')
    end
    if adftest(fund_flow(:,3))
        fprintf('\nSmall cap fund flow is stationary')
    else
        fprintf('\nSmall cap fund flow is not stationary')
    end
else
    if adftest(fund_flow)
        fprintf('\nfund_flow is stationary')
    else
        fprintf('\nfund_flow is not stationary')
    end
end
%If ETF ratio is split must run adf for every subset
if split_ETF_trading_ratio
    if adftest(ETF_trading_ratio(:,1))
        fprintf('\nLarge cap ETF_trading_ratio is stationary')
    else
        fprintf('\nLarge cap ETF_trading_ratio is not stationary')
    end
    if adftest(ETF_trading_ratio(:,2))
        fprintf('\nMid cap ETF_trading_ratio is stationary')
    else
        fprintf('\nMid cap ETF_trading_ratio is not stationary')
    end
    if adftest(ETF_trading_ratio(:,3))
        fprintf('\nSmall cap ETF_trading_ratio is stationary')
    else
        fprintf('\nSmall cap ETF_trading_ratio is not stationary')
    end
    if adftest(ETF_trading_ratio(:,4))
        fprintf('\nOther ETF_trading_ratio is stationary')
    else
        fprintf('\nOther ETF_trading_ratio is not stationary')
    end
else
    if adftest(ETF_trading_ratio)
        fprintf('\nETF_trading_ratio is stationary')
    else
        fprintf('\nETF_trading_ratio is not stationary')
    end
end


%%
%SECTION:------FIRST_DIFFERENCES----------
ETF_trading_ratio = differences(ETF_trading_ratio);%Since all the split ETF series are non-stationary can run for entire matrix
VIX = differences(VIX);
diff_taken = 1; %1 if some differences taken, to offset starting range (gives row of zeros)
fprintf('\nDifferences of non-stationary series calculation complete. ')
toc

%%
%SECTION:------ARMA_RESIDUAL_CALCULATION----------

[temp,n]=size(ETF_trading_ratio);
ETF_trading_ratio_res=ETF_trading_ratio;
for i = 1:n %if ETF ratio is split must make arma residuals for each series
    ETF_trading_ratio_res(:,i) = ARMA_residuals(ETF_trading_ratio(:,i),p_max,q_max);
end
fprintf('\nARMA residual calculation complete. ')
toc

%%
%SECTION:------MARKOV_SWITCHING_MODEL----------
%Calculates the probability of being in a recession, one of our explanatory
%variables

dep=GSPC_log_returns(:,1);          % Defining dependent variable from .mat file
constVec=ones(length(dep),1);       % Defining a constant vector in mean equation (just an example of how to do it)
indep=[constVec];                   % Defining some explanatory variables
k=2;                                % Number of States
S=[1 1];                            % Defining which parts of the equation will switch states (column 1 and variance only)
advOpt.distrib='Normal';            % The Distribution assumption ('Normal', 't' or 'GED')
advOpt.std_method=1;                % Defining the method for calculation of standard errors. See pdf file for more details
advOpt.doPlots=0;                   % Make plots or not.
advOpt.printIter=0;                 % Print iterations.
advOpt.printOut=0;                  % Print output.

[Spec_Out]=MS_Regress_Fit(dep,indep,k,S,advOpt); % Estimating the model
recession = Spec_Out.smoothProb(:,2);

markov_parameters = zeros(3,3);
for i = 1:2
    markov_parameters(i,1) = Spec_Out.Coeff.S_Param{1,1}(i);
    markov_parameters(i,2) = sqrt(Spec_Out.Coeff.covMat{i});
    markov_parameters(i,3) = markov_parameters(i,1)/markov_parameters(i,2);
end
markov_parameters(3,1) = mean(GSPC_log_returns);
markov_parameters(3,2) = sqrt(var(GSPC_log_returns));
markov_parameters(3,3) = markov_parameters(3,1)/markov_parameters(3,2);

clear advOpt
clear constVec
clear dep
clear indep
clear k
clear S
clear Spec_Out

fprintf('\nMarkov switching model calculation complete. ')
toc

%%
%SECTION:------ABSOLUTE_VALUE----------
%calculates the absolute value of the fund flow data
fund_flow = abs(fund_flow);
fprintf('\n Absolute value of fund flow calculation complete. ')
toc

%%
%SECTION:------PLOT----------
close all

fig_count=1;

figure(fig_count)
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
datetick('x','mmm,yy','keepticks')
title('Weighted average correlation of S&P500 assets over time')
ylabel('Weigthed average correlation [-1,1]')
xlabel('Time')
saveas(gcf,'figures\weighted_avg_corr.eps','epsc')
fig_count=fig_count+1;

if ~split_ETF_trading_ratio
figure(fig_count)
plot(datenum(timestamps_monthly(1+diff_taken:end)),ETF_trading_ratio_res(1+diff_taken:end))
hold on
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
datetick('x','mmm,yy','keepticks')
title('ETF trading volume divided by S&P500 trading volume over time, first difference')
ylabel('ETF trading volume/S&P500 trading volume')
xlabel('Time')
legend('ETF trading ratio, first difference','S&P 500 weighted average correlation')
saveas(gcf,'figures\ETF.eps','epsc')
fig_count=fig_count+1;

end

figure(fig_count)
plot(datenum(timestamps_monthly(1+diff_taken:end)),VIX(1+diff_taken:end)/100)
hold on
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
datetick('x','mmm,yy','keepticks')
title('VIX over time, first difference')
ylabel('VIX')
xlabel('Time')
legend('VIX, first difference','S&P 500 weighted average correlation')
saveas(gcf,'figures\VIX.eps','epsc')
fig_count=fig_count+1;

if ~split_fund_flow
figure(fig_count)
plot(datenum(timestamps_monthly(1+diff_taken:end)),fund_flow(1+diff_taken:end))
hold on
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
datetick('x','mmm,yy','keepticks')
title('Flows into US index tracking mutual funds over time, normalized')
xlabel('Time')
legend('Absolute fund flows','S&P 500 weighted average correlation')
saveas(gcf,'figures\fund_flows_abs.eps','epsc')
fig_count=fig_count+1;
end


%experimental plot of fund flow including gspc prices
fig = figure(fig_count);
left_color = [1    0    0];
right_color = [0    0   1];
set(fig,'defaultAxesColorOrder',[left_color; right_color]);
yyaxis left
plot(datenum(timestamps_monthly(1+diff_taken:end)),recession(1+diff_taken:end),'r','linewidth',1.5)
hold on
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end),'-r','linewidth',0.5)
ylabel('Markov probability/weighted average correlation')
ylim([0,1.3])
yyaxis right
plot(datenum(timestamps_monthly(1+diff_taken:end)),GSPC_prices(1+diff_taken:end),'-b','linewidth',0.5)
ylabel('S&P 500 price')
datetick('x','mmm,yy','keepticks')
title('Inferred probability of being in a bear market over time')
xlabel('Time')
legend('Markov bear market probability','S&P 500 weighted average correlation','S&P 500 value','location','NorthWest')
saveas(fig ,'figures\recession_with_gspc.eps','epsc')
fig_count=fig_count+1;

figure(fig_count)
plot(datenum(timestamps_monthly(1+diff_taken:end)),recession(1+diff_taken:end),'r')
hold on
plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end),'b')
datetick('x','mmm,yy','keepticks')
title('Inferred probability of being in a bear market over time')
ylabel('Bear market probability [0,1]')
xlabel('Time')
ylim([0,1])
legend('Markov bear market probability','S&P 500 weighted average correlation')
saveas(gcf,'figures\recession.eps','epsc')
fig_count=fig_count+1;

if split_fund_flow %plots of all ff splits and etf splits
    figure(fig_count) %ETF
    plot(datenum(timestamps_monthly(1+diff_taken:end)),ETF_trading_ratio_res(1+diff_taken:end,1))
    hold on
    for i = 2:4
        plot(datenum(timestamps_monthly(1+diff_taken:end)),ETF_trading_ratio_res(1+diff_taken:end,i))
    end
    %plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
    datetick('x','mmm,yy','keepticks')
    title('ETF trading volume divided by S&P500 trading volume over time, first difference')
    ylabel('ETF trading volume/S&P500 trading volume')
    xlabel('Time')
    legend('Large cap ETF trading ratio, first difference','Mid cap ETF trading ratio, first difference','Small cap ETF trading ratio, first difference','Other ETF trading ratio, first difference')
    saveas(gcf,'figures\ETF_split.eps','epsc')
    fig_count=fig_count+1;
    
    figure(fig_count) % fund flow
    plot(datenum(timestamps_monthly(1+diff_taken:end)),fund_flow(1+diff_taken:end,1))
    hold on
    for i = 2:3
        plot(datenum(timestamps_monthly(1+diff_taken:end)),fund_flow(1+diff_taken:end,i))
    end
    %plot(datenum(timestamps_monthly(1+diff_taken:end)),weighted_avg_corr(1+diff_taken:end))
    datetick('x','mmm,yy','keepticks')
    title('Flows into US index tracking mutual funds over time, normalized')
    xlabel('Time')
    legend('Absolute large cap fund flows','Absolute mid cap fund flows','Absolute small cap fund flows')
    saveas(gcf,'figures\fund_flows_split_abs.eps','epsc')
    fig_count=fig_count+1;
    
end

fprintf('\nPlotting complete.')
toc

%%
%SECTION:-----CREATING_EXPLANATORY_VARIABLE_MATRIX----------

%Create matrix of explanatory variables for regression

if include_VIX
    X=[fund_flow ETF_trading_ratio_res VIX recession]; 
else
    X = [fund_flow ETF_trading_ratio_res recession];
end


%%
%SECTION:-----CORRELATION_MATRIX----------
cor_mat = corr(X);

%%
%SECTION:------SBIC_ARMAX----------
if run_sbic_armax_test
    options = load('options.mat');
    options = options.options;
    options.OutputResults = 'off';
    [p_armax,q_armax] = sbic_armax(weighted_avg_corr(1+diff_taken:end),X(1+diff_taken:end,:),options,p_max,q_max);
    fprintf('SBIC criterion run on ARMAX model. p = %d, q = %d',p_armax,q_armax)

    options.OutputResults = 'on';
    [parameters, stderrors, LLF, ht, resids, summary] = garch1(weighted_avg_corr(1+diff_taken:end), 'GARCH', 'GAUSSIAN', p_armax, q_armax, X(1+diff_taken:end,:), 0, 0, 0, [], options);
else
    p_star = 3; %result of running the code in the if part
end

%%
%SECTION:------REGRESSION----------
%X = [ones(size(weighted_avg_corr)) ETF_trading_ratio VIX(:,5)]; %VIX adjusted close in column 5
%[Mdl,FitInfo] = fitrlinear(X,weighted_avg_corr);

if include_AR_lags
    X_ar = [X create_AR_lags(weighted_avg_corr,p_star)]; 
    index_start = max([1+diff_taken 1+p_star]);
    lm = fitlm(X_ar(index_start:end,:),weighted_avg_corr(index_start:end),'linear');
    fprintf('\nAR regression completed. ')
    toc

    lm
    fprintf('\nx1: fund flows, x2: ETF trading ratio residuals, x3: VIX, x4: probability of recession, x5: AR1, x6: AR2, x7: AR3\n')
else
    index_start = 1+diff_taken;
    lm = fitlm(X(1+diff_taken:end,:),weighted_avg_corr(1+diff_taken:end),'linear');
    fprintf('\nRegression completed. ')
    toc
    
    lm
    fprintf('\nx1: fund flows, x2: ETF trading ratio residuals, x3: probability of recession, x4: VIX\n')
end


%%
%Section: HAC

[hacCov, hacSE, hacCoeff] = hac(X_ar(index_start:end,:),weighted_avg_corr(index_start:end),'type','HC');
hacTstats = hacCoeff./hacSE;
hacPvalues = hacTstats;
for i = 1:length(hacTstats)
    hacPvalues(i) = tcdf(hacTstats(i),length(X_ar(:,1))-index_start);
    hacPvalues(i) = min(hacPvalues(i),1-hacPvalues(i));
end

%%
%SECTION:------TESTS----------

%first create residuals vector
residuals = table2array(lm.Residuals(:,1)); %extracts the raw residuals and converts to a column vector

[h_jb,p_jb,jb_stat]=jbtest(residuals,alpha);
fprintf('\nJerque Bera test:\nDecision on if we reject the null of normality: %d (0 equals normality). P-value: %.3f\n',h_jb,p_jb)

[h_white,p_white] = whites_test(residuals,X(index_start:end,:),alpha);
fprintf('\nWhites test:\nDecision on if we reject the null of homoscedasticity: %d (0 equals homoscedasticity). P-value: %.3f\n',h_white,p_white)

[h_bg,p_bg] = bgtest(bg_lags,alpha,residuals,X(index_start:end,:));
fprintf('\nBreusch Godfrey test:\nDecision on if we reject the null of no autocorrelation: %d (1 equals autocorrelation). P-value: %.3f\n',h_bg,p_bg)

[h_reset,p_reset] = RESET(weighted_avg_corr(index_start:end),lm.Fitted,X(index_start:end,:),reset_order,alpha);
fprintf('\nRamseys RESET test:\nDecision on if we reject the null of correct functional form: %d (0 equals correct form). P-value: %.15f\n',h_reset,p_reset)

p_values= [p_jb,p_white,p_bg,p_reset];

%%
%--------SECTION: SAVE_DATA_FOR_TABLE----------
data_filename = strcat("latex_tables\table_",index);
if split_fund_flow==true
    data_filename = strcat(data_filename,"_sep");
else
    data_filename = strcat(data_filename,"_agg");
end
save(data_filename,'lm','p_values')





