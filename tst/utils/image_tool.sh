#!/bin/sh
#   This file is part of Realtimestagram.
#
#   Realtimestagram is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 2 of the License, or
#   (at your option) any later version.
#
#   Realtimestagram is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with Realtimestagram.  If not, see <http://www.gnu.org/licenses/>.

BITDEPTH=8
WIDTH=512 
HEIGHT=512

# Creates pgm gray image where all color channels are averaged into single gray channel 
function create_gray_image {
    output_image=$1.pgm

    convert ${INPUT_FILE}                           \
            -resize ${WIDTH}x${HEIGHT}\!            \
            -compress none -depth ${BITDEPTH}       \
            -set colorspace Gray -separate -average \
            ${OUTPUT_FILE}
}

# Creates pnm color image
function create_color_image {
    output_image=$1.pnm

    convert ${INPUT_FILE}                           \
            -resize ${WIDTH}x${HEIGHT}\!            \
            -compress none -depth ${BITDEPTH}       \
            ${OUTPUT_FILE}
}

# Split all bit values into single lines
function split_gray {
    cat ${OUTPUT_FILE} | sed 1,3!d > ${OUTPUT_FILE}.tmp
    cat ${OUTPUT_FILE} | sed 1,3d | sed 's/ \+/\n/g' | sed '/^$/d' >> ${OUTPUT_FILE}.tmp

    cp -f ${OUTPUT_FILE}.tmp ${OUTPUT_FILE}
    rm -f ${OUTPUT_FILE}.tmp
}

# Split all rgb values into single lines
function split_color {
    cat ${OUTPUT_FILE} | sed 1,3!d > ${OUTPUT_FILE}.tmp
    cat ${OUTPUT_FILE} | sed 1,3d | sed 's/\([0-9]\+ [0-9]\+ [0-9]\+\) /\1\n/g' | sed '/^$/d' >> ${OUTPUT_FILE}.tmp

    cp -f ${OUTPUT_FILE}.tmp ${OUTPUT_FILE}
    rm -f ${OUTPUT_FILE}.tmp
}

function create_HSV_image {
    
    convert $1 -colorspace HSB -set colorspace RGB $2 
    cat $2 | pnmtoplainpnm > $2.tmp
    
    cp -f $2.tmp $2
    rm -f $2.tmp
}

function split_HSV_image {
    
    HUE=${1}.hue
    SAT=${1}.sat
    VAL=${1}.val

    convert $1 -channel R -separate ${HUE}.tmp 
    cat ${HUE}.tmp | pnmtoplainpnm > ${HUE}
    
    convert $1 -channel G -separate ${SAT}.tmp 
    cat ${SAT}.tmp | pnmtoplainpnm > ${SAT}
    
    convert $1 -channel B -separate ${VAL}.tmp 
    cat ${VAL}.tmp | pnmtoplainpnm > ${VAL}

    rm -f ${HUE}.tmp
    rm -f ${SAT}.tmp
    rm -f ${VAL}.tmp
}


while getopts :h:w:i:o:cgr option
do
    case "$option" in
    d)
         BITDEPTH=$OPTARG
         ;;
    h)
         HEIGHT=$OPTARG
         ;;
    w)
         WIDTH=$OPTARG
         ;;
    i)  
         INPUT_FILE=$OPTARG
         OUTPUT_FILE=$OPTARG.pnm
         ;;
    o)  
         OUTPUT_FILE=$OPTARG.pnm
         ;;
    c)
         COLOR_CONVERSION=1
         ;;
    g) 
         GRAY_CONVERSION=1
         ;;
    r)
         CREATE_REF_IMAGE=1
         ;;
    *)
        echo "Hmm, an invalid option was received. -h, and -w require an argument."
        echo "Here's the usage statement:"
        echo ""
        return
        ;;
        esac
done

if [[ $CREATE_REF_IMAGE -eq 1 ]]; then

   create_HSV_image ${INPUT_FILE} ${OUTPUT_FILE}
   split_HSV_image ${OUTPUT_FILE}

   rm -f ${OUTPUT_FILE}

else
    if [[ $COLOR_CONVERSION -eq $GRAY_CONVERSION ]]; then

        echo "Select either gray with [-g] or color [-c] output images";
        exit 1; 

    fi
fi

if [[ $color_conversion -eq 1 ]]; then
   create_color_image
   split_color
fi

if [[ $gray_conversion -eq 1 ]]; then
   create_gray_image
   split_gray
fi

