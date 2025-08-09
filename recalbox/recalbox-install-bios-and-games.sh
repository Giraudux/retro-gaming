#!/bin/sh

# Exit on error
set -e

# Constants
readonly ia_bios_identifier="bios-recalbox-9.2.3-rabbits-games"
readonly ia_bios_file="Bios-Recalbox-9.2.3-Rabbits-Games.zip"
readonly ia_games_identifier="recalbox-9-discovery-romset"
readonly ia_games_files="3do.zip \
                         amiga1200.zip \
                         amiga600.zip \
                         amigacd32.zip \
                         amigacdtv.zip \
                         amstradcpc.zip \
                         apple2.zip \
                         apple2gs.zip \
                         atari2600.zip \
                         atari5200.zip \
                         atari7800.zip \
                         atari800.zip \
                         atarist.zip \
                         atomiswave.zip \
                         bbcmicro.zip \
                         bk.zip \
                         c64.zip \
                         channelf.zip \
                         colecovision.zip \
                         daphne.zip \
                         dos.zip \
                         dragon.zip \
                         dreamcast.zip \
                         fbneo.zip \
                         fds.zip \
                         gamegear.zip \
                         gb.zip \
                         gba.zip \
                         gbc.zip \
                         gx4000.zip \
                         intellivision.zip \
                         jaguar.zip \
                         lynx.zip \
                         mame.zip \
                         mastersystem.zip \
                         megadrive.zip \
                         model3.zip \
                         msx1.zip \
                         msx2.zip \
                         msxturbor.zip \
                         n64.zip \
                         naomi.zip \
                         nds.zip \
                         neogeo.zip \
                         nes.zip \
                         ngpc.zip \
                         o2em.zip \
                         openbor.zip \
                         oricatmos.zip \
                         pc88.zip \
                         pc98.zip \
                         pcengine.zip \
                         pcenginecd.zip \
                         pcfx.zip \
                         pokemini.zip \
                         psp.zip \
                         psx.zip \
                         saturn.zip \
                         scummvm.zip \
                         scv.zip \
                         sega32x.zip \
                         segacd.zip \
                         sg1000.zip \
                         snes.zip \
                         solarus.zip \
                         spectravideo.zip \
                         supervision.zip \
                         thomson.zip \
                         ti994a.zip \
                         tic80.zip \
                         trs80coco.zip \
                         uzebox.zip \
                         vectrex.zip \
                         vic20.zip \
                         virtualboy.zip \
                         wswan.zip \
                         wswanc.zip \
                         x1.zip \
                         x68000.zip \
                         zxspectrum.zip"

#                         gamecube.zip \
#                         ps2.zip \
#                         wii.zip \

# Variables
debug=false
destination=
username=
password=

printf_usage() {
  echo "Usage: $0: [-d] [-u IA_USERNAME] [-p IA_PASSWORD] -o DESTINATION"
  echo "  -d              Enable debug"
  echo "  -u IA_USERNAME  Internet Archive username"
  echo "  -p IA_PASSWORD  Internet Archive password"
  echo "  -o DESTINATION  Destination directory"
  echo
  echo "Example:"
  echo "  $0 -u my_username -p my_password -o /media/\$USER/SHARE"
}

# Parse args
while getopts "du:p:o:" "opt"
do
  case $opt in
    d)
      set -x
      debug=true
      ;;
    u)
      username="$OPTARG"
      ;;
    p)
      password="$OPTARG"
      ;;
    o)
      destination="$OPTARG"
      ;;
    ?)
      printf_usage
      exit
      ;;
  esac
done

# Check destination directory
if [ ! -d "$destination" ]
then
  echo "Error: \"$destination\" is not a valid directory."
  printf_usage
  exit
fi

# Prepare tmp directory
readonly tmp_dir=$(mktemp --directory)
cleanup_hook() {
  rm --recursive --force "$tmp_dir"
}
trap cleanup_hook EXIT

# Setup Internet Archive cli
wget --directory-prefix="$tmp_dir" "https://archive.org/download/ia-pex/ia"
readonly ia_bin="$tmp_dir/ia"
chmod +x "$ia_bin"
if [ -z "$username" ] || [ -z "$password" ]
then
  "$ia_bin" configure
else
  "$ia_bin" configure --username "$username" --password "$password"
fi

# Prepare download directory
readonly download_dir="$tmp_dir/download/"
mkdir --parents "$download_dir"

# Download and install bios
"$ia_bin" download --no-directories --destdir "$download_dir" "$ia_bios_identifier" "$ia_bios_file"
unzip "$download_dir/"*".zip" -d "$download_dir"
cp --recursive --force --verbose "$download_dir/"*/* "$destination"
rm --recursive "$download_dir/"*

# Download and install games
set -- $ia_games_files
for game in "$@"
do
  "$ia_bin" download --no-directories --destdir "$download_dir" "$ia_games_identifier" "$game"
  unzip -o "$download_dir/"*".zip" -d "$destination/roms"
  rm "$download_dir/"*".zip"
done
