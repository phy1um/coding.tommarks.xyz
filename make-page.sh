
HEADER=$(cat src/tmp-header.html)
FOOTER=$(cat src/tmp-footer.html)
PAGE=$(cat $1)

echo -e "$HEADER\n$PAGE\n$FOOTER"
