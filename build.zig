const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "tinycctest",
        .root_source_file = .{ .path = "main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibC();

    exe.linkSystemLibraryName("tcc");
    exe.addIncludePath(.{ .path = "tinycc" });
    exe.addLibraryPath(.{ .path = "tinycc" });

    const install_exe = b.addInstallArtifact(exe, .{});
    b.getInstallStep().dependOn(&install_exe.step);
}
