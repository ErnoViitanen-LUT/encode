#!/bin/sh

function handleopts {
  while test "$1" != ""; do
    #echo "p: $1"
    case "$1" in
        -i1|--input1) INPUT_FILE1=$2; shift ;;
        -i2|--input2) INPUT_FILE2=$2; shift ;;
        -i3|--input3) INPUT_FILE3=$2; shift ;;
        -o|--output) OUTPUT_FILE=$2; shift ;;        
        * )
          #if test "$1" != "$cmd" &&          
            # test "$1" != "$author"; then
           # echo " $1"
          #fi
          shift
          ;;
       
    esac
  done
}

SPEED_FACTOR=1.5 # Default is 1.5 X speed
NUMBER_OF_THREADS=4 # Default is 4 threads
TRIM_EOF_DURATION=0 # Default is 0.0 second trimmed from EOF
INPUT_FILE1=""
INPUT_FILE2=""
INPUT_FILE3=""
OUTPUT_FILE=""

handleopts "$@"

RECORDINGS_DIRECTORY="/Users/Macchi/Pictures/Screenshots" # predefined directory of recordings

tmpfile=$(mktemp /tmp/concat.XXXXXX)

BASE_PATH=$RECORDINGS_DIRECTORY
FILENAME_EXT="$(basename "${INPUT_FILE1}")"
FILENAME_ONLY="${FILENAME_EXT%.*}"
EXT_ONLY="${FILENAME_EXT##*.}" # Or hardcode it like "mp4"
FILENAME_ONLY_PATH="${BASE_PATH}/${FILENAME_ONLY}"

OUTPUT_FILE_EXT="${FILENAME_ONLY_PATH}-out.mp4"

if test "$OUTPUT_FILE" != ""; then
   OUTPUT_FILE_EXT="${BASE_PATH}/${OUTPUT_FILE}"
fi

echo "file '$INPUT_FILE1'" >> $tmpfile;
echo "file '$INPUT_FILE2'" >> $tmpfile;
if test "$INPUT_FILE3" != ""; then
  echo "file '$INPUT_FILE3'" >> $tmpfile;
fi

echo "BASE_PATH $BASE_PATH"
echo "FILENAME_EXT $FILENAME_EXT"
echo "FILENAME_ONLY $FILENAME_ONLY"
echo "EXT_ONLY $EXT_ONLY"
echo "FILENAME_ONLY_PATH $FILENAME_ONLY_PATH"
echo "OUTPUT_FILE $OUTPUT_FILE_EXT"

echo "\nConcat file contents"
cat $tmpfile

ffscript="ffmpeg -f concat -safe 0 -i $tmpfile -c copy '$OUTPUT_FILE_EXT'"
echo "$ffscript"
eval $ffscript
rm $tmpfile
#open $RECORDINGS_DIRECTORY
