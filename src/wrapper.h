#include <stdbool.h>

typedef struct PxFoundation* PxFoundationRef;
typedef struct PxPhysics* PxPhysicsRef;
typedef struct PxPvd* PxPvdRef;
typedef struct PxScene* PxSceneRef;
typedef struct PxMaterial* PxMaterialRef;
typedef struct PxRigidStatic* PxRigidStaticRef;
typedef struct PxActor* PxActorRef;

typedef struct PxVec3f {
    float x, y, z;
} PxVec3f;

typedef struct PxPlanef {
    PxVec3f normal;
    float distance;
} PxPlanef;

PxFoundationRef pxCreateFoundation();
PxPvdRef pxCreatePvd(PxFoundationRef foundation);
PxPhysicsRef pxCreatePhysics(PxFoundationRef foundation, PxPvdRef pvd);

PxSceneRef pxPhysicsCreateScene(PxPhysicsRef physics);
PxMaterialRef pxPhysicsCreateMaterial(PxPhysicsRef physics, float dynamicFriction, float staticFriction, float restitution);

PxRigidStaticRef pxCreatePlane(PxPhysicsRef physics, PxPlanef plane, PxMaterialRef material);

void pxSceneAddActor(PxSceneRef scene, PxActorRef actor);
bool pxSceneSimulate(PxSceneRef scene, float dt);
bool pxSceneFetchResults(PxSceneRef scene, bool block);

