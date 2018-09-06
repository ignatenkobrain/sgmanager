$(shell git diff --quiet)
ifneq ($(.SHELLSTATUS),0)
#$(error git repository is dirty, fix this first! $(shell git diff))
endif
VERSION = 2.0.0
REVNUM = $(shell git rev-list --count HEAD)
COMMIT = $(shell git rev-parse HEAD)
SHORTCOMMIT = $(shell git rev-parse --short HEAD)
RHEL_RELEASE ?= el7
DIST ?= $(RHEL_RELEASE)

TARBALL = sgmanager-$(VERSION)~git+$(REVNUM).$(SHORTCOMMIT).tar.gz

sgmanager.spec: .FORCE
	@sed \
		-e "s|@REVNUM@|$(REVNUM)|" \
		-e "s|@COMMIT@|$(COMMIT)|" \
		-e "s|@SHORTCOMMIT@|$(SHORTCOMMIT)|" \
		sgmanager.spec.in > sgmanager.spec

tarball:
	@git archive --prefix=sgmanager-$(COMMIT)/ --format=tar.gz $(COMMIT) -o $(TARBALL)

srpm: sgmanager.spec tarball
	@rpmbuild -bs sgmanager.spec -D "_sourcedir $(PWD)" -D "_srcrpmdir $(PWD)/srpm" -D "dist .$(DIST)"

.FORCE:
.DEFAULT_GOAL := srpm
.PHONY: tarball srpm
