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

# This program was written by Dominic Hosler dom@dominichosler.co.uk
# There is a description of how it works on my blog http://dominichosler.wordpress.com
# Please ask on the blog if you have any questions, thank you.

#setup song count so order is preserved
count=0

#necessary to fill an array first, because ffmpeg messes with the standard input and output.
#It is not the waiting that is the problem, it is ffmpeg using the input and output that removes
# the next so much of the input lines, however if all the input is done into an array before
# ffmpeg is called, it runs perfectly.

EXPECTED_ARGS=2
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
      echo "Usage: `basename $0` playlist.m3u destination_folder"
      exit $E_BADARGS
fi


#store old IFS so can return it at the end
old_IFS=$IFS
#set IFS to newline
IFS=$'\n'
#store an array filled with each line of the file.
lines=($(cat $1)) # array
#replace the old IFS
IFS=$old_IFS

dest_folder=$2

if [ ! -d $dest_folder ]; then
      echo "Usage: `basename $0` playlist.m3u destination_folder"
      exit $E_BADARGS
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
     
     if [[ ${lines[$i]} == *mp3 ]]
     then
         echo "copying file "${filename}" to "${countstr}_${filename}
         cp "${lines[$i]}" "${dest_folder}/${countstr}_${filename}"
     fi
     
     if [[ ${lines[$i]} == *m4a ]]
     then
    
         echo "converting file "${filename}" to "${dest_folder}"/"${countstr}"_"${filename%\.*}".mp3"
         
         avconv -y -i "${lines[$i]}" -acodec libmp3lame -ab 192k "${dest_folder}/${countstr}_${filename%\.*}.mp3" &> /dev/null  &
         wait $!;
     fi
done
