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
    echo "`basename $0` [-r] playlist.m3u dest_folder"
    echo "  -r  rename all files in ####.mp3"
}

count=0

eval set -- $(getopt -n $0 -o "-r" -- "$@")

rename=0
declare -a files
while [ $# -gt 0 ] ; do
            case "$1" in
                -r) rename=1 ; shift ;;
                --) shift ;;
                -*) echo "bad option '$1'";usage ; exit 1 ;;
                *) files=("${files[@]}" "$1") ; shift ;;
            esac
done

if [ ${#files[@]} -ne 2 ] ; then
     echo "Playlist and output dir are required."
     usage
     exit 1
fi

playlist="${files[0]}"

dest_folder="${files[1]}"

IFS=$'\r\n' lines=($(cat ${playlist})) # array

if [ ! -d $dest_folder ]; then
      echo $dest_folder" is not a folder"
      usage
      exit 1
fi

#find size of file
size=${#lines[@]}

number_mp3=0
number_m4a=0
total_number=0

for ((i=0;i<$size;i+=1))
do

     if [[ ${lines[$i]} == \#* ]]
     then
         continue
     fi

    if [ ! -f "${lines[$i]}" ]; then
        echo "File "${lines[$i]}" not found"
        continue
    fi

     if [[ ${lines[$i]} == *m4a ]]
     then
        number_m4a=$((number_m4a+1))
     fi

     if [[ ${lines[$i]} == *mp3 ]]
     then
        number_mp3=$((number_mp3+1))
     fi

     total_number=$((total_number+1))

done

echo "Found "$total_number" files"
echo "Coping "$number_mp3" files to folder "$dest_folder
echo "Converting "$number_m4a" files to folder "$dest_folder

read

for ((i=0;i<$size;i+=1))
do
     if [[ ${lines[$i]} == \#* ]]
     then
         continue
     fi
     
     filename=${lines[$i]##*\/}
     
     count=$((count+1))
     countstr=$(printf "%04d" $count)


    if [ $rename == 1 ] ; then
         newfilename="${dest_folder}/${countstr}.mp3"
     else
         newfilename="${dest_folder}/${countstr}_${filename%\.*}.mp3"
     fi

     if [ ! -f ${newfilename} ]
     then

     if [[ ${lines[$i]} == *mp3 ]]
     then

         echo "copying file "${filename}" to "${newfilename}
         cp "${lines[$i]}" "${newfilename}"
     fi
     
     if [[ ${lines[$i]} == *m4a ]]
     then
    
         echo "converting file "${filename}" to "$newfilename
         
         #avconv -y -i "${lines[$i]}" -acodec libmp3lame -ab 192k "${newfilename}" & #&> /dev/null  &

         #ffmpeg -i "${lines[$i]}" -acodec libmp3lame -ab 192k "${newfilename}" &
         
         rm -f tmp.wav
         ffmpeg -i "${lines[$i]}" tmp.wav

         lame -m j -q $QUALITY -v -V $VBR_QUALITY -b $MIN_BITRATE \
                          -B $MAX_BITRATE -s $SAMPLE_FREQ tmp.wav "${newfilename}"

         python2 -c "
import mutagen
input = mutagen.File(\"${lines[$i]}\", easy = True)
output = mutagen.File(\"${newfilename}\", easy = True)
for tag in [ 'artist', 'album', 'tracknumber', 'genre', 'title' ]:
    value = input.get(tag)
    if value: output[tag] = value[0]
output.save(v1=2)"
         
         
         #wait $!;
     fi
 fi
done

