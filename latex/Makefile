SOURCES=$(wildcard *.tex)
TARGETS=$(patsubst %.tex, %.pdf, $(SOURCES))
OPTIONS=-interaction=nonstopmode -use-make -bibtex

.PHONY: all clean cleanall

all: $(TARGETS)

%.pdf: %.tex
	latexmk -pdf $(OPTIONS) $?

cleanall:
	latexmk -C $(OPTIONS)

clean:
	latexmk -c $(OPTIONS)
	rm -f LoRa.pdf
