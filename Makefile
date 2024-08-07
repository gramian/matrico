# matrico Makefile

TAR = tar # homebrew: gtar
SED = sed # homebrew: gsed
CSC = csc
CSI = csi
CHICKEN_INSTALL = chicken-install
CHICKEN_PROFILE = chicken-profile
TEST_NEW_EGG = test-new-egg # homebrew: /opt/homebrew/Cellar/chicken/5.4.0/bin/test-new-egg

CLARG =
LEVEL = -O3
DEBUG = -d0
override FLAGS += -strict-types -C -O2 -C -pipe

VERSION = $(shell csi -b version.scm -p "(matrico-version)")

DIM = 1000

.PHONY: mips, linpack, matmul

default:
	$(CSC) -shared -emit-import-library matrico $(LEVEL) $(DEBUG) $(FLAGS) matrico.scm

test:
	$(CSI) tests/run.scm

test_egg_local:
	$(TAR) cvzf matrico-$(VERSION).tar.gz --transform 's,^,matrico/,' \
              AUTHORS CITATION.cff LICENSE README.md \
              matrico.egg matrico.release-info res/matrico-logo.svg \
              matrico.scm RUNME.sh version.scm \
              src/dense.scm src/f64vector.scm src/fpmath.scm src/matrix.scm src/mx.scm src/utils.scm \
              tests/check.scm tests/run.scm tests/test-f64vector.scm tests/test-fpmath.scm tests/test-matrico.scm tests/test-utils.scm
	python3 -m http.server --bind 127.0.0.1 &
	sleep 1
	$(SED) -e '3 c\(uri targz \"http://0.0.0.0:8000/{egg-name}-{egg-release}.tar.gz\")' matrico.release-info > matrico-dev.release-info
	$(TEST_NEW_EGG) matrico http://0.0.0.0:8000/matrico-dev.release-info
	pkill -9 -f 'python3 -m http.server'
	rm matrico-dev.release-info

test_egg_remote:
	$(TEST_NEW_EGG) matrico https://raw.githubusercontent.com/gramian/matrico/main/matrico.release-info

test_install:
	CHICKEN_INSTALL_REPOSITORY="/tmp/matrico" $(CHICKEN_INSTALL) -test
	CHICKEN_REPOSITORY_PATH="/tmp/matrico:`$(CHICKEN_INSTALL) -repository`" $(CSI) -e "(import matrico) (matrico 'citation)"

iprofile:
	make linpack LEVEL='-O3' FLAGS='-profile' DIM=1000
	ls -1 PROFILE.* | sort -n | head -n1 | $(CHICKEN_PROFILE)
 
sprofile:
	make linpack LEVEL='-O4' DEBUG='-d3' DIM=1000 CLARG='-:P1000'
	ls -1 PROFILE.* | sort -n | head -n1 | $(CHICKEN_PROFILE)

mips:LEVEL=-O5
mips:
	@echo "(include \"matrico.scm\") \
	       (import matrico) \
	       (print "BogoMips:" #\space (matrico 'benchmark)) \
	       (newline) \
	       (exit)" | $(CSC) $(LEVEL) $(FLAGS) - -o /tmp/mips
	@/tmp/mips

matmul:LEVEL=-O5
matmul:
	@echo "(include \"matrico.scm\") \
	       (import matrico) \
	       (import (chicken time)) \
	       (define A (mx-random $(DIM) $(DIM) -1.0 1.0)) \
	       (define B (mx-random $(DIM) $(DIM) -1.0 1.0)) \
	       (define t0 (current-process-milliseconds)) \
	       (define C (time (mx-dot* A B))) \
	       (define t1 (current-process-milliseconds)) \
	       (print "Megaflops:" #\space (inexact->exact (floor (/ (* $(DIM) $(DIM) $(DIM)) (* (- t1 t0) 1000.0))))) \
	       (newline) \
	       (exit)" | $(CSC) $(LEVEL) $(FLAGS) - -o /tmp/matmul
	@/tmp/matmul $(CLARG) 2> matmul.txt
	@cat matmul.txt

linpack:LEVEL=-O5
linpack:
	@echo "(include \"matrico.scm\") \
	       (import matrico) \
	       (import (chicken time)) \
	       (define A (mx-random $(DIM) $(DIM) -1.0 1.0)) \
	       (define b (mx-rowsum A)) \
	       (define t0 (current-process-milliseconds)) \
	       (define solver (time (mx-solver A))) \
	       (define t1 (current-process-milliseconds)) \
	       (print "Megaflops:" #\space (inexact->exact (floor (/ (* $(DIM) $(DIM) $(DIM)) (* (- t1 t0) 1000.0))))) \
	       (print "Residual:" #\space (mx-norm (mx- (solver b) 1.0) 2)) \
	       (newline) \
	       (exit)" | $(CSC) $(LEVEL) $(FLAGS) - -o /tmp/linpack
	@/tmp/linpack $(CLARG) 2> linpack.txt
	@cat linpack.txt

heat:
	csi -b demos/heat.scm

flame:
	csi -b demos/flame.scm

clean:
	rm -f test.csv test.mx linpack.txt matmul.txt \
	      matrico.so *.import.scm *.import.so matrico.static.o \
	      matrico.build.sh matrico.install.sh matrico.link matrico.static.so \
	      matrico-$(VERSION).tar.gz PROFILE.* heat.csv flame.csv
