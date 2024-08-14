const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) !void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addStaticLibrary(.{
        .name = "PhysX",
        .target = target,
        .optimize = optimize,
    });
    b.installArtifact(lib);

    lib.linkLibC();
    lib.linkLibCpp();

    var physx_dir = try std.fs.cwd().openDir("physx", .{
        .iterate = true,
    });
    var source_dir = try std.fs.cwd().openDir("physx/source", .{
        .iterate = true,
    });

    lib.addIncludePath(.{
        .cwd_relative = try physx_dir.realpathAlloc(b.allocator, "include"),
    });
    lib.addIncludePath(.{
        .cwd_relative = try source_dir.realpathAlloc(b.allocator, "common/include"),
    });

    lib.defineCMacro("NDEBUG", "1");
    lib.defineCMacro("PX_PHYSX_STATIC_LIB", "1");
    lib.defineCMacro("PX_CLANG", "1");
    lib.defineCMacro("DISABLE_CUDA_PHYSX", "1");
    lib.defineCMacro("PX_SUPPORT_PVD", "1");

    switch (target.result.cpu.arch) {
        .x86 => lib.defineCMacro("PX_X86", "1"),
        .x86_64 => {
            lib.defineCMacro("PX_X64", "1");

            // TODO add feature query
            lib.defineCMacro("PX_SSE2", "1");
        },
        .aarch64 => lib.defineCMacro("PX_A64", "1"),
        .arm => lib.defineCMacro("PX_ARM", "1"),
        else => {},
    }

    switch (target.result.os.tag) {
        .windows => lib.defineCMacro("PX_WINDOWS", "1"),
        .macos => lib.defineCMacro("PX_OSX", "1"),
        .linux => lib.defineCMacro("PX_LINUX", "1"),
        else => {},
    }

    var known_paths = std.StringHashMap(void).init(b.allocator);
    defer known_paths.deinit();

    var walker = try source_dir.walk(b.allocator);
    defer walker.deinit();

    while (try walker.next()) |entry| {
        if (target.result.os.tag != .windows and std.mem.containsAtLeast(u8, entry.path, 1, "windows")) {
            continue;
        }

        if (entry.kind == .file and std.mem.endsWith(u8, entry.basename, ".cpp")) {
            const file_path = try source_dir.realpathAlloc(b.allocator, entry.path);
            lib.addCSourceFile(.{
                .file = .{
                    .cwd_relative = file_path,
                },
                .flags = &.{
                    "-std=c++17",
                    "-w",
                    "-fno-rtti",
                    "-fno-exceptions",
                    "-ffunction-sections",
                    "-fdata-sections",
                    "-fno-strict-aliasing",
                    "-fvisibility=hidden",
                    "-ffp-exception-behavior=maytrap",
                },
            });
        }

        if (entry.kind == .file and std.mem.endsWith(u8, entry.basename, ".h")) {
            const dir = try source_dir.realpathAlloc(
                b.allocator,
                std.fs.path.dirname(entry.path).?,
            );
            const path = known_paths.get(dir);

            if (path == null) {
                lib.addIncludePath(.{
                    .cwd_relative = dir,
                });
                try known_paths.put(dir, {});
            }
        }
    }
}
