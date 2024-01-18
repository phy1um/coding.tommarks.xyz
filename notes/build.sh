
output=${1-notes.txt}
cat header.txt > $output
for file in $(find -type f -name "20*.txt" | sort -rn); do
  cat $file >> $output
done
		

