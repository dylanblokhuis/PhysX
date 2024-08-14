#include <ctype.h>
#include <stdio.h>

#include "PxPhysicsAPI.h"

using namespace physx;

static PxDefaultAllocator gAllocator;
static PxDefaultErrorCallback gErrorCallback;
static PxDefaultCpuDispatcher *gDispatcher = NULL;

extern "C"
{
#include "wrapper.h"


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
    sceneDesc.filterShader = PxDefaultSimulationFilterShader;
    return physics->createScene(sceneDesc);
  }

  PxMaterialRef pxPhysicsCreateMaterial(PxPhysicsRef physics, float dynamicFriction, float staticFriction, float restitution)
  {
    return physics->createMaterial(dynamicFriction, staticFriction, restitution);
  }

  PxRigidStaticRef pxCreateRigidStatic(PxPhysicsRef physics, PxTransformf transform)
  {
    return physics->createRigidStatic(reinterpret_cast<PxTransform &>(transform));
  }

  PxRigidDynamicRef pxCreateRigidDynamic(PxPhysicsRef physics, PxTransformf transform)
  {
    return physics->createRigidDynamic(reinterpret_cast<PxTransform &>(transform));
  }

  PxShapeRef pxCreateShape(PxPhysicsRef physics, PxGeometryRef geometry, PxMaterialRef material, bool isExclusive)
  {
    return physics->createShape(*geometry, *material, isExclusive);
  }

  PxGeometryRef pxCreatePlaneGeometry()
  {
    return PxGeometryRef(new PxPlaneGeometry());
  }

  PxGeometryRef pxCreateBoxGeometry(PxVec3f halfExtents)
  {
    return PxGeometryRef(new PxBoxGeometry(halfExtents.x, halfExtents.y, halfExtents.z));
  }

  PxGeometryRef pxCreateSphereGeometry(C_PxReal radius)
  {
    return PxGeometryRef(new PxSphereGeometry(radius));
  }

  PxRigidStaticRef pxCreatePlane(PxPhysicsRef physics, PxPlanef plane, PxMaterialRef material)
  {
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

  C_PxU32 pxSceneGetNbActors(PxSceneRef scene, C_PxActorTypeFlag flags)
  {
    return scene->getNbActors(PxActorTypeFlags(flags));
  }

  C_PxU32 pxSceneGetActors(PxSceneRef scene, C_PxActorTypeFlag flags, PxActorRef *actors, C_PxU32 bufferSize, C_PxU32 startIndex)
  {
    return scene->getActors(PxActorTypeFlags(flags), actors, bufferSize, startIndex);
  }

  bool pxActorIsRigid(PxActorRef actor)
  {
    return actor->is<PxRigidStatic>();
  }

  bool pxRigidActorAttachShape(PxRigidActorRef actor, PxShapeRef shape)
  {
    return actor->attachShape(*shape);
  }

  C_PxU32 pxRigidActorGetNbShapes(PxRigidActorRef actor)
  {
    return actor->getNbShapes();
  }
  C_PxU32 pxRigidActorGetShapes(PxRigidActorRef actor, PxShapeRef *shapes, C_PxU32 size, C_PxU32 startIndex)
  {
    return actor->getShapes(shapes, size, startIndex);
  }

  PxMat44f pxShapeGetGlobalPose(PxShapeRef shape, PxRigidActorRef actor)
  {
    PxMat44 shapePose(PxShapeExt::getGlobalPose(*shape, *actor));
    return reinterpret_cast<PxMat44f &>(shapePose);
  }
};