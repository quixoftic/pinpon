# NOTE:
#
# This Makefile is very much tailored to the maintainer's environment.
# It might work for you, but don't expect much.


nix-build: nix
	nix-build nix/jobsets/release.nix

doc:	test
	@echo "*** Generating docs"
	cabal haddock --hyperlink-source

test:	build
	@echo "*** Running tests"
	cabal test

help:
	@echo "Targets:"
	@echo
	@echo "Cabal/Nix:"
	@echo
	@echo "(Default is 'nix-build')"
	@echo
	@echo "The following targets assume that you are running Nix with some version"
	@echo "of cabal and GHC in your environment."
	@echo
	@echo "    nix-build - Run nix-build on all release.nix targets"
	@echo "    test      - configure and build the package, then run the tests"
	@echo "    build     - configure and build the package"
	@echo "    configure - configure the package"
	@echo
	@echo "General:"
	@echo
	@echo "    clean - remove all targets"
	@echo "    help  - show this message"

build:	configure
	@echo "*** Building the package"
	cabal build

sdist:	check doc
	@echo "*** Creating a source distribution"
	cabal sdist

check:
	@echo "*** Checking the package for errors"
	cabal check

configure: nix pinpon.cabal
	@echo "*** Configuring the package"
	cabal configure -f test-hlint

nix: 	pinpon.cabal
	@echo "*** Generating pkgs/pinpon.nix"
	cd nix/pkgs && cabal2nix ../../. > pinpon.nix
	cd nix/pkgs && cabal2nix --flag test-hlint ../../. > pinpon-hlint.nix

pinpon.cabal: package.yaml
	@echo "*** Running hpack"
	hpack

clean:
	cabal clean

.PHONY: clean nix
