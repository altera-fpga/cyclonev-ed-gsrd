THIS_MK_ABSPATH := $(abspath $(lastword $(MAKEFILE_LIST)))
THIS_MK_DIR := $(dir $(THIS_MK_ABSPATH))

# Enable pipefail for all commands
SHELL=/bin/bash -o pipefail

# Enable second expansion
.SECONDEXPANSION:

# Clear all built in suffixes
.SUFFIXES:

NOOP :=
SPACE := $(NOOP) $(NOOP)
COMMA := ,
HOSTNAME := $(shell hostname)

##############################################################################
# Environment check
##############################################################################


##############################################################################
# Configuration
##############################################################################
WORK_ROOT := $(abspath $(THIS_MK_DIR)/work)
INSTALL_RELATIVE_ROOT ?= install
INSTALL_ROOT ?= $(abspath $(THIS_MK_DIR)/$(INSTALL_RELATIVE_ROOT))

PYTHON3 ?= python3
VENV_DIR := venv
VENV_PY := $(VENV_DIR)/bin/python
VENV_PIP := $(VENV_DIR)/bin/pip
ifneq ($(https_proxy),)
PIP_PROXY := --proxy $(https_proxy)
else
PIP_PROXY :=
endif
VENV_PIP_INSTALL := $(VENV_PIP) install $(PIP_PROXY) --timeout 90 --trusted-host pypi.org --trusted-host files.pythonhosted.org

##############################################################################
# Set default goal before any targets. The default goal here is "test"
##############################################################################
DEFAULT_TARGET := help

.DEFAULT_GOAL := default
.PHONY: default
default: $(DEFAULT_TARGET)


##############################################################################
# Makefile starts here
##############################################################################


###############################################################################
#                          Design Targets
###############################################################################
%/output_files:
	mkdir -p $@

$(INSTALL_ROOT) $(INSTALL_ROOT)/designs $(INSTALL_ROOT)/not_shipped:
	mkdir -p $@

# Initialize variables
ALL_TARGET_STEM_NAMES =
ALL_TARGET_ALL_NAMES =

# Define function to create targets
# create_ghrd_target
# $(1) - Base directory name. i.e. cv_soc_devkit_ghrd
# $(2) - Target name. i.e. cyclonev-soc-devkit-baseline. Format is <devkit>-<name>
# $(3) - Revision name. i.e. soc_system
# $(4) - Config target. i.e. generate-cyclonev-soc-devkit-baseline
define create_ghrd_target
ALL_TARGET_STEM_NAMES += $(strip $(2))
ALL_TARGET_ALL_NAMES += $(strip $(2))-all

.PHONY: $(strip $(2))-prep
$(strip $(2))-prep: prepare-tools | $(strip $(1))/output_files

.PHONY: $(strip $(2))-generate-design
$(strip $(2))-generate-design: prepare-tools | $(strip $(1))/output_files
	$(MAKE) -C $(strip $(1)) $(strip $(4))
	$(MAKE) -C $(strip $(1)) apply_pin_assignment

.PHONY: $(strip $(2))-build
$(strip $(2))-build: $(strip $(1))/output_files
	cd $(strip $(1)) && quartus_map $(strip $(3))
	cd $(strip $(1)) && quartus_fit $(strip $(3))
	cd $(strip $(1)) && quartus_asm $(strip $(3))
	cd $(strip $(1)) && quartus_sta $(strip $(3)) --mode=finalize
	cd $(strip $(1)) && touch output_files/$(strip $(3)).sof
	$(MAKE) -C $(strip $(1)) create_rbf

.PHONY: $(strip $(2))-sw-build
$(strip $(2))-sw-build:

.PHONY: $(strip $(2))-test
$(strip $(2))-test:

.PHONY: $(strip $(2))-install-sof
$(strip $(2))-install-sof: | $(INSTALL_ROOT)/designs
	cp -f $(strip $(1))/output_files/$(strip $(3)).sof $(INSTALL_ROOT)/designs/$(strip $(2)).sof
	cp -f $(strip $(1))/output_files/$(strip $(3)).rbf $(INSTALL_ROOT)/designs/$(strip $(2)).rbf

.PHONY: $(strip $(2))-package-design
$(strip $(2))-package-design: | $(INSTALL_ROOT)/designs
	cd $(strip $(1)) && zip -r $(INSTALL_ROOT)/designs/$(strip $(2)).zip * -x .gitignore "output_files/*" "db/*" "tmp-clearbox/*"

.PHONY: $(strip $(2))-all
$(strip $(2))-all:
	$(MAKE) $(strip $(2))-generate-design
	$(MAKE) $(strip $(2))-package-design
	$(MAKE) $(strip $(2))-prep
	$(MAKE) $(strip $(2))-build
	$(MAKE) $(strip $(2))-sw-build
	$(MAKE) $(strip $(2))-test
	$(MAKE) $(strip $(2))-install-sof

endef

# Create the recipes by calling create_ghrd_target on each design
$(eval $(call create_ghrd_target, cv_soc_devkit_ghrd, cyclonev-soc-devkit-baseline, soc_system, generate-cyclonev-soc-devkit-baseline))

###############################################################################
#                          UTILITY TARGETS
###############################################################################
# Deep clean using git
.PHONY: dev-clean
dev-clean :
	git clean -dfx --exclude=/.vscode --exclude=.lfsconfig

# Using git
.PHONY: dev-update
dev-update :
	git pull
	git submodule update --init --recursive

.PHONY: clean
clean:
	git clean -dfx --exclude=/.vscode --exclude=.lfsconfig --exclude=$(VENV_DIR)

# Prep workspace
venv:
	$(PYTHON3) -m venv $(VENV_DIR)
	$(VENV_PIP_INSTALL) --upgrade pip
	$(VENV_PIP_INSTALL) -r requirements.txt


.PHONY: venv-freeze
venv-freeze:
	$(VENV_PIP) freeze > requirements.txt
	sed -i -e 's/==/~=/g' requirements.txt

.PHONY: prepare-tools
prepare-tools : venv

# Include not_shipped Makefile if present
-include not_shipped/Makefile.mk

###############################################################################
#                          Toplevel Targets
###############################################################################

.PHONY: prep
prep: prepare-tools

.PHONY: pre-prep
pre-prep:

.PHONY: package-designs
package-designs: $(addsuffix -package-designs,$(ALL_TARGET_STEM_NAMES))

###############################################################################
#                                HELP
###############################################################################
.PHONY: help
help:
	$(info GHRD Build)
	$(info ----------------)
	$(info ALL Targets         : $(ALL_TARGET_ALL_NAMES))
	$(info Stem names          : $(ALL_TARGET_STEM_NAMES))
