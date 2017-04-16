#!/bin/bash
for simNumber in "2" "3"
do
for sourceFolder in "dataOutputold" "dataOutputold2"
do
# Make experimental directories
mkdir Experiment2_GrowthAndMR/Growth_0.1_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.2_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.4_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.8_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_1.6_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_3.2_noMR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.1_MR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.2_MR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.4_MR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_0.8_MR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_1.6_MR_$simNumber
mkdir Experiment2_GrowthAndMR/Growth_3.2_MR_$simNumber
# Move data from folder
mv $sourceFolder/*Growth_0.1_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_0.1_noMR_$simNumber/
mv $sourceFolder/*Growth_0.2_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_0.2_noMR_$simNumber/
mv $sourceFolder/*Growth_0.4_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_0.4_noMR_$simNumber/
mv $sourceFolder/*Growth_0.8_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_0.8_noMR_$simNumber/
mv $sourceFolder/*Growth_1.6_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_1.6_noMR_$simNumber/
mv $sourceFolder/*Growth_3.2_NoMR_$simNumber* Experiment2_GrowthAndMR/Growth_3.2_noMR_$simNumber/
mv $sourceFolder/*Growth_0.1_MR_$simNumber* Experiment2_GrowthAndMR/Growth_0.1_MR_$simNumber/
mv $sourceFolder/*Growth_0.2_MR_$simNumber* Experiment2_GrowthAndMR/Growth_0.2_MR_$simNumber/
mv $sourceFolder/*Growth_0.4_MR_$simNumber* Experiment2_GrowthAndMR/Growth_0.4_MR_$simNumber/
mv $sourceFolder/*Growth_0.8_MR_$simNumber* Experiment2_GrowthAndMR/Growth_0.8_MR_$simNumber/
mv $sourceFolder/*Growth_1.6_MR_$simNumber* Experiment2_GrowthAndMR/Growth_1.6_MR_$simNumber/
mv $sourceFolder/*Growth_3.2_MR_$simNumber* Experiment2_GrowthAndMR/Growth_3.2_MR_$simNumber/
done
done