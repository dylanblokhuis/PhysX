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
        .distance = 5.0,
    }, material);

    c.pxSceneAddActor(scene, @ptrCast(plane));

    const actor_count = c.pxSceneGetNbActors(scene, c.C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC | c.C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC);

    const actors = try std.heap.c_allocator.alloc(c.PxActorRef, actor_count);
    _ = c.pxSceneGetActors(scene, c.C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC | c.C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC, actors.ptr, actor_count, 0);

    const shape_count = c.pxRigidActorGetNbShapes(@ptrCast(actors[0]));
    const shapes = try std.heap.c_allocator.alloc(c.PxShapeRef, shape_count);
    _ = c.pxRigidActorGetShapes(@ptrCast(actors[0]), shapes.ptr, shape_count, 0);

    const pose = c.pxShapeGetGlobalPose(shapes[0], @ptrCast(actors[0]));
    std.debug.print("{any}\n", .{pose});

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
