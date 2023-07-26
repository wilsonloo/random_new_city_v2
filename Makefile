.PHONY: all

all: libs

IMGE_MAKEFILE=lib/imgexporter/Makefile
$(IMGE_MAKEFILE):
	git submodule update --init
libs: lib/imgexporter | $(IMGE_MAKEFILE)
	cd lib/imgexporter && make
	cp lib/imgexporter/3rd/bson/bson.so ./lib
	cp lib/imgexporter/3rd/cjson/cjson.so ./lib