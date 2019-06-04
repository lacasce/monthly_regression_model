function [h,p] = whites_test(res,X,alpha)

n = size(X,1); % set number of observations equal to the # of rows in X
k = size(X,2) + 1; % set number of coefficients to # of columns in X plus constant

uhat = res;

% Recall that the test of White (1980) for conditional heteroskedasticity
% involves regressing the squared residuals on all regressors included in
% X, their squares and cross-products, using an auxiliary regression.

% First, define the new data matrix containing regressors for auxiliary
% model, and the new dependent variable:

xmat_whites_test = [ones(n,1) X X.^2 X(:,1).*X(:,2)];
ymat_whites_test = uhat.^2;

% Next, estimate the auxiliary model using OLS:

betahat_whites_test = inv(xmat_whites_test'*xmat_whites_test)*(xmat_whites_test'*ymat_whites_test);

% Recall that the test statistic for the test of White (1980) is n*R^2,
% where R^2 is the coefficient of determination from the auxiliary
% regression, and n is the sample size as before.

R2_auxiliary_regression = sum((xmat_whites_test*betahat_whites_test - mean(ymat_whites_test)).^2)/...
    sum((ymat_whites_test - mean(ymat_whites_test)).^2); % R^2 from auxiliary regression

whites_test_statistic = n*R2_auxiliary_regression; % White's test statistic

% Recall that under H0 of homoskedasticity, this statistic asymptotically
% follows a Chi-Squared distribution with (p-1) degrees of freedom, where
% p is the number of columnts in the auxiliary regression data matrix.

% To carry out the test, look up corresponding cricical value, and reject
% if whites_test_statistic > critical value.

% If you have MATLAB's Statistics Toolbox installed, you can obtain the
% critical value using the chi2inv() function (see help for more info.):

level_of_significance = alpha;
whites_critical_value = chi2inv(1-level_of_significance,size(xmat_whites_test,2) - 1);

p = 1-chi2cdf(whites_test_statistic,size(xmat_whites_test,2) - 1);
h = whites_test_statistic > whites_critical_value;