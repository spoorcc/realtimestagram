#!/bin/bash

bits=8
width=512 
height=512

# Creates an ascii based pgm gray image where all color channels are averaged into single gray channel 
function create_gray_image {
    output_image=$1.pgm

    convert $1                                      \
            -resize ${width}x${height}\!            \
            -compress none -depth ${bits}           \
            -set colorspace Gray -separate -average \
            ${output_image}
}

function create_color_image {
    output_image=$1.pnm

    convert $1                                      \
            -resize ${width}x${height}\!            \
            -compress none -depth ${bits}           \
            ${output_image}
}

function remove_pgm_header_and_split {
    cat ${output_image} | sed 1,3d | sed 's/ \+/\n/g' | sed '/^$/d' > ${output_image}.txt
}

function remove_pnm_header_and_split {
    cat ${output_image} | sed 1,3d | sed 's/\([0-9]\+ [0-9]\+ [0-9]\+\) /\1\n/g' | sed '/^$/d' > ${output_image}.txt
}

function split {
    cat ${output_image} | sed 1,3!d > ${output_image}.tmp
    cat ${output_image} | sed 1,3d | sed 's/\([0-9]\+ [0-9]\+ [0-9]\+\) /\1\n/g' | sed '/^$/d' >> ${output_image}.tmp

    cp -f ${output_image}.tmp ${output_image}
    rm -f ${output_image}.tmp
}
create_color_image $1
#remove_pnm_header_and_split
split

