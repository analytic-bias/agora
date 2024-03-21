myfilename="sachertorte"

pandoc \
-t markdown_strict \
--extract-media='./attachments/' \
$myfilename.docx \
-o $myfilename.md
