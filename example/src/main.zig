const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
    @cInclude("raymath.h");
    @cInclude("cphysx.h");
});

pub fn main() !void {
    const foundation = c.pxCreateFoundation();
    const physics = c.pxCreatePhysics(foundation, null);
    const scene = c.pxPhysicsCreateScene(physics);

    const material = c.pxPhysicsCreateMaterial(physics, 0.5, 0.5, 0.2);

    {
        const actor = c.pxCreateRigidDynamic(physics, .{
            .p = .{ .x = 5.0, .y = 5.0, .z = 0.0 },
            .q = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 },
        });

        const geo = c.pxCreateSphereGeometry(1);

        const shape = c.pxCreateShape(physics, geo, material, true);
        _ = c.pxRigidActorAttachShape(@ptrCast(actor), shape);
        c.pxSceneAddActor(scene, @ptrCast(actor));
    }

    {
        const actor = c.pxCreateRigidStatic(physics, .{
            .p = .{ .x = 0.0, .y = -5.0, .z = 0.0 },
            .q = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 },
        });

        const box = c.pxCreateBoxGeometry(.{
            .x = 10,
            .y = 1,
            .z = 10,
        });

        const shape = c.pxCreateShape(physics, box, material, true);
        _ = c.pxRigidActorAttachShape(@ptrCast(actor), shape);
        c.pxSceneAddActor(scene, @ptrCast(actor));
    }

    // {
    //     const actor = c.pxCreateRigidDynamic(physics, .{
    //         .p = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
    //         .q = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 },
    //     });
    //     const box = c.pxCreateBoxGeometry(.{
    //         .x = 1,
    //         .y = 1,
    //         .z = 1,
    //     });
    //     const shape = c.pxCreateShape(physics, box, material, true);
    //     _ = c.pxRigidActorAttachShape(@ptrCast(actor), shape);
    //     c.pxSceneAddActor(scene, @ptrCast(actor));
    // }

    // const plane = c.pxCreatePlane(physics, .{
    //     .normal = .{
    //         .x = 0.0,
    //         .y = 1.0,
    //         .z = 0.0,
    //     },
    //     .distance = 5.0,
    // }, material);

    // c.pxSceneAddActor(scene, @ptrCast(plane));

    c.InitWindow(1280, 720, "physx example");
    defer c.CloseWindow();

    var camera = c.Camera3D{
        .position = c.Vector3{
            .x = 10.0,
            .y = 10.0,
            .z = 10.0,
        },
        .target = c.Vector3{
            .x = 0.0,
            .y = 0.0,
            .z = 0.0,
        },
        .up = c.Vector3{
            .x = 0.0,
            .y = 1.0,
            .z = 0.0,
        },
        .fovy = 45.0,
        .projection = c.CAMERA_PERSPECTIVE,
    };
    c.SetTargetFPS(60);

    const cube_mesh = c.GenMeshCube(10 * 2, 1, 10 * 2);
    var cube_model = c.LoadModelFromMesh(cube_mesh);
    const sphere_mesh = c.GenMeshSphere(1, 16, 16);
    var sphere_model = c.LoadModelFromMesh(sphere_mesh);

    var drop_dist: f32 = 20.0;

    while (!c.WindowShouldClose()) {
        if (c.IsMouseButtonPressed(c.MOUSE_BUTTON_RIGHT)) {
            drop_dist += 5.0;
        }
        if (c.IsMouseButtonPressed(c.MOUSE_LEFT_BUTTON)) {
            {
                const t = c.Vector3MoveTowards(camera.position, camera.target, drop_dist);
                const actor = c.pxCreateRigidDynamic(physics, .{
                    .p = .{
                        .x = t.x + @as(f32, @floatFromInt(c.GetRandomValue(0, 255))) / 150.0,
                        .y = t.y + @as(f32, @floatFromInt(c.GetRandomValue(0, 255))) / 150.0,
                        .z = t.z + @as(f32, @floatFromInt(c.GetRandomValue(0, 255))) / 150.0,
                    },
                    .q = .{ .x = 0.0, .y = 0.0, .z = 0.0, .w = 1.0 },
                });

                const geo = c.pxCreateSphereGeometry(1);

                const shape = c.pxCreateShape(physics, geo, material, true);
                _ = c.pxRigidActorAttachShape(@ptrCast(actor), shape);
                c.pxSceneAddActor(scene, @ptrCast(actor));
            }
        }

        if (!c.pxSceneSimulate(scene, 1.0 / 60.0)) {
            return error.Failed;
        }

        if (!c.pxSceneFetchResults(scene, true)) {
            return error.Failed;
        }
        c.UpdateCamera(&camera, c.CAMERA_ORBITAL);

        c.BeginDrawing();
        defer c.EndDrawing();

        c.ClearBackground(c.RAYWHITE);
        c.BeginMode3D(camera);
        defer c.EndMode3D();

        // c.DrawCube(.{}, width: f32, height: f32, length: f32, color: Color)

        {
            const actor_count = c.pxSceneGetNbActors(scene, c.C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC | c.C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC);
            const actors = try std.heap.c_allocator.alloc(c.PxActorRef, actor_count);
            defer std.heap.c_allocator.free(actors);
            _ = c.pxSceneGetActors(scene, c.C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC | c.C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC, actors.ptr, actor_count, 0);

            var seed: c_uint = 0;
            for (actors) |actor| {
                const shape_count = c.pxRigidActorGetNbShapes(@ptrCast(actor));
                const shapes = try std.heap.c_allocator.alloc(c.PxShapeRef, shape_count);
                defer std.heap.c_allocator.free(shapes);

                _ = c.pxRigidActorGetShapes(@ptrCast(actor), shapes.ptr, shape_count, 0);

                const pose = c.pxShapeGetGlobalPose(shapes[0], @ptrCast(actor));

                const geo = c.pxShapeGetGeometry(shapes[0]);
                const ty = c.pxGeometryGetType(geo);

                c.SetRandomSeed(seed);
                seed += 1;
                const color_val: c_int = c.GetRandomValue(0, 255) << 16 | c.GetRandomValue(0, 255) << 8 | c.GetRandomValue(0, 255);
                var color = c.GetColor(@intCast(color_val));
                color.a = 255;

                const position = c.Vector3{
                    .x = pose.p.x,
                    .y = pose.p.y,
                    .z = pose.p.z,
                };
                const rotate_mat = c.QuaternionToMatrix(.{
                    .x = pose.q.x,
                    .y = pose.q.y,
                    .z = pose.q.z,
                    .w = pose.q.w,
                });
                if (ty == c.C_PX_GEOMETRY_TYPE_BOX) {
                    cube_model.transform = rotate_mat;

                    c.DrawModel(cube_model, position, 1, color);
                }
                if (ty == c.C_PX_GEOMETRY_TYPE_SPHERE) {
                    // const sphere_geo = c.pxGeometryGetSphere(geo);
                    sphere_model.transform = rotate_mat;
                    c.DrawModel(sphere_model, position, 1, color);
                    c.DrawModelWires(sphere_model, position, 1, c.BLACK);
                }
                if (ty == c.C_PX_GEOMETRY_TYPE_PLANE) {
                    c.DrawPlane(position, .{
                        .x = 1,
                        .y = 1,
                    }, c.BLUE);
                }
            }
        }
    }
}
