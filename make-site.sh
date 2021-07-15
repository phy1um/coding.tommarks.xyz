PAGES="blog.html contact.html index.html projects.html thanks.html"
BLOG_FILES="src/blog/*.md"
BLOG_PREFIX="blog-"
BLOG_TEMPLATE="blog-template.html"

function test_in_path {
    echo " ------------- "
    echo "   Locating $1..."
    which $1 > /dev/null 2>&1
    if [ $? == 0 ]; then
        echo "    Found $1 @ $(which $1)"
        vstr=$($1 $2)
        echo "    Version: $vstr"
    else
        echo " /!\\ NOT FOUND /!\\"
    fi

}

function log_init_status {
    echo "=== BUILDING SITE ==="
    echo " DEPLOYING TO: $URL"
    echo " > source: $REPOSITORY_URL"
    echo " > branch: $BRANCH"
    echo " > commit: $COMMIT_REF"
    test_in_path "python3" "--version"
    test_in_path "pandoc" "-v"
}

function make_page {
    cat "src/tmp-header.html" "$1" "src/tmp-footer.html"
}

if [ -z $PANDOC ]; then
    PANDOC="pandoc"
fi

log_init_status

echo " === Building Blog Index === "
echo "   Blog posts found: $BLOG_FILES"
python3 make-blog-index.py "$BLOG_PREFIX" $BLOG_FILES

echo
echo " === Making Main Pages === "

for p in $PAGES; do
    echo " > Building page: $p"
    make_page "src/$p" > "http/$p"
done

echo
echo " === Making Blog === "

make_page "src/tmp-blog-post.html" > "$BLOG_TEMPLATE"

for p in $BLOG_FILES; do
    echo " > Building blog post: $p"
    fn=$(basename -s .md $p)
    $PANDOC --template "$BLOG_TEMPLATE" $p > "http/$BLOG_PREFIX$fn.html"
done

echo
echo
echo " =========="