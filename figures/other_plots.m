clear
close all
clc
tic

load('wacs.mat')

figure(1)
plot(datenum(timestamps_monthly(1:end)),large_wac(1:end))
hold on
plot(datenum(timestamps_monthly(1:end)),mid_wac(1:end))
plot(datenum(timestamps_monthly(1:end)),small_wac(1:end))
datetick('x','mmm,yy','keepticks')
title('Weighted average of assets in S&P500, S&P400 and S&P600')
ylabel('Weigthed average correlation [-1,1]')
xlabel('Time')
legend('Large cap weighted average correlation','Mid cap weighted average correlation','Small cap weighted average correlation')
saveas(gcf,'figures\wac_all_markets.eps','epsc')