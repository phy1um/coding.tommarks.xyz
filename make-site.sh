PAGES="blog.html contact.html index.html projects.html thanks.html"
BLOG_FILES="src/blog/*.md"
BLOG_PREFIX="blog-"
BLOG_TEMPLATE="blog-template.html"

function make_page {
    cat "src/tmp-header.html" "$1" "src/tmp-footer.html"
}

if [ -z $PANDOC ]; then
    PANDOC="pandoc"
fi

python3 make-blog-index.py "$BLOG_PREFIX" $BLOG_FILES

for p in $PAGES; do
    echo "$p"
    make_page "src/$p" > "http/$p"
done

make_page "src/tmp-blog-post.html" > "$BLOG_TEMPLATE"

for p in $BLOG_FILES; do
    echo "$p"
    fn=$(basename -s .md $p)
    $PANDOC --template "$BLOG_TEMPLATE" $p > "http/$BLOG_PREFIX$fn.html"
done
