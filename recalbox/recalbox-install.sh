#!/bin/sh

# Exit on error
set -e

# Constants
readonly recalbox_img_url_tpl="https://upgrade.recalbox.com/latest/download-wizard/%s/recalbox-%s.img.xz"

# Variables
debug=false
platform=
device=
recalbox_img_url=

printf_usage() {
  printf "Usage: %s: [-d] -p PLATFORM DEVICE\n" "$0"
  printf "  -d           Enable debug\n"
  printf "  -p PLATFORM  Platform, one of: rpi1, rpi2, rpizero2, rpi3, rpi4_64, rpi5_64, etc.\n"
  printf "Example:\n"
  printf "  %s /dev/mmcblk0\n" "$0"
}

# Parse args
while getopts "dp:" "opt"
do
  case $opt in
    d)
      set -x
      debug=true
      ;;
    p)
      platform="$OPTARG"
      ;;
    ?)
      printf_usage
      exit
      ;;
  esac
done

# Check arguments
if [ -z "$platform" ]
then
    printf "Error: missing platform argument.\n"
    printf_usage
    exit
fi

# Check positional arguments
if [ "$OPTIND" -gt "$#" ]
then
    printf "Error: missing positional argument.\n"
    printf_usage
    exit
fi

# Parse positional args
shift "$((OPTIND - 1))"
readonly device="$*"

# Check device
if [ ! -b "$device" ]
then
  printf "Error: \"%s\" is not a valid device.\n" "$device"
  printf_usage
  exit
fi

# Prepare tmp directory
# readonly tmp_dir=$(mktemp --directory)
# cleanup_hook() {
#   rm --recursive --force "$tmp_dir"
# }
# trap cleanup_hook EXIT

sudo umount "$device"*

recalbox_img_url=$(printf "$recalbox_img_url_tpl" "$platform" "$platform")

wget --quiet  --output-document=- "$recalbox_img_url" \
  | xz --decompress --stdout \
  | sudo dd of="$device" status=progress conv=fsync
