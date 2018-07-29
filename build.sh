# Compile the markdown to a pdf

STYLE=tango
DOT_FONT=Helvetica
# In the case where we include code, we have nice syntax highlighting.

build_image () {
	dot -Tpng $1.dot -Gfontname=$DOT_FONT -Nfontname=$DOT_FONT -Efontname=$DOT_FONT -o $1.png
	convert $1.png -fuzz 1% -transparent white $1.png
}

build_doc () {
	pandoc \
	--bibliography=biblio.bib\
	--number-sections\
	--from=markdown+grid_tables+pipe_tables\
	--template=./$2.tex\
	--toc\
	--variable urlcolor=blue\
	--metadata link-citations=true\
	--highlight-style=$STYLE\
        $1.md\
        -s -o $2.tex

	pdflatex $1.tex -o $1.pdf
	makeglossaries $1
	pdflatex $1.tex -o $1.pdf
}

#build_image newplan
#build_image database
#build_image organisation
#build_image compilation

#build_doc report template
build_doc abstract abstract_template


