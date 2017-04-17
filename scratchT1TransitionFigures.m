close all
clearvars

load('Summary.mat')

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
errorbar(g_list, T1ave, T1std)
hold on
errorbar(g_list, T1aveNoMR, T1stdNoMR)
legend({'Mitotic Rounding', 'No Mitotic Rounding'})
xlabel('Growth Rate (divisions per hour)')
ylabel('T1 transitions per hour per 60 cells')