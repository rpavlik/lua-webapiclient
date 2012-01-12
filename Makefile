
JSONDIR := json4lua/json

JSONFILES := $(wildcard $(JSONDIR)/*.lua)

JSONOUTPUTS := $(patsubst $(JSONDIR)/%,%,$(JSONFILES))

OUTPUTS := $(JSONOUTPUTS)

# This copies all required libraries to the same directory
all: $(OUTPUTS)

# This reverses the above
clean: updategitignore
	-rm $(OUTPUTS)

# This ensures git doesn't try to version our "generated" files
updategitignore: $(MAKEFILE) .gitignore
	@echo Verifying all copied files are in the .gitignore file
	@for fn in $(OUTPUTS); do \
	  grep --quiet "/$${fn}" .gitignore || (echo "/$${fn}" >> .gitignore; echo "Adding $${fn} to .gitignore")\
	done

$(JSONOUTPUTS): % : $(JSONDIR)/%  $(MAKEFILE)
	@echo Copying $<
	@cp $<	$@

.PHONY: all clean updategitignore
