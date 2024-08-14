#include <ctype.h>

#include "PxPhysicsAPI.h"

using namespace physx;

static PxDefaultAllocator gAllocator;
static PxDefaultErrorCallback gErrorCallback;
static PxDefaultCpuDispatcher *gDispatcher = NULL;

extern "C"
{
#include "wrapper.h"

  // typedef struct PxFoundation* PxFoundationRef;
  // typedef struct PxPhysics* PxPhysicsRef;
  // typedef struct PxPvd* PxPvdRef;

  PxFoundationRef pxCreateFoundation()
  {
    return PxCreateFoundation(PX_PHYSICS_VERSION, gAllocator, gErrorCallback);
  }

  PxPvdRef pxCreatePvd(PxFoundationRef foundation)
  {
    return PxCreatePvd(*foundation);
  }

  PxPhysicsRef pxCreatePhysics(PxFoundationRef foundation, PxPvdRef pvd)
  {
    return PxCreatePhysics(PX_PHYSICS_VERSION, *foundation, PxTolerancesScale(), true, pvd);
  }

  PxSceneRef pxPhysicsCreateScene(PxPhysicsRef physics)
  {
    PxSceneDesc sceneDesc(physics->getTolerancesScale());
    sceneDesc.gravity = PxVec3(0.0f, -9.81f, 0.0f);
    gDispatcher = PxDefaultCpuDispatcherCreate(2);
    sceneDesc.cpuDispatcher = gDispatcher;
    return physics->createScene(sceneDesc);
  }

  PxMaterialRef pxPhysicsCreateMaterial(PxPhysicsRef physics, float dynamicFriction, float staticFriction, float restitution) {
    return physics->createMaterial(dynamicFriction, staticFriction, restitution);
  }

  PxRigidStaticRef pxCreatePlane(PxPhysicsRef physics, PxPlanef plane, PxMaterialRef material) {
      return PxCreatePlane(*physics, PxPlane(plane.normal.x, plane.normal.y, plane.normal.z, plane.distance), *material);
  }

  void pxSceneAddActor(PxSceneRef scene, PxActorRef actor)
  {
    scene->addActor(*actor);
  }

  bool pxSceneSimulate(PxSceneRef scene, float dt)
  {
    return scene->simulate(dt);
  }

  bool pxSceneFetchResults(PxSceneRef scene, bool block)
  {
    return scene->fetchResults(block);
  }

  

  

};