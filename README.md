# Encode

Encode screen recording to h264 with ffmpeg

## Prerequisites

Install `ffmpeg` and `terminal-notifier`

```shell
brew install ffmpeg
brew install terminal-notifier
```

## Install

```shell
sudo ln ~/development/encode/encode.sh /usr/local/bin/encode
```

## Usage

```shell
encode
```

or with options

```shell
encode -i "/Users/Macchi/Pictures/Screenshots/Screen-Recording-2022-01-28-at-14.53.38.mov" -te 20 -t 4 -s 2
```

## Options

   - -i | --input) INPUT_FILE, defaults to last .mov file from defined directory
   - -o | --output) OUTPUT_FILE, defaults to input.mp4
   - -s | --speed) SPEED_FACTOR, defaults to 1.5x
   - -te | --trimend) TRIM_EOF_DURATION, defaults to 0 seconds
   - -t | --threads) NUMBER_OF_THREADS, defaults to 4 threads
