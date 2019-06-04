function [sp500_prices,sp400_prices,sp600_prices,sp500_market_cap,sp400_market_cap,sp600_market_cap,ETF_volume,sp500_volume,fund_flow,sp500_names,sp400_names,sp600_names,VIX,timestamps_daily,timestamps_monthly,GSPC_prices] = read_excel_monthly()

%Adjusted closing price data
[sp500_prices,sp500_prices_text] = xlsread('s_p500_adjusted_close.xlsx','Sheet1');

%Get header and date vectors from sp500_prices matrix
[n,m] = size(sp500_prices_text);
timestamps_daily = sp500_prices_text(2:n,1);
sp500_names = sp500_prices_text(1,2:m);

%midcap
[sp400_prices,sp400_prices_text] = xlsread('sp400_daily_adj_close.xlsx','Sheet1');

%Get header and date vectors from sp400_prices matrix
sp400_prices = sp400_prices(:,3:end);
[n,m] = size(sp400_prices_text);
sp400_names = sp400_prices_text(1,2:m);

%smallcap
[sp600_prices,sp600_prices_text] = xlsread('sp600_daily_adj_close.xlsx','Sheet1');

%Get header and date vectors from sp500_prices matrix
sp600_prices = sp600_prices(:,3:end);
[n,m] = size(sp600_prices_text);
sp600_names = sp600_prices_text(1,2:m);

%Data for market cap
sp500_market_cap = xlsread('s_p500_market_cap_cleaned_dates_monthly.xlsx','monthly');

sp400_market_cap = xlsread('sp400_mcap.xlsx','monthly'); %mid cap

sp600_market_cap = xlsread('sp600_mcap.xlsx','monthly'); %small cap

%Data for ETF_volume and ETF names
ETF_volume = xlsread('ETF_volume_USD_Jason_monthly.xlsx','Overview');
ETF_volume=ETF_volume(:,3:end);

%Data for S&P500_volume
sp500_volume = xlsread('S_P 500 usd_volume 05-18 from yahoo_monthly.xlsx','monthly');

%Data for index fund flows
[fund_flow,fund_flow_text] = xlsread('Fund_Flows_monthly.xlsx','Consolidated');%row 1 is total, 2 is high cap, 3 is mid cap and 4 is small cap

%Get monthly date vector
[n,m] = size(fund_flow_text);
timestamps_monthly = date_format(fund_flow_text(2:n,1)); %This data has wrong format, run correctional function

%VIX
VIX = xlsread('VIX_monthly.xlsx','monthly');

%^GSPC
GSPC_prices = xlsread('GSPC_monthly.xlsx','monthly');

end