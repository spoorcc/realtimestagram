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

TEST_INPUT_FOLDER="tst/input"
TEST_OUTPUT_FOLDER="tst/output"
TEST_SCRIPTING="../../tst/utils"

TESTSET_FOLDER="bld"

## @fn qualify_rgb2hsv_image()
## @brief Qualifies a conversion of rgb to hsv colorspace
## @param INPUT_FILE  file used as input
## @param OUTPUT_FILE file that should be qualified
## Creates a reference image and compares that to the OUTPUT_FILE 
qualify_rgb2hsv_image() {

    INPUT_FILE=$1
    OUTPUT_FILE=$2

    INPUT_FILE_BASE="${INPUT_FILE##*/}"
    REF_FILE="tmp/${INPUT_FILE_BASE%.*}_hsv_ref"

    PSNR_THRESHOLD=13.05

    printf "\n--> Qualifying %s" "$OUTPUT_FILE"

    # Create a reference file
    printf "\n\tCreating reference file"
    $TEST_SCRIPTING/image_tool.sh -i "${INPUT_FILE}" -o "${REF_FILE}"  --create_HSV_image

    # Compare test output with reference file
    printf "\n\tComparing reference file to test output\n"
    $TEST_SCRIPTING/compare_images.sh -a "${OUTPUT_FILE}" -e "${REF_FILE}.pnm"  -t $PSNR_THRESHOLD --psnr

    return $?
}

## @fn run_rgb2hsv_test()
## @brief Runs rgb2hsv test
run_rgb2hsv_test() {

    # Run the test set
    echo "> Running rgb2hsv tests"
    $TESTSET_FOLDER/rgb2hsv_testsets_tb

    RGB2HSV_TEST_RESULT=0

    # Qualify the results
    echo "> Qualifying rgb2hsv tests"
    for image in lenna windmill danger_zone amersfoort rainbow hue_gradient sat_gradient val_gradient
    do
        INPUT_IMAGE="$TEST_INPUT_FOLDER/$image.pnm"
        OUTPUT_IMAGE="$TEST_OUTPUT_FOLDER/rgb2hsv_$image.pnm"

        qualify_rgb2hsv_image $INPUT_IMAGE $OUTPUT_IMAGE

        result=$?

        if [ $result != 0 ]
        then
           RGB2HSV_TEST_RESULT=1
        fi
    done

    return $RGB2HSV_TEST_RESULT
}

run_rgb2hsv_test
RGB2HSV_RESULT=$?

if [[ $RGB2HSV_RESULT -ne 0 ]]
then 
   echo "FAIL: Some tests failed"
   exit 1
else
   echo "PASS: All tests passed"
   exit 0
fi



