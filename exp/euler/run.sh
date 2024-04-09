myfilename="euler"

pandoc \
-t markdown_strict \
--extract-media="./attachments/$myfilename" \
$myfilename.docx \
-o $myfilename.bak
