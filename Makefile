.PHONY: clean html

clean:
	@rm -rf build

copy-assets:
	@mkdir -p build
	@cp -r static build

html: clean copy-assets
	@saxon -s:xslt/pages.xml -xsl:xslt/pipeline.xslt base-uri=$(shell pwd)
