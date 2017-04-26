[g_ave, MR, measurements] = summarizeT1Frequency(settings);

T1Frequency = [measurements.T1_transition_rate] / settings.cellRadius;

g_ave = g_ave / 3.6;

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
errorbar(g_list, T1ave, T1std, '.r','Linewidth',1,'CapSize',10)
hold on
errorbar(g_list, T1aveNoMR, T1stdNoMR, '.k','Linewidth',1,'CapSize',10)
mdl = fitlm(g_ave(MR), T1Frequency(MR), 'quadratic');
plot(g_regression, mdl.feval(g_regression), '-r','Linewidth',1);
mdlNoMR = fitlm(g_ave(~MR)', T1Frequency(~MR), 'linear');
plot(g_regression, mdlNoMR.feval(g_regression),'-k','Linewidth',1);
legend({'Mitotic Rounding', 'No Mitotic Rounding'})
xlabel('Growth Rate (divisions per cell per hour)')
ylabel('T1 transitions (per cell per hour)')
ylim([0, 5e-4])