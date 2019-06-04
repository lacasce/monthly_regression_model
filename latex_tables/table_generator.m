clear
close all
clc

indices={'large','mid','small'};

for i = 1:3

load(strcat('table_',indices{i},'_agg.mat'));
lm_agg = lm;
p_agg = p_values;
load(strcat('table_',indices{i},'_sep.mat'))
lm_sep = lm;
p_sep = p_values;


filename = strcat('table_',indices{i},'_agg.txt');

regression_table(filename,lm_agg,lm_sep,p_agg,p_sep,convertCharsToStrings(indices{i}));


end

fprintf('Table generation complete\n\n')