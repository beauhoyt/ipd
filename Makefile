OS := $(shell uname)
ifeq ($(OS),Linux)
	TAR_OPTS := --wildcards
endif

all: deps test vet install

fmt:
	go fmt ./...

test:
	go test ./...

vet:
	go vet ./...

deps:
	go get -d -v ./...

install:
	go install ./...

build:
	go build -o ipd cmd/ipd/main.go

run:
	./ipd -f GeoLite2-Country.mmdb  -c GeoLite2-City.mmdb  -a GeoLite2-ASN.mmdb -p -r

databases := GeoLite2-City GeoLite2-Country GeoLite2-ASN

$(databases):
	mkdir -p data
	curl -fsSL -m 30 http://geolite.maxmind.com/download/geoip/database/$@.tar.gz | tar $(TAR_OPTS) --strip-components=1 -C $(PWD)/data -xzf - '*.mmdb'
	test ! -f data/GeoLite2-City.mmdb || mv data/GeoLite2-City.mmdb ./GeoLite2-City.mmdb
	test ! -f data/GeoLite2-Country.mmdb || mv data/GeoLite2-Country.mmdb ./GeoLite2-Country.mmdb
	test ! -f data/GeoLite2-ASN.mmdb || mv data/GeoLite2-ASN.mmdb ./GeoLite2-ASN.mmdb

geoip-download: $(databases)
