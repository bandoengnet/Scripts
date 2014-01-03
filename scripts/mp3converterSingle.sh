#!/bin/bash

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see http://www.gnu.org/licenses/gpl-3.0.html
#  for the full license.

EFAULT_OUTPUT_DIR=/tmp/mp3ify
QUALITY=2
VBR_QUALITY=4
MIN_BITRATE=64
MAX_BITRATE=256
SAMPLE_FREQ=44.1

function usage {
    echo ""
    echo "`basename $0` m4afile "
}

count=0

eval set -- $(getopt -n $0 -o "-r" -- "$@")

declare -a files
while [ $# -gt 0 ] ; do
            case "$1" in
                --) shift ;;
                -*) echo "bad option '$1'";usage ; exit 1 ;;
                *) files=("${files[@]}" "$1") ; shift ;;
            esac
done

if [ ${#files[@]} -ne 1 ] ; then
     echo "Filename is required."
     usage
     exit 1
fi

filem4a="${files[0]}"


newfilename="${filem4a%\.*}.mp3"

echo $newfilename

if [ ! -f "${newfilename}" ]
then

     
     if [[ ${filem4a} == *m4a ]]
     then
    
         echo "converting file "${filem4a}" to "$newfilename
         
         avconv -y -i "${filem4a}" -acodec libmp3lame -ab 192k "${newfilename}" & #&> /dev/null  &

         #ffmpeg -i "${lines[$i]}" -acodec libmp3lame -ab 192k "${newfilename}" &
         
         wait $!;
     fi
 fi
