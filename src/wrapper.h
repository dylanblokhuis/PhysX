#include <stdbool.h>
#include <stdint.h>

typedef struct PxFoundation* PxFoundationRef;
typedef struct PxPhysics* PxPhysicsRef;
typedef struct PxPvd* PxPvdRef;
typedef struct PxScene* PxSceneRef;
typedef struct PxMaterial* PxMaterialRef;
typedef struct PxRigidStatic* PxRigidStaticRef;
typedef struct PxActor* PxActorRef;
typedef struct PxRigidActor* PxRigidActorRef;
typedef struct PxShape* PxShapeRef;
typedef struct PxRigidDynamic* PxRigidDynamicRef;

typedef struct PxVec3f {
    float x, y, z;
} PxVec3f;

typedef struct PxVec34f {
    float x, y, z, w;
} PxVec4f;

typedef struct PxMat44f {
    PxVec4f column0, column1, column2, column3;
} PxMat44f;

typedef struct PxPlanef {
    PxVec3f normal;
    float distance;
} PxPlanef;



typedef uint32_t C_PxU32;
typedef uint16_t C_PxU16;

// PxActorTypeFlag is a uint16_t enum
typedef C_PxU16 C_PxActorTypeFlag;
#define C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC (1 << 0)
#define C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC (1 << 1)


PxFoundationRef pxCreateFoundation();
PxPvdRef pxCreatePvd(PxFoundationRef foundation);
PxPhysicsRef pxCreatePhysics(PxFoundationRef foundation, PxPvdRef pvd);

PxSceneRef pxPhysicsCreateScene(PxPhysicsRef physics);
PxMaterialRef pxPhysicsCreateMaterial(PxPhysicsRef physics, float dynamicFriction, float staticFriction, float restitution);

PxRigidStaticRef pxCreatePlane(PxPhysicsRef physics, PxPlanef plane, PxMaterialRef material);
// PxRigidStaticRef pxCreateBox(PxPhysicsRef physics, PxVec3f halfExtents, PxMaterialRef material, PxMat44f pose);

void pxSceneAddActor(PxSceneRef scene, PxActorRef actor);
bool pxSceneSimulate(PxSceneRef scene, float dt);
bool pxSceneFetchResults(PxSceneRef scene, bool block);
C_PxU32 pxSceneGetNbActors(PxSceneRef scene, C_PxActorTypeFlag flags);
C_PxU32 pxSceneGetActors(PxSceneRef scene, C_PxActorTypeFlag flags, PxActorRef* actors, C_PxU32 size, C_PxU32 startIndex);

bool pxActorIsRigidStatic(PxActorRef actor);
C_PxU32 pxRigidActorGetNbShapes(PxRigidActorRef actor);
C_PxU32 pxRigidActorGetShapes(PxRigidActorRef actor, PxShapeRef* shapes, C_PxU32 size, C_PxU32 startIndex);



PxMat44f pxShapeGetGlobalPose(PxShapeRef shape, PxRigidActorRef actor);


