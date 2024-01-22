.PHONY: clean html

clean:
	@rm -rf build

html: clean
	@saxon -s:data/Abt-1_Tiefbau_Band-1.xml -xsl:xslt/pipeline.xslt base-uri=$(shell pwd)
