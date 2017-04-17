#!/bin/bash
# This script downsamples vtk files to 1/5th of the set output frequency
echo "This script is going to delete 4/5 of your vtk files, leaving only files ending in 0 or 5."
read -p "You are about to lose a lot of data. Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
	cd Data/unsorted/
	echo "removing vtk files ending with 1"
		find . -name "*1.vtk" -delete
	echo "removing vtk files ending with 2"
		find . -name "*2.vtk" -delete
	echo "removing vtk files ending with 3"
		find . -name "*3.vtk" -delete
	echo "removing vtk files ending with 4"
		find . -name "*4.vtk" -delete
	echo "removing vtk files ending with 6"
		find . -name "*6.vtk" -delete
	echo "removing vtk files ending with 7"
		find . -name "*7.vtk" -delete
	echo "removing vtk files ending with 8"
		find . -name "*8.vtk" -delete
	echo "removing vtk files ending with 9"
		find . -name "*9.vtk" -delete
fi
