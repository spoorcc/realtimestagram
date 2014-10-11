#!/bin/bash

output_image=$1.pgm
 
convert $1 -compress none -depth 8 -set colorspace Gray -separate -average $output_image

