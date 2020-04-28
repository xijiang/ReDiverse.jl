CXXFLAGS = -O2 -Wall -std=c++17

target=fr2ped triallele merge-dup keep-vcf-snp

all:    ${target}

mv:
	mkdir -p ../bin
	mv ${target} ../bin

.PHONY: clean

clean:
	rm -f ${target}
