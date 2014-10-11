#!/bin/bash

output_image=$1.pgm
bits=8
width=640 
height=480

# Creates an ascii based pgm gray image where all color channels are averaged into single gray channel 
convert $1                                      \
        -resize ${width}x${height}\!            \
        -compress none -depth ${bits}           \
        -set colorspace Gray -separate -average \
        ${output_image}

cat ${output_image} | sed 1,3d | sed 's/ \+/\n/g' | sed '/^$/d' > ${output_image}.txt

