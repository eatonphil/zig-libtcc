# zig-libtcc

```console
$ git submodule update --init --recursive
$ ( cd tinycc && ./configure && make )
$ zig build
$ ./zig-out/bin/tinycctest
Hello, from C compiled dynamically from Zig!
```
