# Compile the markdown to a pdf

STYLE=zenburn
# In the case where we include code, we have nice syntax highlighting.

rm report.tex

dot -Tpng graph.dot -o plan.png

convert plan.png -fuzz 1% -transparent white plan.png

pandoc \
	--latex-engine=pdflatex\
	--filter pandoc-citeproc --bibliography=biblio.bib\
	--number-sections\
	--from=markdown+grid_tables+pipe_tables\
	--template=./template.tex\
	--toc\
	--variable urlcolor=blue\
	--highlight-style=$STYLE\
        report.md\
        -s -o report.tex

pdflatex report.tex -o report.pdf
makeglossaries report
pdflatex report.tex -o report.pdf

#pandoc \
#	--latex-engine=pdflatex\
#	--filter pandoc-citeproc --bibliography=biblio.bib\
#	--number-sections\
#	--from=markdown+grid_tables+pipe_tables\
#        -fmarkdown-implicit_figures\
#	--template=./template.tex\
#	--toc\
#	--highlight-style=$STYLE\
#        report.md\
#        -o report.pdf
