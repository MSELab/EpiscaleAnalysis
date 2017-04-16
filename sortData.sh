#!/bin/bash
directory=Data/Exp1_GrowthAndMR/
unsorted=Data/unsorted/
orphaned=Data/orphaned/

find . -name "*00000.txt" | while read line; do
	name="${line#*Stat_}"
	name="${name%%_00000*}"
	name="${name%%00000*}"
	
	echo "Processing simulation '$name'"
	
	mkdir $directory$name
	mkdir $directory$name/DataOutput
	mkdir $directory$name/Paraview
	
	find $unsorted -name *$name*.txt -print0 | xargs -0 -I files mv files $directory$name/DataOutput/
	find $unsorted -name *$name*.vtk -print0 | xargs -0 -I files mv files $directory$name/Paraview/
done
