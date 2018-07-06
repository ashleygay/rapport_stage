# Compile the markdown to a pdf

STYLE=zenburn
# In the case where we include code, we have nice syntax highlighting.

pandoc \
	--latex-engine=pdflatex\
	--filter pandoc-citeproc --bibliography=biblio.bib\
	--number-sections\
	--from=markdown+grid_tables+pipe_tables\
        -fmarkdown-implicit_figures\
	--template=./template.tex\
	--toc\
	--highlight-style=$STYLE\
        report.md\
        -s -o report.tex

#pdflatex report.tex -o report.pdf

pandoc \
	--latex-engine=pdflatex\
	--filter pandoc-citeproc --bibliography=biblio.bib\
	--number-sections\
	--from=markdown+grid_tables+pipe_tables\
        -fmarkdown-implicit_figures\
	--template=./template.tex\
	--toc\
	--highlight-style=$STYLE\
        report.md\
        -o report.pdf
