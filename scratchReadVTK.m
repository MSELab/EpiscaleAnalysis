
dirName = 'C:\Users\Pavel\Documents\GitHub\EpiscaleAnalysis\Data\Exp1_GrowthAndMR\Growth_3.2_noMR_1\Paraview\WingDisc_Growth_3.2_NoMR_1_';

for fr = 0:5:1252
    fr
    [coord{fr+1}, cellNumber{fr+1}] = extractVtkData(fr, dirName);
end