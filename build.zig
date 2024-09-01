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

    const is_shared = b.option(bool, "shared", "Build shared library") orelse false;

    const lib = if (is_shared) b.addSharedLibrary(.{
        .name = "PhysX",
        .target = target,
        .optimize = optimize,
    }) else b.addStaticLibrary(.{
        .name = "PhysX",
        .target = target,
        .optimize = optimize,
    });

    // somehow physx literally memsets a nullptr to 0 on scene creation, so we disable this
    lib.root_module.sanitize_c = false;

    b.installArtifact(lib);

    lib.linkLibC();
    lib.linkLibCpp();

    var physx_dir = try std.fs.openDirAbsolute(try b.build_root.join(b.allocator, &.{"./physx"}), .{ .iterate = true });
    var source_dir = try std.fs.openDirAbsolute(try b.build_root.join(b.allocator, &.{"./physx/source"}), .{ .iterate = true });

    lib.addIncludePath(.{
        .cwd_relative = try physx_dir.realpathAlloc(b.allocator, "include"),
    });
    lib.addIncludePath(.{
        .cwd_relative = try source_dir.realpathAlloc(b.allocator, "common/include"),
    });

    // lib.defineCMacro("PX_LIBCPP", "1");
    // lib.defineCMacro("PX_CHECKED", "1");
    lib.defineCMacro("NDEBUG", "1");
    lib.defineCMacro("PX_PHYSX_STATIC_LIB", "1");
    lib.defineCMacro("PX_CLANG", "1");
    lib.defineCMacro("DISABLE_CUDA_PHYSX", "1");
    lib.defineCMacro("PX_SUPPORT_PVD", "1");
    lib.defineCMacro("PX_SUPPORT_GPU_PHYSX", "0");

    switch (target.result.cpu.arch) {
        .x86 => lib.defineCMacro("PX_X86", "1"),
        .x86_64 => {
            lib.defineCMacro("PX_X64", "1");

            if (std.Target.x86.featureSetHas(target.result.cpu.features, .sse2)) {
                lib.defineCMacro("PX_SSE2", "1");
            }
        },
        .aarch64 => {
            lib.defineCMacro("PX_A64", "1");
            if (std.Target.aarch64.featureSetHas(target.result.cpu.features, .neon)) {
                lib.defineCMacro("PX_NEON", "1");
            }
        },
        .arm => {
            lib.defineCMacro("PX_ARM", "1");
            if (std.Target.arm.featureSetHas(target.result.cpu.features, .neon)) {
                lib.defineCMacro("PX_NEON", "1");
            }
        },
        else => {},
    }

    switch (target.result.os.tag) {
        .windows => lib.defineCMacro("PX_WINDOWS", "1"),
        .macos => lib.defineCMacro("PX_OSX", "1"),
        .linux => lib.defineCMacro("PX_LINUX", "1"),
        else => {},
    }

    const flags = &.{
        "-std=c++11",
        "-fno-rtti",
        "-fno-exceptions",
        "-ffunction-sections",
        "-fdata-sections",
        "-fno-strict-aliasing",
        "-fvisibility=hidden",
        "-ffp-exception-behavior=maytrap",
        "-fno-threadsafe-statics",
    };

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
                .flags = flags,
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

    lib.installHeadersDirectory(.{
        .cwd_relative = try physx_dir.realpathAlloc(b.allocator, "include"),
    }, "", .{});
    lib.installHeader(b.path("src/cphysx.h"), "cphysx.h");
    lib.addCSourceFile(.{
        .file = b.path("src/cphysx.cpp"),
        .flags = flags,
    });
}
