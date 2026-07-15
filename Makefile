.PHONY: build clean package test

build:
	./scripts/build.sh

package:
	./scripts/package.sh

test:
	./scripts/test.sh

clean:
	rm -rf .build build artifacts
