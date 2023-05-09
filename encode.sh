#!/bin/sh
#brew install ffmpeg
#brew install imagemagick

function handleopts {
  while test "$1" != ""; do
    #echo "p: $1"
    case "$1" in
        -i|--input) INPUT_FILE=$2; shift ;;
        -o|--output) OUTPUT_FILE=$2; shift ;;
        -s|--speed) SPEED_FACTOR=$2; shift ;;
        -g|--gif) GIF_FILE=true; shift ;;
        -l|--low) LOW_RESOLUTION=true; shift ;;
        -te|--trimend) TRIM_EOF_DURATION=$2; shift ;;
        -t|--threads) NUMBER_OF_THREADS=$2; shift ;;
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
NUMBER_OF_THREADS=8 # Default is 4 threads
TRIM_EOF_DURATION=0 # Default is 0.0 second trimmed from EOF
INPUT_FILE=""
OUTPUT_FILE=""

handleopts "$@"

RECORDINGS_DIRECTORY="/Users/viitanener/Pictures/Screenshots" # predefined directory of recordings

# when no input file, use last recording
if test "$INPUT_FILE" == ""; then
   LAST_RECORDING=$(ls -1t $RECORDINGS_DIRECTORY/*.mov | head -1)
else
   LAST_RECORDING=$INPUT_FILE
fi

FILE_RAW=$LAST_RECORDING
FILENAME_NO_SPACES=$(echo "${FILE_RAW// /-}")
eval "mv -fv '$FILE_RAW' $FILENAME_NO_SPACES" # remove spaces from filename by renaming the input file

BASE_PATH=$RECORDINGS_DIRECTORY
FILENAME_EXT="$(basename "${FILENAME_NO_SPACES}")"
FILENAME_ONLY="${FILENAME_EXT%.*}"
EXT_ONLY="${FILENAME_EXT##*.}" # Or hardcode it like "mp4"
FILENAME_ONLY_PATH="${BASE_PATH}/${FILENAME_ONLY}"


if [ $GIF_FILE ]; then
  OUTPUT_FILE_EXT="${FILENAME_ONLY_PATH}.gif"
else
  OUTPUT_FILE_EXT="${FILENAME_ONLY_PATH}.mp4"
fi

INPUT_DURATION=$(ffprobe -v error -select_streams v:0 -show_entries stream=duration -of default=noprint_wrappers=1:nokey=1 "${FILENAME_ONLY_PATH}.${EXT_ONLY}")
INPUT_DURATION=$(bc <<< "$INPUT_DURATION"/"$SPEED_FACTOR")
OUTPUT_DURATION=$(bc <<< "$INPUT_DURATION"-"$TRIM_EOF_DURATION")

echo "SPEED_FACTOR $SPEED_FACTOR"
echo "NUMBER_OF_THREADS $NUMBER_OF_THREADS"
echo "TRIM_EOF_DURATION $TRIM_EOF_DURATION"
echo "FILE_RAW $FILE_RAW"
echo "BASE_PATH $BASE_PATH"
echo "FILENAME_EXT $FILENAME_EXT"
echo "FILENAME_ONLY $FILENAME_ONLY"
echo "EXT_ONLY $EXT_ONLY"
echo "FILENAME_ONLY_PATH $FILENAME_ONLY_PATH"
echo "OUTPUT_FILE $OUTPUT_FILE_EXT"
echo "INPUT/OUTPUT_DURATION $INPUT_DURATION/$OUTPUT_DURATION"

if [ $GIF_FILE ]; then
  if [ $LOW_RESOLUTION ]; then
    ffscript="ffmpeg -i $FILENAME_NO_SPACES -threads $NUMBER_OF_THREADS -t '$OUTPUT_DURATION' -vf 'setpts=(PTS-STARTPTS)/${SPEED_FACTOR}' -af atempo=$SPEED_FACTOR -pix_fmt rgb24 -r 5 -f gif $OUTPUT_FILE_EXT"
  else
    ffscript="ffmpeg -i $FILENAME_NO_SPACES -r 23.976 -threads $NUMBER_OF_THREADS -t '$OUTPUT_DURATION' -vf 'setpts=(PTS-STARTPTS)/${SPEED_FACTOR}' -af atempo=$SPEED_FACTOR $OUTPUT_FILE_EXT && gifsicle -O3 $OUTPUT_FILE_EXT -o $OUTPUT_FILE_EXT"
  fi
else
  ffscript="ffmpeg -i $FILENAME_NO_SPACES -r 23.976 -threads $NUMBER_OF_THREADS -t '$OUTPUT_DURATION' -vf 'setpts=(PTS-STARTPTS)/${SPEED_FACTOR}' -af atempo=$SPEED_FACTOR $OUTPUT_FILE_EXT"
fi
echo "\n-----------------------------------------------------------------------------------"
echo "$ffscript"
echo "-----------------------------------------------------------------------------------\n"
eval $ffscript
retVal=$?
if [ $retVal -eq 0 ]; then
  terminal-notifier -message "Encoding complete" -execute "open $RECORDINGS_DIRECTORY"
  echo "\nDone. $OUTPUT_FILE_EXT"
fi
