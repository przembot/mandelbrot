CC=gcc
CFLAGS= -Wall -lallegro

all: mandel.o manasm.o
	$(CC) $(CFLAGS) mandel.o manasm.o -o mandel

mandel.o: mandel.c
	$(CC) $(CFLAGS) -c mandel.c -o mandel.o

manasm.o: manasm.s
	nasm -f elf64 -g manasm.s -o manasm.o

clean:
	rm *.o
