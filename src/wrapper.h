#include <stdbool.h>
#include <stdint.h>

typedef struct PxFoundation *PxFoundationRef;
typedef struct PxPhysics *PxPhysicsRef;
typedef struct PxPvd *PxPvdRef;
typedef struct PxScene *PxSceneRef;
typedef struct PxMaterial *PxMaterialRef;
typedef struct PxRigidStatic *PxRigidStaticRef;
typedef struct PxRigidDynamic *PxRigidDynamicRef;
typedef struct PxActor *PxActorRef;
typedef struct PxRigidActor *PxRigidActorRef;
typedef struct PxShape *PxShapeRef;
typedef struct PxGeometry *PxGeometryRef;

typedef struct PxVec3f
{
	float x, y, z;
} PxVec3f;

typedef struct PxVec4f
{
	float x, y, z, w;
} PxVec4f;

typedef struct PxQuatf
{
	float x, y, z, w;
} PxQuatf;

typedef struct PxMat44f
{
	PxVec4f column0, column1, column2, column3;
} PxMat44f;

typedef struct PxTransformf
{
	PxQuatf q;
	PxVec3f p;
} PxTransformf;

typedef uint32_t C_PxU32;
typedef uint16_t C_PxU16;
typedef float C_PxReal;

// PxActorTypeFlag is a uint16_t enum
typedef C_PxU16 C_PxActorTypeFlag;
#define C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC (1 << 0)
#define C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC (1 << 1)
#define C_PX_ACTOR_TYPE_FLAG_ALL (C_PX_ACTOR_TYPE_FLAG_RIGID_DYNAMIC | C_PX_ACTOR_TYPE_FLAG_RIGID_STATIC)

// all geometry structs
typedef struct C_PxPlaneGeometry
{

} C_PxPlaneGeometry;

typedef struct C_PxBoxGeometry
{
	PxVec3f halfExtents;
} C_PxBoxGeometry;

typedef struct C_PxSphereGeometry
{
	C_PxReal radius;
} C_PxSphereGeometry;

typedef C_PxU16 C_PxGeometryType;
#define C_PX_GEOMETRY_TYPE_SPHERE 0
#define C_PX_GEOMETRY_TYPE_PLANE 1
#define C_PX_GEOMETRY_TYPE_CAPSULE 2
#define C_PX_GEOMETRY_TYPE_BOX 3
#define C_PX_GEOMETRY_TYPE_CONVEXMESH 4
#define C_PX_GEOMETRY_TYPE_PARTICLESYSTEM 5
#define C_PX_GEOMETRY_TYPE_TETRAHEDRONMESH 6
#define C_PX_GEOMETRY_TYPE_TRIANGLEMESH 7
#define C_PX_GEOMETRY_TYPE_HEIGHTFIELD 8
#define C_PX_GEOMETRY_TYPE_HAIRSYSTEM 9
#define C_PX_GEOMETRY_TYPE_CUSTOM 10

PxFoundationRef pxCreateFoundation();
PxPvdRef pxCreatePvd(PxFoundationRef foundation);
PxPhysicsRef pxCreatePhysics(PxFoundationRef foundation, PxPvdRef pvd);

PxSceneRef pxPhysicsCreateScene(PxPhysicsRef physics);
PxMaterialRef pxPhysicsCreateMaterial(PxPhysicsRef physics, float dynamicFriction, float staticFriction, float restitution);

PxRigidStaticRef pxCreateRigidStatic(PxPhysicsRef physics, PxTransformf transform);
PxRigidDynamicRef pxCreateRigidDynamic(PxPhysicsRef physics, PxTransformf transform);
PxShapeRef pxCreateShape(PxPhysicsRef physics, const PxGeometryRef geometry, PxMaterialRef material, bool isExclusive);

PxGeometryRef pxCreatePlaneGeometry();
PxGeometryRef pxCreateBoxGeometry(PxVec3f halfExtents);
PxGeometryRef pxCreateSphereGeometry(C_PxReal radius);

void pxSceneAddActor(PxSceneRef scene, PxActorRef actor);
bool pxSceneSimulate(PxSceneRef scene, float dt);
bool pxSceneFetchResults(PxSceneRef scene, bool block);
C_PxU32 pxSceneGetNbActors(PxSceneRef scene, C_PxActorTypeFlag flags);
C_PxU32 pxSceneGetActors(PxSceneRef scene, C_PxActorTypeFlag flags, PxActorRef *actors, C_PxU32 size, C_PxU32 startIndex);

bool pxActorIsRigid(PxActorRef actor);

bool pxRigidActorAttachShape(PxRigidActorRef actor, PxShapeRef shape);
C_PxU32 pxRigidActorGetNbShapes(PxRigidActorRef actor);
C_PxU32 pxRigidActorGetShapes(PxRigidActorRef actor, PxShapeRef *shapes, C_PxU32 size, C_PxU32 startIndex);

PxMat44f pxShapeGetGlobalPose(PxShapeRef shape, PxRigidActorRef actor);
PxGeometryRef pxShapeGetGeometry(PxShapeRef shape);

C_PxGeometryType pxGeometryGetType(PxGeometryRef geometry);
C_PxBoxGeometry pxGeometryGetBox(PxGeometryRef geometry);
C_PxSphereGeometry pxGeometryGetSphere(PxGeometryRef geometry);