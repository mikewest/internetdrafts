id_base = ..
xml2rfc ?= xml2rfc
saxpath ?= ~/bin/saxon9.jar
kramdown-rfc2629 ?= kramdown-rfc2629
bootstrap ?= ../RFCbootstrap/rfcbootstrap.xslt
idnits ?= idnits

title = west-$(shell basename ${CURDIR})
latest = $(shell (ls draft-${title}-*.xml || echo "draft-${title}-00.xml") | sort | tail -1)
version = $(shell basename ${latest} .xml | awk -F- '{print $$NF}')

target = draft-$(title)-$(version)
prev = draft-$(title)-$(shell printf "%.2d" `echo ${version}-1 | bc`)
next = draft-$(title)-$(shell printf "%.2d" `echo ${version}+1 | bc`)

.PHONY: latest clean next diff idnits update

latest: $(target).html $(target).txt index.html index.txt

clean:
	rm -f $(target).html $(target).txt

next: 
	cp $(target).xml $(next).xml
	sed -i '' -e"s/$(target)/$(next)/" draft.md

diff: 
	rfcdiff $(prev).txt $(target).txt

idnits: $(target).txt
	$(idnits) $<

%.xml: draft.md
	@echo "# Building XML"
	@echo ">> $(kramdown-rfc2629) $< > $@"
	@$(kramdown-rfc2629) $< > $@
	
%.html: %.xml
	@echo "# Building HTML:"
#	@echo ">> sed -i '' -e \"s/rfc2629.dtd/$(id_base)\\/Tools\/rfc2629xslt\\/rfc2629.dtd/\" $<"
#	@sed -i '' -e "s|rfc2629.dtd|$(id_base)/Tools/rfc2629xslt/rfc2629.dtd|" $<
	@echo "# Transforming HTML:"
	@echo ">> java -classpath $(saxpath) net.sf.saxon.Transform -l $< $(bootstrap) > $@"
	@java -classpath $(saxpath) net.sf.saxon.Transform -l $< $(bootstrap) > $@

%.txt: %.xml
	$(xml2rfc) $< $@

index.html: $(target).html
	cp $< $@

index.txt: $(target).txt
	cp $< $@

update:
	cp $(id_base)/Tools/skel/Makefile .
