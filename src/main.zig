const std = @import("std");
const c = @cImport({
    @cInclude("wrapper.h");
});

pub fn main() !void {
    const foundation = c.pxCreateFoundation();
    const physics = c.pxCreatePhysics(foundation, null);
    const scene = c.pxPhysicsCreateScene(physics);

    const material = c.pxPhysicsCreateMaterial(physics, 0.5, 0.5, 0.6);
    const plane = c.pxCreatePlane(physics, .{
        .normal = .{
            .x = 0.0,
            .y = 1.0,
            .z = 0.0,
        },
        .distance = 0.0,
    }, material);

    c.pxSceneAddActor(scene, @ptrCast(plane));

    var frames: usize = 0;
    while (frames < 100) : (frames += 1) {
        if (!c.pxSceneSimulate(scene, 1.0 / 60.0)) {
            return error.Failed;
        }

        if (!c.pxSceneFetchResults(scene, true)) {
            return error.Failed;
        }
    }

    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("Hello, world!\n", .{});
}
