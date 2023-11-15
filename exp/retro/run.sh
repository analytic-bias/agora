myfilename="Tortoise&Achilles-2023"

pandoc \
-t markdown_strict \
--extract-media='./attachments/$myfilename' \
$myfilename.docx \
-o $myfilename.md
