// Port of https://github.com/TinyCC/tinycc/blob/mob/tests/libtcc_test.c to Zig.

const std = @import("std");

const assert = std.debug.assert;

const tcc = @cImport(@cInclude("libtcc.h"));

const program =
    \\#include <stdio.h>
    \\void hello_world() {
    \\  printf("Hello, World!");
    \\}
;

fn handle_error(_: ?*anyopaque, msg: [*c]const u8) callconv(.C) void {
    std.debug.print("{s}\n", .{msg});
}

pub fn main() !void {
    var s: *tcc.TCCState = tcc.tcc_new() orelse {
        return;
    };
    defer tcc.tcc_delete(s);

    assert(tcc.tcc_get_error_func(s) == null);
    assert(tcc.tcc_get_error_opaque(s) == null);

    tcc.tcc_set_error_func(s, null, handle_error);
    assert(tcc.tcc_get_error_func(s) == handle_error);
    assert(tcc.tcc_get_error_opaque(s) == null);

    assert(tcc.tcc_add_include_path(s, "tinycc") == 0);
    assert(tcc.tcc_add_library_path(s, "tinycc") == 0);

    // MUST BE CALLED before any compilation
    assert(tcc.tcc_set_output_type(s, tcc.TCC_OUTPUT_MEMORY) == 0);

    if (tcc.tcc_compile_string(s, program) == -1) {
        return error.CouldNotCompile;
    }

    // relocate the code
    if (tcc.tcc_relocate(s, tcc.TCC_RELOCATE_AUTO) < 0) {
        return error.CouldNotRelocate;
    }

    // get entry symbol
    const func_opaque = tcc.tcc_get_symbol(s, "hello_world") orelse {
        return error.CouldNotGetSymbol;
    };
    const hello_world: *const fn () void = @alignCast(@ptrCast(func_opaque));

    // run the code
    hello_world();
}
