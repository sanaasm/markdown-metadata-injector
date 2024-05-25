#!/bin/sh

DIRECTORY=$1

find $DIRECTORY -type f -name '*.md' -print0 | while read -d $'\0' file
do
	#echo "$file"
	STRIPTEDFILE=$(awk '
BEGIN { in_metadata = 0; }
/^---$/ { 
    in_metadata++; 
    if (in_metadata == 2) { 
        in_metadata = 0; 
        next; 
    }
    next;
}
in_metadata == 0 { printf "%s\\n", $0}
' "$file"
)
	TITLEFROMHEADER=$(grep '^#' "$file" | head -n 1 | sed 's/^#\+ *//')
	#date created
	CREATEDDATA=$(git log --diff-filter=A --follow --format="%ci" -- "$file")
	#date last edited
	UPDATEDDATA=$(git log -1 --format="%ci" -- "$file")

	METADATA=$"---\ntitle: \"${TITLEFROMHEADER}\"\ndraft: false \ncreated: ${CREATEDDATA}\nupdated: ${UPDATEDDATA}\ntags: []\n---\n"
	NEWFILE=$"${METADATA}${STRIPTEDFILE}"
	echo -e $NEWFILE > "$file"

done



