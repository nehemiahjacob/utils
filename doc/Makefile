#!/usr/bin/make

#=======================================================================
# doc/Makefile
# File ID: 26514a24-5d7c-11df-afe6-90e6ba3022ac
#=======================================================================

BOOKFILES = index.xml
HTMLFILE = index.html
XMLLINT = xmllint

$(HTMLFILE): $(BOOKFILES)
	xsltproc --output $(HTMLFILE) ~/xsl/xhtml/docbook.xsl $(BOOKFILES)
	xmllint --format --encode UTF-8 $(HTMLFILE) >$(HTMLFILE).tmp
	mv -v $(HTMLFILE).tmp $(HTMLFILE)

htmlbook:
	$(MAKE) clean && $(MAKE) all-html

clean:
	rm -f $(HTMLFILE)

ready:
	$(MAKE) clean
	$(MAKE)
	svn st

valid:
	XML_CATALOG_FILES=catalog.xml $(XMLLINT) --noout --nonet --valid $(BOOKFILES)

# vim: set ts=4 sw=4 sts=4 noet :
