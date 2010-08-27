.SUFFIXES: .ll .bc

all: mandelbrot mandelbrot_opt

clean:
	rm utils.ll mandelbrot_opt.ll bmpfile.ll mandelbrot mandelbrot_opt
	rm *.bc

mandelbrot: mandelbrot.bc utils.bc bmpfile.bc
	llvm-ld -native mandelbrot.bc utils.bc bmpfile.bc -o mandelbrot

mandelbrot_opt: mandelbrot_opt.bc utils.bc bmpfile.bc mandelbrot_opt.ll
	llvm-ld -native mandelbrot_opt.bc utils.bc bmpfile.bc -o mandelbrot_opt

mandelbrot_opt.ll: mandelbrot_opt.bc
	llvm-dis mandelbrot_opt.bc -f

mandelbrot_opt.bc: mandelbrot.bc
	opt -O3 mandelbrot.bc -f -o mandelbrot_opt.bc

utils.ll: utils.c
	clang -g -S -emit-llvm -o utils.ll utils.c

bmpfile.ll: bmpfile.c
	clang -g -S -emit-llvm -o bmpfile.ll bmpfile.c

.ll.bc:
	llvm-as -f $<
