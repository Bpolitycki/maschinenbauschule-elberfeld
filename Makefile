.PHONY: clean html

clean:
	@rm -rf build

copy-assets:
	@mkdir -p build
	@cp -r static build

html: clean copy-assets
	@java -jar lib/saxon/saxon-he-12.4.jar -s:xslt/pages.xml -xsl:xslt/pipeline.xslt base-uri=$(shell pwd)
