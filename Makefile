#!/usr/bin/make -f
# Makefile to build website

# Languages which we translate
LANGUAGES=cs pl tr fr sv es da gl pt_BR zh_TW zh_CN id

# directory where phpMyAdmin sources are placed
PMA_DIR=../phpmyadmin

# Option to po4a programs
PO4AOPTS=-M utf-8 -L utf-8

# Options for generating po files using po4a
PO4A_PO_OPTS=--msgid-bugs-address weblate@lists.cihar.com \
		--copyright-holder "Michal Čihař" \
		--package-name "Weblate website" \
		-M utf-8 \
		-L utf-8 \

# Options for processing html files
PO4A_HTML_OPTS=-f xhtml

all: sitemap.xml

sitemap.xml: $(wildcard */*.html) get-sitemap
	@echo 'GEN $@'
	@./get-sitemap */*.html > $@
	
en/index.html:
	@echo -n

%/index.html: po/%.po
	@echo 'TRANSLATE $@'
	@po4a-translate $(PO4A_HTML_OPTS) -m $*/index.html -p $< -l $@ ${PO4AOPTS} -k 0

.PRECIOUS: po/weblate-web.pot
po/weblate-web.pot: en/index.html
	@echo 'GEN $@'
	@po4a-gettextize $(PO4A_HTML_OPTS) ${PO4A_PO_OPTS} \
		-m en/index.html \
		-p $@

po/%.po: po/weblate-web.pot
	@set -e; \
	if [ ! -f $@ ] ; then msginit -i $< -l $* --no-translator -o $@ ; fi
	@echo 'MERGE $@'
	@msgmerge -U $@ $<
	@touch $@
