#!/bin/bash

for x in `cat listoffolders.txt`

do

#cd $x
#for file in *.HEIC; do heif-convert $file ${file/%.HEIC/.jpg}; done
#mv *.HEIC /home/arun/Downloads/iPhone/allimages_HEIC/
#mv *.jpg /home/arun/Downloads/iPhone/allimages_JPEC/
#mv *.MOV /home/arun/Downloads/iPhone/allMOV

rmdir $x


#cd -

done
