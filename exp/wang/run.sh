myfilename="JoCPHaoWang-2017"

pandoc \
-t markdown_strict \
--extract-media="./attachments/${myfilename}" \
$myfilename.docx \
-o $myfilename.md

myfilename="WangChronology"

pandoc \
-t markdown_strict \
--extract-media="./attachments/${myfilename}" \
$myfilename.docx \
-o $myfilename.md
