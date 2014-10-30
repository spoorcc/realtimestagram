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

AE_FUZZ_DIFF=0.5

function create_diff_image {
    compare -metric AE -fuzz $AE_FUZZ_DIFF    \
            ${ACTUAL_FILE} ${EXPECTED_FILE} ${DIFF_FILE}
}

function create_normalized_diff_image {
    composite ${ACTUAL_FILE} ${EXPECTED_FILE}  \
             -compose difference ${DIFF_FILE}.tmp

    convert ${DIFF_FILE}.tmp -auto-level ${DIFF_FILE}

    rm -f ${DIFF_FILE}.tmp
}

function create_diff_mask {
    convert ${ACTUAL_FILE} ${EXPECTED_FILE} -compose difference -composite \
            -threshold 0 -separate -evaluate-sequence Add \
            ${DIFF_FILE}
}

function create_diff_statistics {

        printf "\n======================= Comparison =======================\n"
        printf "Actual image:\t%s\n" ${ACTUAL_FILE}
        printf "Expected image:\t%s\n" ${EXPECTED_FILE}

        printf "\nDifferences:\n"
        convert ${ACTUAL_FILE} ${EXPECTED_FILE} -compose Difference -composite \
                -colorspace gray -verbose info: |\
                sed -n '/statistics:/,/^  [^ ]/ p'

        printf "\n======================= Metrics =======================\n"
        printf "Mean Absolute Error:\t\t "
        compare -metric MAE ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nRoot Mean Square Error:\t\t "
        compare -metric RMSE ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nPeak Signal Noise Ratio:\t "
        compare -metric PSNR ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nNormalized Cross Correlation:\t "
        compare -metric NCC ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1
        printf "\n\n"
}

function usage {

    printf "\n"
    printf "compare_image.sh -a <file_path> -e <file_path> [opts] (--create_diff_image)\n"
    printf "\n"
    printf "\tOptions:\n"
    printf "\t\t-a\t Actual file name [MANDATORY]\n"
    printf "\t\t-e\t Expected file name [MANDATORY]\n"
    printf "\t\t-d\t Difference file name [MANDATORY]\n"
    printf "\t\t-u\t Print this message\n"
    printf "\n"
    printf "\tActions:\n"
    printf "\t\t--create_diff_image\n"
    printf "\t\t                  Creates an diference image between actual and expected\n"
    printf "\n"
}

while getopts :ua:e:d:-: option
do
    case "$option" in
    u)
         usage
         ;;
    a)  
         ACTUAL_FILE=$OPTARG
         DIFF_FILE="$OPTARG"_DIFF.pnm
         ;;
    e)  
         EXPECTED_FILE=$OPTARG
         ;;
    d)  
         DIFF_FILE=$OPTARG
         ;;
    -)
         case "${OPTARG}" in
             create_diff_image)
                create_diff_image
                ;;
             create_norm_diff_image)
                create_normalized_diff_image
                ;;
             create_diff_mask)
                create_diff_mask
                ;;
             create_diff_stats)
                create_diff_statistics
                ;;

             *)
                if [ "$OPTERR" = 1 ] && [ "${optspec:0:1}" != ":" ]; then
                    echo ""
                    echo "Unknown option --${OPTARG}" >&2
                    usage
                    exit 1
                fi
                ;;
         esac;;
    *)
        echo ""
        echo "ERROR: Invalid option: -${OPTARG}" 
        usage
        exit 1
        ;;
        esac
done

