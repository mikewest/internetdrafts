all: spec/index.html

clean:
	rm -rf ./spec/index.html
	rm -rf ./usecases/index.html
	rm -rf ./writeonly/index.html

spec/index.html: spec/index.src.html biblio.json
	bikeshed -q spec ./spec/index.src.html ./spec/index.html
