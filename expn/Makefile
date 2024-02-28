# Thanks to Job Vranish (https://spin.atomicobject.com/2016/08/26/makefile-c-projects/)
TARGET_NAME      := exp
  
# SRCS             := $(shell find $(SRC_DIRS) -name '*.tex')
EMBEDS           := $(shell basename "$(find ./embed -name '*.tex')")
  
# Prepends BUILD_DIR and appends .o to every src file
# As an example, ./your_dir/hello.cpp turns into ./build/./your_dir/hello.cpp.o
EMBED_SVGS       := $(EMBEDS:%=./embed/%.svg)
EMBED_PDFS       := $(EMBEDS:%=./embed/%.pdf)

XELATEX_FLAGS    := -shell-escape -interaction=nonstopmode #-halt-on-error
LWARPMK		     := lwarpmk
# LWARPMK_FLAGS  :=

./embed/%.pdf: ./embed/%.tex
	xelatex $(XELATEX_FLAGS) $<

./build/%.svg: ./build/%.pdf
	pdf2svg $< $@

./build/exp.pdf: ./exp.tex $(EMBED_PDFS)
	xelatex $(XELATEX_FLAGS) ./exp.tex
	# biber

# $(BUILD_DIR)/$(TARGET_NAME).html: $(BUILD_DIR)/$(TARGET_NAME).pdf
# 	$(LWARPMK) limages
# 	$(LWARPMK) html

print: ./exp.pdf
	evince $<

