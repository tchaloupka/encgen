# encgen
Encoding generator for D

It can be used to help generate encodings for [Phobos](https://github.com/D-Programming-Language/phobos/blob/master/std/encoding.d) library.

Use [dub](https://github.com/D-Programming-Language/dub) to build it.
It takes one parameter, which has to be a file name with unicode mappings specifications fror required encoding.

Works at least with CP1250 and ISO-8859-2, maybe many more simple mappings (not all for sure).

The unicode mapping files can be found [here](ftp://ftp.unicode.org/Public/MAPPINGS/)

# todo list
- generate also unittest for all characters from mapping to test it fully
