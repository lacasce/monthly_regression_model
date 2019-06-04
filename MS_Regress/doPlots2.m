% Plotting time varying probabilities

for i=1:k
    States{i}=['State ',num2str(i)];
end

for i=1:k
    States{i}=['State ',num2str(i)];
end

for i=1:nEq
        myMeanLeg{i}=['Explained Variable #' num2str(i)];
        myStdLeg{i}=['Conditional Std of Equation #' num2str(i)];
end

% figure(1);
% plot(Spec_Output.filtProb);
% xlabel('Time');
% ylabel('Filtered States Probabilities');
% legend(States);

% figurecount = length(findobj('Type','figure'));
% figure(figurecount+1);

figure(1)
plot(smoothProb);
xlabel('Time');
ylabel('Smoothed States Probabilities');
legend(States);

% figurecount = length(findobj('Type','figure'));
% figure(figurecount+1);
% plot(Spec_Output.condMean);
% legend(myLeg);

diff_taken = 1;
timestamps_monthly = load('timestamps_monthly.mat');
timestamps_monthly = timestamps_monthly.timestamps_monthly;

subplot(3,1,1)
plot(datenum(timestamps_monthly(1+diff_taken:end)),dep(1+diff_taken:end));
datetick('x','mmm,yy','keepticks')
legend(myMeanLeg);

subplot(3,1,2);
plot(datenum(timestamps_monthly(1+diff_taken:end)),Spec_Output.condStd(1+diff_taken:end));
datetick('x','mmm,yy','keepticks')
legend(myStdLeg);

subplot(3,1,3);
plot(datenum(timestamps_monthly(1+diff_taken:end)),smoothProb(1+diff_taken:end,:));
datetick('x','mmm,yy','keepticks')
xlabel('Time');
ylabel('Smoothed States Probabilities');
legend(States);

