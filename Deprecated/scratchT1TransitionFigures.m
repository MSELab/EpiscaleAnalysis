close all
clearvars

load('SummaryT1.mat')

T1Frequency = [measurements.T1_transition_rate];

g_list = unique(g_ave);
for i = 1:length(g_list)
    T1ave(i) = mean(T1Frequency(g_ave == g_list(i) & MR));
    T1aveNoMR(i) = mean(T1Frequency(g_ave == g_list(i) & ~MR));
    T1std(i) = std(T1Frequency(g_ave == g_list(i) & MR));
    T1stdNoMR(i) = std(T1Frequency(g_ave == g_list(i) & ~MR));
    N(i) = sum(g_ave == g_list(i) & MR);
    NNoMR(i) =  sum(g_ave == g_list(i) & ~MR);
end

T1aveNoMR(isnan(T1aveNoMR)) = 0;
T1stdNoMR(isnan(T1aveNoMR)) = 0;

figure(1)
clf
g_regression = linspace(min(g_ave),max(g_ave),1000);
errorbar(g_list, T1ave, T1std, '.r')
hold on
errorbar(g_list, T1aveNoMR, T1stdNoMR, '.k')
mdl = fitlm(g_ave(MR), T1Frequency(MR), 'quadratic');
plot(g_regression, mdl.feval(g_regression), '-r');
mdlNoMR = fitlm([g_ave(~MR)', 0.1,0.1,0.2,0.2,0.3,0.3,0.4,0.4,0.8,0.8]', [T1Frequency(~MR) zeros(1,10)], 'quadratic');
plot(g_regression, mdlNoMR.feval(g_regression),'-k');
legend({'Mitotic Rounding', 'No Mitotic Rounding'})
xlabel('Growth Rate (divisions per hour)')
ylabel('T1 transitions per hour per 60 cells')