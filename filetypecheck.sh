#!/bin/bash
# Usage: filetypecheck -c (Correct extension errors) -a (Display files with correct extensions as well)

do_correct=0
display_all=0
files_were_shown=0

while getopts "ac" opt; do
	case "$opt" in
	c)	do_correct=1
	;;
	a)	display_all=1
	;;
	esac
done

# Set extensions to check for here. jpg files are notified as jpeg
declare -a valid_extensions=(png jpeg gif)

array_size=$(echo ${#valid_extensions[@]})
ls -1 | sort -k1n > .file_list
file_number=$(cat .file_list | wc -l)

for i in $(seq 1 $file_number)
do
	file_check=$(sed -n "$i"p .file_list)
	extension="${file_check##*.}"
	filename="${file_check%.*}"

		if [ "$extension" = "jpg" ]; then
			extension="jpeg"
		fi

	actext=$(file -ib "$file_check" | awk '{print $1}' | cut -d "/" -f2 | tr -d ";")

		for i in $(seq 1 $array_size)
		do
			array_var=$[ $i -1 ]
			checkable_extension=${valid_extensions[$array_var]}

			if [ "$extension" = "$checkable_extension" ]; then
				validity=1
				valid_extensions_found=1
				break
				else
				validity=0
			fi
		done

		if [[ $validity = 1 ]]; then
			if [ "$extension" = "$actext" ]; then
				if [[ $display_all = 1 ]]; then
					echo $(color lightgreen)$file_check $actext$(color)
					files_were_shown=1
				fi
				else
				if [[ $do_correct = 1 ]] ; then
					echo $(color lightyellow)$file_check" - Corrected to "$actext$(color)
					mv "$file_check" "$filename".$actext
					files_were_shown=1
					else
					echo $(color lightred)$file_check $actext$(color)
					files_were_shown=1
				fi
			fi
		fi
done

if [[ $files_were_shown = 0 ]] && [[ $valid_extensions_found = 1 ]] ; then
	echo $(color lightcyan)"All files have correct extensions"$(color)
fi

if [[ ! $valid_extensions_found = 1 ]]; then
	echo $(color lightyellow)"No valid extensions found"$(color)
fi

rm .file_list
