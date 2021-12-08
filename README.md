# filesymbol
Small tool to embed files and directory hierarchies into C sources, to be compiled and available as symbols for any language that can read them

## Usage
```
filesymbol -o OUTFILE [-i HEADERFILE] [-r RAWFILE NAME]... [-R RAWFILE NAME]... [-f FILE NAME]... FILES...
	-o --out    OUTFILE      - set output file (.c)
	-i --header HEADERFILE   - set output header file (.h)
	-r --rawlen RAWFILE NAME - add raw file as name, with length
	-R --raw    RAWFILE NAME - add raw file as name, without length
	-f --file   FILE NAME    - add file hierarchy to output
	FILES                    - add file hierarchy to output, named by path
```

### Examples
Package the `filesymbol`, `include` and `bin` directories, along with the rockspec:
```
filesymbol -o filesymbol.c -i filesymbol.h include bin filesymbol *.rockspec
```

Package the readme as the `readme` symbol, and compile it to the `readme.o` object file, without anything else:
```
filesymbol -o readme.c -R README.md readme
gcc -c readme.c -o readme.o
```

## Installing
TODO
