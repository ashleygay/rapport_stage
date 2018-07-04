# Compile the markdown to a pdf

STYLE=zenburn
# In the case where we include code, we have nice syntax highlighting.

pandoc \
	--number-sections\
	-f markdown\
        -fmarkdown-implicit_figures\
	--template=./template.tex\
	--toc\
	--highlight-style=$STYLE\
        report.md\
        -s -o report.tex
pandoc \
	--number-sections\
	-f markdown\
        -fmarkdown-implicit_figures\
	--template=./template.tex\
	--toc\
	--highlight-style=$STYLE\
        report.md\
        -o report.pdf
