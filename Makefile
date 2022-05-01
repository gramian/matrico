# matrico Makefile

CSC = csc
CSI = csi

LEVEL = -O4
FLAGS = -d0 -C -O2 -C -pipe

VERSION = $(shell csi -b version.scm -p "(matrico-version)")

DIM = 1000

.PHONY: benchmark, linpack

default:
	$(CSC) -shared -emit-import-library matrico $(LEVEL) $(FLAGS) matrico.scm

test:
	$(CSI) tests/run.scm

test_egg_local:
	tar cvzf matrico-$(VERSION).tar.gz \
                ../matrico/AUTHORS ../matrico/CITATION.cff ../matrico/LICENSE ../matrico/README.md \
                ../matrico/matrico.egg ../matrico/matrico.release-info ../matrico/matrico-logo.svg \
                ../matrico/matrico.scm ../matrico/RUNME.scm ../matrico/version.scm \
                ../matrico/src/dense.scm ../matrico/src/f64vector.scm ../matrico/src/fpmath.scm ../matrico/src/matrix.scm ../matrico/src/mx.scm ../matrico/src/utils.scm \
                ../matrico/tests/check.scm ../matrico/tests/run.scm ../matrico/tests/test-f64vector.scm ../matrico/tests/test-fpmath.scm ../matrico/tests/test-matrico.scm ../matrico/tests/test-utils.scm
	python3 -m http.server &
	test-new-egg matrico http://0.0.0.0:8000/matrico.release-info

test_egg_remote:
	test-new-egg matrico https://raw.githubusercontent.com/gramian/matrico/main/matrico.release-info

test_install:
	CHICKEN_INSTALL_REPOSITORY="/tmp/matrico" chicken-install -test
	CHICKEN_REPOSITORY_PATH="`chicken-install -repository`:/tmp/matrico" $(CSI) -e "(import matrico) (matrico-help)"

benchmark:
	@rm -f benchmark.txt
	make benchset DIM=125
	make benchset DIM=250
	make benchset DIM=500
	make benchset DIM=1000
	@cat benchmark.txt

benchset:
	@echo "## $(DIM):" >> benchmark.txt
	make benchrun LEVEL='-O0'
	make benchrun LEVEL='-O1'
	make benchrun LEVEL='-O2'
	make benchrun LEVEL='-O3'
	make benchrun LEVEL='-O4'
	make benchrun LEVEL='-O5'

benchrun:
	@echo "(include \"matrico.scm\") \
	       (import matrico) \
	       (time (mx-gram (mx-random $(DIM) $(DIM) -1.0 1.0))) \
	       (exit)" | $(CSC) $(LEVEL) $(FLAGS) - -o /tmp/benchmark
	@/tmp/benchmark 2>> benchmark.txt

linpack:
	@echo "(include \"matrico.scm\") \
	       (import matrico) \
	       (import (chicken time)) \
	       (define A (mx-random $(DIM) $(DIM) -1.0 1.0)) \
	       (define b (mx-rowsum A)) \
	       (define t0 (current-seconds)) \
	       (define solver (time (mx-solver A))) \
	       (define t1 (current-seconds)) \
	       (print "Megaflops/s:" #\space (/ (* $(DIM) $(DIM) $(DIM)) (* (- t1 t0) 1000.0 1000.0))) \
	       (print "Residual:" #\space (mx-norm (mx- (solver b) 1.0) 2)) \
	       (exit)" | $(CSC) -O5 $(FLAGS) - -o /tmp/linpack
	@/tmp/linpack 2> linpack.txt
	@cat linpack.txt

clean:
	rm -f benchmark.txt linpack.txt matrico.so matrico.import.scm matrico-$(VERSION).tar.gz

