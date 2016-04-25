# Ian Dennis Miller

# ignore the following LaTeX commands when spell checking
NOSPELL=--add-tex-command="bibliographystyle op" --add-tex-command="bibliography op" --add-tex-command="thispagestyle op"
PROJECT=intergalactic-computer-network

all: clean manuscript doc # spell
	@echo done

clean:
	rm -rf .build
	mkdir -p .build

journal: timestamp
	pdflatex -output-directory=.build "\def\myflag{}\input{$(PROJECT).tex}"
	bibtex .build/$(PROJECT).aux
	pdflatex -output-directory=.build "\def\myflag{}\input{$(PROJECT).tex}"
	pdflatex -output-directory=.build "\def\myflag{}\input{$(PROJECT).tex}"

manuscript: timestamp
	pdflatex -output-directory=.build $(PROJECT).tex
	bibtex .build/$(PROJECT).aux
	pdflatex -output-directory=.build $(PROJECT).tex
	pdflatex -output-directory=.build $(PROJECT).tex

watch: timestamp
	cd .build && latexmk ../$(PROJECT).tex

timestamp:
	@mkdir -p .build
	@rm -f .build/gitinfo.tex && touch .build/gitinfo.tex
	@echo '\\begin{description}' >> .build/gitinfo.tex
	@echo '\item[build time]{\\texttt{'`date`"}}" >> .build/gitinfo.tex
	@echo '\item[git revision]{\\texttt{'`git rev-parse --verify HEAD`"}}" >> .build/gitinfo.tex
	@echo '\item[canonical.Rdata.gz]{\\texttt{'`md5 ../analysis/data/canonical.RData.gz | awk '{print $$4}'`"}}" >> .build/gitinfo.tex
	@echo '\item[canonical-scored.Rdata.gz]{\\texttt{'`md5 ../analysis/data/canonical-scored.RData.gz | awk '{print $$4}'`"}}" >> .build/gitinfo.tex
	@echo '\\end{description}' >> .build/gitinfo.tex
	@echo "Wrote timestamp TeX in: .build/gitinfo.tex"

doc: html
	pandoc -r html -R -w markdown .build/$(PROJECT).html | perl ~/bin/html-table2pandoc.pl > .build/tmp.md
	sed 's/^### /\'$$'\n### /g' .build/tmp.md > .build/tmp2.md
	sed 's/^### /\'$$'\n### /g' .build/tmp2.md > .build/tmp3.md
	#convert graphic/simple-slopes.pdf dogwhistles0x.png
	pandoc -f markdown -t docx -o .build/$(PROJECT).docx .build/tmp3.md
	#rm dogwhistles0x.png

html:
	htlatex $(PROJECT).tex "xhtml,word"
	pandoc --self-contained -f html -t rtf -o .build/$(PROJECT).rtf $(PROJECT).html
	mv $(PROJECT).html $(PROJECT).css .build
	rm -f $(PROJECT).4tc $(PROJECT).4ct $(PROJECT).aux $(PROJECT).fff $(PROJECT).dvi $(PROJECT).idv $(PROJECT).lg $(PROJECT).log $(PROJECT).tmp $(PROJECT).ttt $(PROJECT).xref zz$(PROJECT).ps texput.log

spell:
	@aspell $(NOSPELL) --master=en_CA --mode=tex check $(PROJECT).tex
	@echo Finished checking spelling

open:
	open .build/$(PROJECT).pdf

count:
	detex $(PROJECT).tex |wc

products: all
	cp .build/*.pdf products

.PHONY: all clean manuscript doc spell html open count timestamp journal watch products
