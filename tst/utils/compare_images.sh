#!/usr/bin/env bash
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

## @var AE_FUZZ_DIFF
## @brief The Absolute Error fuzz difference factor 
declare AE_FUZZ_DIFF=0.5

## @fn psnr()
## @brief Compares on PSNR based on given threshold
psnr() {

    result=$(compare -metric PSNR "${ACTUAL_FILE}" "${EXPECTED_FILE}" null: 2>&1)

    check_limits "PSNR" "$result" "$THRESHOLD"

    return $?
}

## @fn check_limits()
## @brief Compares value versus threshold
## @param metric_name String used for printing result message
## @param value       Value (can also be inf)
## @param threshold
## Compares "value > threshold" print a message of the result and returns
## @retval 0 value is above threshold
## @retval 1 value is equal to or lower then threshold
check_limits() {

    metric_name="$1"
    result="$2"
    threshold="$3"

    if [ "$result" = "inf" ]
    then
        result="9999.99"
    fi

    if [ $(echo "$result > $threshold" | bc) -ne 0 ]
    then
        printf "\tPASS: %s %s is above %s\n" "$metric_name" "$result" "$threshold"
        return 0
    else
        printf "\tFAIL: %s %s is below %s\n" "$metric_name" "$result" "$threshold"
        return 1
    fi
}

## @fn print_metrics()
## @brief Prints difference metrics between actual and expected image
print_metrics() {

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

## @fn print_extended_metrics()
## @brief Prints difference metrics between actual and expected image
print_extended_metrics() {

        printf "\n======================= Metrics =======================\n"
        printf "Mean Absolute Error\n-----------------------------------\n"
        compare -verbose -metric MAE ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nRoot Mean Square Error\n-----------------------------------\n"
        compare -verbose -metric RMSE ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nPeak Signal Noise Ratio\n-----------------------------------\n"
        compare -verbose -metric PSNR ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1

        printf "\nNormalized Cross Correlation\n-----------------------------------\n"
        compare -verbose -metric NCC ${ACTUAL_FILE} ${EXPECTED_FILE} null: 2>&1
        printf "\n\n"
}

## @fn print_comparison_header()
## @brief Prints header with name of actual and expected image
print_comparison_header() {
        printf "\n======================= Comparison =======================\n"
        printf "Actual image:\t%s\n" ${ACTUAL_FILE}
        printf "Expected image:\t%s\n" ${EXPECTED_FILE}
}

## @fn create_diff_image()
## @brief Creates an image with all differences between actual and expected
create_diff_image() {
    compare -metric AE -fuzz $AE_FUZZ_DIFF    \
            ${ACTUAL_FILE} ${EXPECTED_FILE} ${DIFF_FILE}
}

## @fn create_normalized_diff_image()
## @brief Creates a normalized image with all differences between actual and expected
create_normalized_diff_image() {
    composite ${ACTUAL_FILE} ${EXPECTED_FILE}  \
             -compose difference ${DIFF_FILE}.tmp

    convert ${DIFF_FILE}.tmp -auto-level ${DIFF_FILE}

    rm -f ${DIFF_FILE}.tmp
}

## @fn create_diff_mask()
## @brief Creates a difference mask between actual and expected image
create_diff_mask() {
    convert ${ACTUAL_FILE} ${EXPECTED_FILE} -compose difference -composite \
            -threshold 0 -separate -evaluate-sequence Add \
            ${DIFF_FILE}
}

## @fn create_diff_statistics()
## @brief Prints complete metrics of difference between actual and expected image
create_diff_statistics() {

    print_comparison_header
    printf "\nDifferences:\n"
    convert ${ACTUAL_FILE} ${EXPECTED_FILE} -compose Difference -composite \
            -colorspace gray -verbose info: |\
            sed -n '/statistics:/,/^  [^ ]/ p'

    print_metrics
}

## @fn create_diff_statistics_per_channel()
## @brief Prints complete metrics of difference between actual and expected image per channel
create_diff_statistics_per_channel() {

    print_comparison_header

    print_metrics
}

## @fn create_extended_diff_statistics_per_channel()
## @brief Prints complete metrics of difference between actual and expected image per channel
create_extended_diff_statistics_per_channel() {

    print_comparison_header

    print_extended_metrics
}

## @fn usage()
## @brief Prints usage of this shell script
usage() {

    printf "\n"
    printf "compare_image.sh -a <file_path> -e <file_path> [opts] --<action>\n"
    printf "\n"
    printf "\tOptions:\n"
    printf "\t\t-a\t Actual file name [MANDATORY]\n"
    printf "\t\t-e\t Expected file name [MANDATORY]\n"
    printf "\t\t-d\t Difference file name [MANDATORY]\n"
    printf "\t\t-t\t threshold [MANDATORY]\n"
    printf "\t\t-u\t Print this message\n"
    printf "\n"
    printf "\tActions:\n"
    printf "\t\t--psnr\n"
    printf "\t\t     compares based on psnr threshold \n"
    printf "\n"
    printf "\t\t--create_diff_image\n"
    printf "\t\t                  Creates a diference image between actual and expected\n"
    printf "\n"
    printf "\t\t--create_norm_diff_image\n"
    printf "\t\t                  Creates a normalized diference image between actual and expected\n"
    printf "\n"
    printf "\t\t--create_diff_mask\n"
    printf "\t\t                  Creates a binary diference image between actual and expected\n"
    printf "\n"
    printf "\t\t--create_diff_stats\n"
    printf "\t\t                  Prints out information about the difference between the actual and expected image\n"
    printf "\n"
    printf "\t\t--create_diff_stats_per_channel\n"
    printf "\t\t                  Prints out information about the difference between the actual and expected image\n"
    printf "\n"
    printf "\t\t--create_extended_diff_stats_per_channel\n"
    printf "\t\t                  Prints out more information about the difference between the actual and expected image\n"
    printf "\n"
}

while getopts :ua:e:d:t:-: option
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
    t)  
         THRESHOLD=$OPTARG
         ;;
    -)
         case "${OPTARG}" in
             psnr)                                      psnr;;
             create_diff_image)                         create_diff_image;;
             create_norm_diff_image)                    create_normalized_diff_image;;
             create_diff_mask)                          create_diff_mask;;
             create_diff_stats)                         create_diff_statistics;;
             create_diff_stats_per_channel)             create_diff_statistics_per_channel;;
             create_extended_diff_stats_per_channel)    create_extended_diff_statistics_per_channel;;

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

