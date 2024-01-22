.PHONY: clean html

clean:
	@rm -rf build

html: clean
	@saxon -s:xslt/pages.xml -xsl:xslt/pipeline.xslt base-uri=$(shell pwd)
