prefix = /usr/local

all: bin bin/libuuidxx.so
	@echo
	@echo "Build completed successfully!"
	@echo "Don't forget to run \`make test\` to ensure correct functionality prior to installing with \`make install\`"

test: bin/test
	@echo
	bin/test
	@echo
	@echo "Tests passed successfully!"

clean:
	rm -f *.o
	rm -rf bin

install: bin/libuuidxx.so bin/libuuidxx.a
	cp bin/libuuidxx.so bin/libuuidxx.a $(prefix)/lib/

uninstall:
	rm -f $(prefix)/lib/libuuidxx.so $(prefix)/lib/libuuidxx.a

bin:
	mkdir bin

uuidxx.o: uuidxx.cpp uuidxx.h
	$(CXX) $(CXXFLAGS) -std=c++11 -fPIC ./uuidxx.cpp -c -o uuidxx.o

bin/libuuidxx.so: uuidxx.o
	$(CXX) -shared uuidxx.o -o bin/libuuidxx.so

bin/libuuidxx.a: uuidxx.o
	ar rvs bin/libuuidxx.a uuidxx.o

bin/test: bin/libuuidxx.so
	$(CXX) $(CXXFLAGS) -std=c++11 bin/libuuidxx.so tests/main.cpp -o bin/test

.PHONY: all test
