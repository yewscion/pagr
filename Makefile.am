include guile.am

SOURCES =				\
cdr255/pagr.scm

EXTRA_DIST =				\
README.md				\
bootstrap				\
pre-inst-env.in				\
bin/pagr.scm

bin_SCRIPTS =				\
pagr

TESTS=run-tests

#MOSTLYCLEANFILES +=                    

CLEANFILES +=                           \
pagr                        \
cdr255/pagr.scm     \
pagr

DISTCLEANFILES =                        \
config.status                           \
config.log                              \
Makefile                                \
run-tests                               \
basic-tests.log

#MAINTAINERCLEANFILES +=

pagr: src/exe.scm
		sed -e 's,#!\/usr\/bin\/env -S guile -e main -s,\#!$(GUILE) \\,g' \
	 < $(srcdir)/src/exe.scm > ./pagr
	chmod +x pagr

cdr255/pagr.scm:
	mkdir -pv cdr255/
	cat < $(srcdir)/src/main.scm \
	> cdr255/pagr.scm

run-tests:
		sed -e 's,#!\/usr\/bin\/env -S guile -e main -s,\#!$(GUILE) \\,g' \
	< $(srcdir)/test/maintests.scm \
	> run-tests
	chmod +x run-tests
	guile -C ./ ./run-tests
