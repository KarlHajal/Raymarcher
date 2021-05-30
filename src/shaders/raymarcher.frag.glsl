precision highp float;

#define PI 3.14159265359

#define NUM_AMBIENT_OCCLUSION_SAMPLES 32
#define MAX_MARCHING_STEPS 255
#define MIN_DISTANCE 0.0
#define MAX_DISTANCE 100.0
#define EPSILON 0.001
#define MAX_RANGE 1e6
//#define NUM_REFLECTIONS

//#define ENVIRONMENT_MAPPING
uniform samplerCube cubemap_texture;

//#define SOFT_SHADOWS
uniform float soft_shadows_factor;

const int SPHERE_ID = 1;
const int PLANE_ID = 2;
const int CYLINDER_ID = 3;
const int BOX_ID = 4;
const int TORUS_ID = 5;
const int TRIANGLE_ID = 6;
const int LINK_ID = 7;
const int CONE_ID = 8;
const int HEXAGONAL_ID = 9;
const int TRIANGULAR_ID = 10;
const int ELLIPSOID_ID = 11;
const int OCTAHEDRON_ID = 12;
const int PYRAMID_ID = 13;

struct ShapesCombination {
	int shape1_id;
	int shape1_index;
	int shape2_id;
	int shape2_index;
	int material_id;
	float smooth_factor;
};

//#define NUM_COMBINATIONS
#if NUM_COMBINATIONS != 0
uniform ShapesCombination combinations[NUM_COMBINATIONS];
#endif

//#define NUM_INTERSECTIONS
//#define NUM_UNIONS
//#define NUM_SUBTRACTIONS


//#define NUM_SPHERES
#if NUM_SPHERES != 0
uniform vec4 spheres_center_radius[NUM_SPHERES]; // ...[i] = [center_x, center_y, center_z, radius]
#endif
//#define COMBINATION_NUM_SPHERES
#if COMBINATION_NUM_SPHERES != 0
uniform vec4 combination_spheres_center_radius[COMBINATION_NUM_SPHERES];
#endif

//#define NUM_PLANES
#if NUM_PLANES != 0
uniform vec4 planes_normal_offset[NUM_PLANES]; // ...[i] = [nx, ny, nz, d] such that dot(vec3(nx, ny, nz), point_on_plane) = d
#endif
//#define COMBINATION_NUM_PLANES
#if COMBINATION_NUM_PLANES != 0
uniform vec4 combination_planes_normal_offset[COMBINATION_NUM_PLANES];
#endif

//#define NUM_CYLINDERS
struct Cylinder {
	vec3 center;
	vec3 axis;
	float radius;
	float height;
	int is_capsule;
};
#if NUM_CYLINDERS != 0
uniform Cylinder cylinders[NUM_CYLINDERS];
#endif
//#define COMBINATION_NUM_CYLINDERS
#if COMBINATION_NUM_CYLINDERS != 0
uniform Cylinder combination_cylinders[COMBINATION_NUM_CYLINDERS];
#endif

//#define NUM_BOXES
struct Box {
	vec3 center;
	float length;
	float width;
	float height;
	float rotation_x;
	float rotation_y;
	float rotation_z;
	float rounded_edges_radius;
	int is_frame;
};
#if NUM_BOXES != 0
uniform Box boxes[NUM_BOXES];
#endif
//#define COMBINATION_NUM_BOXES
#if COMBINATION_NUM_BOXES != 0
uniform Box combination_boxes[COMBINATION_NUM_BOXES];
#endif

//#define NUM_TORUSES
struct Torus {
	vec3 center;
	vec2 radi; // x = big radius, y = small radius
	float rotation_x;
	float rotation_y;
	float rotation_z;
};
#if NUM_TORUSES != 0
uniform Torus toruses[NUM_TORUSES];
#endif
//#define COMBINATION_NUM_TORUSES
#if COMBINATION_NUM_TORUSES != 0
uniform Torus combination_toruses[COMBINATION_NUM_TORUSES];
#endif

//#define NUM_CONES
struct Cone {
	vec3 center;
	vec2 sin_cos;
	float height;
};
#if NUM_CONES != 0
uniform Cone cones[NUM_CONES];
#endif
//#define COMBINATION_NUM_CONES
#if COMBINATION_NUM_CONES != 0
uniform Cone combination_cones[COMBINATION_NUM_CONES];
#endif

//#define NUM_HEXAGONALS
struct Hexagonal {
	vec3 center;
	vec2 heights;
};
#if NUM_HEXAGONALS != 0
uniform Hexagonal hexagonals[NUM_HEXAGONALS];
#endif
//#define COMBINATION_NUM_HEXAGONALS
#if COMBINATION_NUM_HEXAGONALS != 0
uniform Hexagonal combination_hexagonals[COMBINATION_NUM_HEXAGONALS];
#endif

//#define NUM_TRIANGULARS
struct Triangular {
	vec3 center;
	vec2 heights;
};
#if NUM_TRIANGULARS != 0
uniform Triangular triangulars[NUM_TRIANGULARS];
#endif
//#define COMBINATION_NUM_TRIANGULARS
#if COMBINATION_NUM_TRIANGULARS != 0
uniform Triangular combination_triangulars[COMBINATION_NUM_TRIANGULARS];
#endif

//#define NUM_ELLIPSOIDS
struct Ellipsoid {
	vec3 center;
	vec3 radius;
};
#if NUM_ELLIPSOIDS != 0
uniform Ellipsoid ellipsoids[NUM_ELLIPSOIDS];
#endif
//#define COMBINATION_NUM_ELLIPSOIDS
#if COMBINATION_NUM_ELLIPSOIDS != 0
uniform Ellipsoid combination_ellipsoids[COMBINATION_NUM_ELLIPSOIDS];
#endif

//#define NUM_OCTAHEDRONS
struct Octahedron {
	vec3 center;
	float length;
};
#if NUM_OCTAHEDRONS != 0
uniform Octahedron octahedrons[NUM_OCTAHEDRONS];
#endif
//#define COMBINATION_NUM_OCTAHEDRONS
#if COMBINATION_NUM_OCTAHEDRONS != 0
uniform Octahedron combination_octahedrons[COMBINATION_NUM_OCTAHEDRONS];
#endif

//#define NUM_PYRAMIDS
struct Pyramid {
	vec3 center;
	float height;
};
#if NUM_PYRAMIDS != 0
uniform Pyramid pyramids[NUM_PYRAMIDS];
#endif
//#define COMBINATION_NUM_PYRAMIDS
#if COMBINATION_NUM_PYRAMIDS != 0
uniform Pyramid combination_pyramids[COMBINATION_NUM_PYRAMIDS];
#endif

//#define NUM_LINKS
struct Link {
	vec3 center;
	float length;
	float radius1;
	float radius2;
};
#if NUM_LINKS != 0
uniform Link links[NUM_LINKS];
#endif
//#define COMBINATION_NUM_LINKS
#if COMBINATION_NUM_LINKS != 0
uniform Link combination_links[COMBINATION_NUM_LINKS];
#endif

//#define NUM_TRIANGLES
struct Triangle {
	vec3 vertice1;
	vec3 vertice2;
	vec3 vertice3;
// 	mat3 normals;
};
#if NUM_TRIANGLES != 0
uniform Triangle triangles[NUM_TRIANGLES];
#endif
//#define COMBINATION_NUM_TRIANGLES
#if COMBINATION_NUM_TRIANGLES != 0
uniform Triangle combination_triangles[COMBINATION_NUM_TRIANGLES];
#endif

// materials
//#define NUM_MATERIALS
struct Material {
	vec3 color;
	float ambient;
	float diffuse;
	float specular;
	float shininess;
	float mirror;
};
uniform Material materials[NUM_MATERIALS];
#if (NUM_SPHERES != 0) || (NUM_PLANES != 0) || (NUM_CYLINDERS != 0) || (NUM_BOXES != 0) || (NUM_TORUSES != 0) || (NUM_TRIANGLES != 0) || (NUM_LINKS != 0) || (NUM_CONES != 0) || (NUM_HEXAGONALS != 0) || (NUM_TRIANGULARS != 0) || (NUM_ELLIPSOIDS != 0) || (NUM_OCTAHEDRONS != 0) || (NUM_PYRAMIDS != 0) 
uniform int object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_ELLIPSOIDS + NUM_OCTAHEDRONS + NUM_PYRAMIDS];
#endif
//#define NUM_LIGHTS
struct Light {
	vec3 color;
	vec3 position;
};
#if NUM_LIGHTS != 0
uniform Light lights[NUM_LIGHTS];
#endif
uniform vec3 light_color_ambient;

varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

Material get_mat2(int mat_id) {
	Material m = materials[0];
	for(int mi = 1; mi < NUM_MATERIALS; mi++) {
		if(mi == mat_id) {
			m = materials[mi];
		}
	}
	return m;
}

#if COMBINATION_NUM_SPHERES != 0
vec4 get_sphere(int sphere_index){
	for(int i = 0; i < COMBINATION_NUM_SPHERES; ++i){
		if(i == sphere_index){
			return combination_spheres_center_radius[i];
		}
	}
	return combination_spheres_center_radius[0];
}
#endif

#if COMBINATION_NUM_PLANES != 0
vec4 get_plane(int plane_index){
	for(int i = 0; i < COMBINATION_NUM_PLANES; ++i){
		if(i == plane_index){
			return combination_planes_normal_offset[i];
		}
	}
	return combination_planes_normal_offset[0];
}
#endif

#if COMBINATION_NUM_CYLINDERS != 0
Cylinder get_cylinder(int cylinder_index) {
	for(int i = 0; i < COMBINATION_NUM_CYLINDERS; ++i){
		if(i == cylinder_index){
			return combination_cylinders[i];
		}
	}
	return combination_cylinders[0];
}
#endif

#if COMBINATION_NUM_BOXES != 0
Box get_box(int box_index) {
	for(int i = 0; i < COMBINATION_NUM_BOXES; ++i){
		if(i == box_index){
			return combination_boxes[i];
		}
	}
	return combination_boxes[0];
}
#endif

#if COMBINATION_NUM_TORUSES != 0
Torus get_torus(int torus_index) {
	for(int i = 0; i < COMBINATION_NUM_TORUSES; ++i){
		if(i == torus_index){
			return combination_toruses[i];
		}
	}
	return combination_toruses[0];
}
#endif

#if COMBINATION_NUM_CONES != 0
Cone get_cone(int cone_index) {
	for(int i = 0; i < COMBINATION_NUM_CONES; ++i){
		if(i == cone_index){
			return combination_cones[i];
		}
	}
	return combination_cones[0];
}
#endif

#if COMBINATION_NUM_HEXAGONALS != 0
Hexagonal get_hexagonal(int hexagonal_index) {
	for(int i = 0; i < COMBINATION_NUM_HEXAGONALS; ++i){
		if(i == hexagonal_index){
			return combination_hexagonals[i];
		}
	}
	return combination_hexagonals[0];
}
#endif

#if COMBINATION_NUM_ELLIPSOIDS != 0
Ellipsoid get_ellipsoid(int ellipsoid_index) {
	for(int i = 0; i < COMBINATION_NUM_ELLIPSOIDS; ++i){
		if(i == ellipsoid_index){
			return combination_ellipsoids[i];
		}
	}
	return combination_ellipsoids[0];
}
#endif

#if COMBINATION_NUM_LINKS != 0
Link get_link(int link_index) {
	for(int i = 0; i < COMBINATION_NUM_LINKS; ++i){
		if(i == link_index){
			return combination_links[i];
		}
	}
	return combination_links[0];
}
#endif

#if COMBINATION_NUM_OCTAHEDRONS != 0
Octahedron get_octahedron(int octahedron_index) {
	for(int i = 0; i < COMBINATION_NUM_OCTAHEDRONS; ++i){
		if(i == octahedron_index){
			return combination_octahedrons[i];
		}
	}
	return combination_octahedrons[0];
}
#endif

#if COMBINATION_NUM_PYRAMIDS != 0
Pyramid get_pyramid(int pyramid_index) {
	for(int i = 0; i < COMBINATION_NUM_PYRAMIDS; ++i){
		if(i == pyramid_index){
			return combination_pyramids[i];
		}
	}
	return combination_pyramids[0];
}
#endif

#if COMBINATION_NUM_TRIANGLES != 0
Triangle get_triangle(int triangle_index) {
	for(int i = 0; i < COMBINATION_NUM_TRIANGLES; ++i){
		if(i == triangle_index){
			return combination_triangles[i];
		}
	}
	return combination_triangles[0];
}
#endif

#if COMBINATION_NUM_TRIANGULARS != 0
Triangular get_triangular(int triangular_index) {
	for(int i = 0; i < COMBINATION_NUM_TRIANGULARS; ++i){
		if(i == triangular_index){
			return combination_triangulars[i];
		}
	}
	return combination_triangulars[0];
}
#endif

mat4 rotation_x (float angle) {
	return mat4(1.0, 0., 0., 0.,
			 	0., cos(angle), -sin(angle), 0.,
				0., sin(angle), cos(angle),	0.,
				0.,	0., 0., 1.);
}

mat4 rotation_y(float angle) {
	return mat4(cos(angle),	0., sin(angle), 0.,
			 	0., 1.0,	0., 0.,
				-sin(angle), 0.,	cos(angle),	0.,
				0., 0., 0., 1.);
}

mat4 rotation_z(float angle) {
	return mat4(cos(angle),	-sin(angle), 0., 0.,
			 	sin(angle),	cos(angle),	0., 0.,
				0., 0., 1., 0.,
				0., 0., 0., 1.);
}


float sphere_sdf(vec3 sample_point, vec4 sphere_center_radius) {
    return length(sphere_center_radius.xyz - sample_point) - sphere_center_radius[3];
}

float plane_sdf(vec3 sample_point, vec4 planes_normal_offset) {
	vec3 plane_normal = planes_normal_offset.xyz;
	float plane_offset = planes_normal_offset[3];
	vec3 point_on_plane = plane_normal * plane_offset;
	return abs(dot(sample_point - point_on_plane, plane_normal));
}

float capped_cylinder_sdf(vec3 sample_point, Cylinder cylinder) {
	vec3 bottom_center = cylinder.center + cylinder.axis * cylinder.height/2.;
	vec3 top_center = cylinder.center - cylinder.axis * cylinder.height/2.;

	vec3  ba = top_center - bottom_center;
	vec3  pa = sample_point - bottom_center;
	
	if(cylinder.is_capsule == 1){
		float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
		return length( pa - ba*h ) - cylinder.radius;
	}

	float baba = dot(ba,ba);
	float paba = dot(pa,ba);
	float x = length(pa*baba-ba*paba) - cylinder.radius*baba;
	float y = abs(paba-baba*0.5)-baba*0.5;
	float x2 = x*x;
	float y2 = y*y*baba;
	float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
	return sign(d)*sqrt(abs(d))/baba;
}

float dot2( in vec3 v ) { return dot(v,v); }


float triangle_sdf( vec3 p, Triangle triangle){
	vec3 a = triangle.vertice1; 
	vec3 b = triangle.vertice2;
	vec3 c = triangle.vertice3;

	vec3 ba = b - a; vec3 pa = p - a;
	vec3 cb = c - b; vec3 pb = p - b;
	vec3 ac = a - c; vec3 pc = p - c;
	vec3 nor = cross( ba, ac );

	return sqrt(
		(sign(dot(cross(ba,nor),pa)) +
		sign(dot(cross(cb,nor),pb)) +
		sign(dot(cross(ac,nor),pc))<2.0)
		?
		min( min(
		dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
		dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
		dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
		:
		dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

float link_sdf( vec3 p, Link link)
{
	float le = link.length;
	float r1 = link.radius1;
	float r2 = link.radius2;
	vec3 center = link.center;
	vec3 p2 = p - center; 
	vec3 q = vec3( p2.x, max(abs(p2.y)-le,0.0), p2.z);
	return length(vec2(length(q.xy)-r1,q.z)) - r2 ;
}

vec3 transform_point_to_centered_shape(vec3 point, vec3 shape_center, float shape_rotation_x, float shape_rotation_y, float shape_rotation_z){
	vec4 translated_point = vec4((point - shape_center), 1.0);
	return (translated_point * rotation_x(-shape_rotation_x) * rotation_y(-shape_rotation_y) * rotation_z(-shape_rotation_z)).xyz;
}

float torus_sdf(vec3 sample_point, Torus torus) {
	vec3 transformed_point = transform_point_to_centered_shape(sample_point, torus.center, torus.rotation_x, torus.rotation_y, torus.rotation_z);
	vec2 q = vec2(length(transformed_point.xz)-torus.radi.x, transformed_point.y);
	return length(q) - torus.radi.y;
}

float box_sdf(vec3 sample_point, Box box){
	vec3 transformed_point = transform_point_to_centered_shape(sample_point, box.center, box.rotation_x, box.rotation_y, box.rotation_z);
	vec3 b = vec3(box.length, box.width, box.height)/2.;
	vec3 q = abs(transformed_point) - b; 
	if(box.is_frame == 1){
		vec3 p = q;
		vec3 q = abs(p + 0.05) - 0.05;
		return min(min(
					length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
					length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
					length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0)) - box.rounded_edges_radius;
	}
  	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded_edges_radius;
}

float cone_sdf( in vec3 p, Cone cone)
{
	vec2 c = cone.sin_cos;
	float h = cone.height;
	vec3 center = cone.center;
	// c is the sin/cos of the angle, h is height
	// Alternatively pass q instead of (c,h),
	// which is the point at the base in 2D
	vec3 p2 = p - center;
	vec2 q = h*vec2(c.x/c.y,-1.0);
		
	vec2 w = vec2( length(p2.xz), p2.y );
	vec2 a = w - q*clamp( dot(w,q)/dot(q,q), 0.0, 1.0 );
	vec2 b = w - q*vec2( clamp( w.x/q.x, 0.0, 1.0 ), 1.0 );
	float k = sign( q.y );
	float d = min(dot( a, a ),dot(b, b));
	float s = max( k*(w.x*q.y-w.y*q.x),k*(w.y-q.y)  );
	return sqrt(d)*sign(s);
}

float hex_prism_sdf( vec3 p, Hexagonal hexagonal)
{
	vec3 center = hexagonal.center; 
	vec2 h = hexagonal.heights;
	vec3 p2 = p - center;
	const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
	p2 = abs(p2);
	p2.xy -= 2.0*min(dot(k.xy, p2.xy), 0.0)*k.xy;
	vec2 d = vec2(
		length(p2.xy-vec2(clamp(p2.x,-k.z*h.x,k.z*h.x), h.x))*sign(p2.y-h.x),
		p2.z-h.y );
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float triangular_sdf( vec3 p, Triangular triangular)
{
	vec3 center = triangular.center;
	vec2 h = triangular.heights;
	p = p - center;
	vec3 q = abs(p);
	return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float ellipsoid_sdf( vec3 p, Ellipsoid ellipsoid)
{
	vec3 center = ellipsoid.center;
	vec3 r = ellipsoid.radius;
	p = p - center;
	float k0 = length(p/r);
	float k1 = length(p/(r*r));
	return k0*(k0-1.0)/k1;
}

float octahedron_sdf( vec3 p, Octahedron octahedron)
{
	vec3 center = octahedron.center;
	float s = octahedron.length;
	p = p - center;
	p = abs(p);
	float m = p.x+p.y+p.z-s;
	vec3 q;
		if( 3.0*p.x < m ) q = p.xyz;
	else if( 3.0*p.y < m ) q = p.yzx;
	else if( 3.0*p.z < m ) q = p.zxy;
	else return m*0.57735027;
		
	float k = clamp(0.5*(q.z-q.y+s),0.0,s); 
	return length(vec3(q.x,q.y-s+k,q.z-k)); 
}

float pyramid_sdf( vec3 p, Pyramid pyramid)
{
	vec3 center = pyramid.center;
	float h = pyramid.height;

	p = p - center;
	float m2 = h*h + 0.25;
		
	p.xz = abs(p.xz);
	p.xz = (p.z>p.x) ? p.zx : p.xz;
	p.xz -= 0.5;

	vec3 q = vec3( p.z, h*p.y - 0.5*p.x, h*p.x + 0.5*p.y);
	
	float s = max(-q.x,0.0);
	float t = clamp( (q.y-0.5*p.z)/(m2+0.25), 0.0, 1.0 );
		
	float a = m2*(q.x+s)*(q.x+s) + q.y*q.y;
	float b = m2*(q.x+0.5*t)*(q.x+0.5*t) + (q.y-m2*t)*(q.y-m2*t);
		
	float d2 = min(q.y,-q.x*m2-q.y*0.5) > 0.0 ? 0.0 : min(a,b);
		
	return sqrt( (d2+q.z*q.z)/m2 ) * sign(max(q.z,-p.y));
}

void primitives_sdf(vec3 sample_point, out float min_distance, out int material_id){
	#if NUM_SPHERES != 0
	for(int i = 0; i < NUM_SPHERES; i++) {
		float object_distance = sphere_sdf(sample_point, spheres_center_radius[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[i];
		}
	}
	#endif

	#if NUM_PLANES != 0 
	for(int i = 0; i < NUM_PLANES; i++) {
		float object_distance = plane_sdf(sample_point, planes_normal_offset[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES+i];
		}
	}
	#endif

	#if NUM_CYLINDERS != 0 
	for(int i = 0; i < NUM_CYLINDERS; i++) {
		float object_distance = capped_cylinder_sdf(sample_point, cylinders[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + i];
		}
	}
	#endif

	#if NUM_BOXES != 0
	for(int i = 0; i < NUM_BOXES; ++i) {
		float object_distance = box_sdf(sample_point, boxes[i]);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + i];
		}
	}
	#endif

	#if NUM_TORUSES != 0
	for(int i = 0; i < NUM_TORUSES; ++i) {
		float object_distance = torus_sdf(sample_point, toruses[i]);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + i];
		}
	}
	#endif

	#if NUM_TRIANGLES != 0
	for(int i = 0; i < NUM_TRIANGLES; i++) {
		float object_distance = triangle_sdf(sample_point, triangles[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + i];
		}
	}
	#endif

	#if NUM_LINKS != 0
	for(int i = 0; i < NUM_LINKS; i++) {
		float object_distance = link_sdf(sample_point, links[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + i];
		}
	}
	#endif

	#if NUM_CONES != 0
	for(int i = 0; i < NUM_CONES; i++) {
		float object_distance = cone_sdf(sample_point, cones[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + i];
		}
	}
	#endif

	#if NUM_HEXAGONALS != 0
	for(int i = 0; i < NUM_HEXAGONALS; i++) {
		float object_distance = hex_prism_sdf(sample_point, hexagonals[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + i];
		}
	}
	#endif

	#if NUM_TRIANGULARS != 0
	for(int i = 0; i < NUM_TRIANGULARS; i++) {
		float object_distance = triangular_sdf(sample_point, triangulars[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + i];
		}
	}
	#endif

	#if NUM_ELLIPSOIDS != 0
	for(int i = 0; i < NUM_ELLIPSOIDS; i++) {
		float object_distance = ellipsoid_sdf(sample_point, ellipsoids[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + i];
		}
	}
	#endif

	#if NUM_OCTAHEDRONS != 0
	for(int i = 0; i < NUM_OCTAHEDRONS; i++) {
		float object_distance = octahedron_sdf(sample_point, octahedrons[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_ELLIPSOIDS + i];
		}
	}
	#endif

	#if NUM_PYRAMIDS != 0
	for(int i = 0; i < NUM_PYRAMIDS; i++) {
		float object_distance = pyramid_sdf(sample_point, pyramids[i]);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TORUSES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_ELLIPSOIDS + NUM_OCTAHEDRONS + i];
		}
	}
	#endif
}

float shape_sdf(vec3 sample_point, int shape_id, int shape_index){

	#if COMBINATION_NUM_SPHERES != 0
	if(shape_id == SPHERE_ID){
		return sphere_sdf(sample_point, get_sphere(shape_index));
	}
	#endif

	#if COMBINATION_NUM_PLANES != 0
	if(shape_id == PLANE_ID){
		return plane_sdf(sample_point, get_plane(shape_index));
	}
	#endif
	
	#if COMBINATION_NUM_CYLINDERS != 0
	if(shape_id == CYLINDER_ID){
		return capped_cylinder_sdf(sample_point, get_cylinder(shape_index));
	}
	#endif

	#if COMBINATION_NUM_BOXES != 0
	if (shape_id == BOX_ID){
		return box_sdf(sample_point, get_box(shape_index));
	}
	#endif

	#if COMBINATION_NUM_TORUSES != 0
	if(shape_id == TORUS_ID){
		return torus_sdf(sample_point, get_torus(shape_index));
	}
	#endif

	#if COMBINATION_NUM_TRIANGLES != 0
	if(shape_id == TRIANGLE_ID){
		return triangle_sdf(sample_point, get_triangle(shape_index));
	}
	#endif
	
	#if COMBINATION_NUM_CONES != 0
	if(shape_id == CONE_ID){
		return cone_sdf(sample_point, get_cone(shape_index));
	}
	#endif

	#if COMBINATION_NUM_ELLIPSOIDS != 0
	if (shape_id == ELLIPSOID_ID){
		return ellipsoid_sdf(sample_point, get_ellipsoid(shape_index));
	}
	#endif

	#if COMBINATION_NUM_HEXAGONALS != 0
	if(shape_id == HEXAGONAL_ID){
		return hex_prism_sdf(sample_point, get_hexagonal(shape_index));
	}
	#endif

	#if COMBINATION_NUM_LINKS != 0
	if(shape_id == LINK_ID){
		return link_sdf(sample_point, get_link(shape_index));
	}
	#endif
	
	#if COMBINATION_NUM_OCTAHEDRONS != 0
	if(shape_id == OCTAHEDRON_ID){
		return octahedron_sdf(sample_point, get_octahedron(shape_index));
	}
	#endif

	#if COMBINATION_NUM_PYRAMIDS != 0
	if (shape_id == PYRAMID_ID){
		return pyramid_sdf(sample_point, get_pyramid(shape_index));
	}
	#endif

	#if COMBINATION_NUM_TRIANGULARS != 0
	if(shape_id == TRIANGULAR_ID){
		return triangular_sdf(sample_point, get_triangular(shape_index));
	}
	#endif

	return MAX_RANGE;
}

float intersection_sdf(float shape1_distance, float shape2_distance, float smooth_factor){
	float h = clamp( 0.5 - 0.5*(shape2_distance-shape1_distance)/smooth_factor, 0.0, 1.0 );
    return mix( shape2_distance, shape1_distance, h ) + smooth_factor*h*(1.0-h);
}

void intersections_sdf(vec3 sample_point, out float min_distance, out int material_id){
	#if NUM_INTERSECTIONS != 0
	for(int i = 0; i < NUM_INTERSECTIONS; ++i) {
		ShapesCombination intersection = combinations[i];

		float shape1_distance = shape_sdf(sample_point, intersection.shape1_id, intersection.shape1_index);
		float shape2_distance = shape_sdf(sample_point, intersection.shape2_id, intersection.shape2_index);

		float object_distance = intersection_sdf(shape1_distance, shape2_distance, intersection.smooth_factor);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = intersection.material_id;
		}
	}
	#endif
}

float union_sdf(float shape1_distance, float shape2_distance, float smooth_factor){
	float h = clamp( 0.5 + 0.5*(shape2_distance-shape1_distance)/smooth_factor, 0.0, 1.0 );
    return mix( shape2_distance, shape1_distance, h ) - smooth_factor*h*(1.0-h);
}

void unions_sdf(vec3 sample_point, out float min_distance, out int material_id){
	#if NUM_UNIONS != 0
	for(int i = 0; i < NUM_UNIONS; ++i) {
		ShapesCombination zunion = combinations[NUM_INTERSECTIONS + i];

		float shape1_distance = shape_sdf(sample_point, zunion.shape1_id, zunion.shape1_index);
		float shape2_distance = shape_sdf(sample_point, zunion.shape2_id, zunion.shape2_index);

		float object_distance = union_sdf(shape1_distance, shape2_distance, zunion.smooth_factor);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = zunion.material_id;
		}
	}
	#endif
}

float subtraction_sdf(float shape1_distance, float shape2_distance, float smooth_factor){
	float h = clamp( 0.5 - 0.5*(shape2_distance+shape1_distance)/smooth_factor, 0.0, 1.0 );
    return mix( shape2_distance, -shape1_distance, h ) + smooth_factor*h*(1.0-h);
}

void subtractions_sdf(vec3 sample_point, out float min_distance, out int material_id){
	#if NUM_SUBTRACTIONS != 0
	for(int i = 0; i < NUM_SUBTRACTIONS; ++i) {
		ShapesCombination subtraction = combinations[NUM_INTERSECTIONS + NUM_UNIONS + i];

		float shape1_distance = shape_sdf(sample_point, subtraction.shape1_id, subtraction.shape1_index);
		float shape2_distance = shape_sdf(sample_point, subtraction.shape2_id, subtraction.shape2_index);

		float object_distance = subtraction_sdf(shape1_distance, shape2_distance, subtraction.smooth_factor);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = subtraction.material_id;
		}
	}
	#endif
}

float scene_sdf(vec3 sample_point, out int material_id) {

	float min_distance = MAX_RANGE;

	primitives_sdf(sample_point, min_distance, material_id);
	intersections_sdf(sample_point, min_distance, material_id);
	unions_sdf(sample_point, min_distance, material_id);
	subtractions_sdf(sample_point, min_distance, material_id);

    return min_distance;
}

vec3 estimate_normal(vec3 p ) // Tetrahedron technique
{
    const float h = 0.0001; // replace by an appropriate value
    const vec2 k = vec2(1,-1);
	int temp_id;
    return normalize( k.xyy*scene_sdf( p + k.xyy*h, temp_id ) + 
                      k.yyx*scene_sdf( p + k.yyx*h, temp_id ) + 
                      k.yxy*scene_sdf( p + k.yxy*h, temp_id ) + 
                      k.xxx*scene_sdf( p + k.xxx*h, temp_id ) );
}


float shortest_distance_to_surface(vec3 ray_origin, vec3 marching_direction, float start, float end, out int material_id) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {

        float dist = scene_sdf(ray_origin + depth * marching_direction, material_id);
        
		if (dist < EPSILON) {
			return depth;
        }
        
		depth += dist;
        
		if (depth >= end) {
            return end;
        }
    }
    return end;
}

float calculate_soft_shadow(vec3 sample_point, Light light){
	vec3 L = normalize(light.position - sample_point);
	vec3 displaced_origin = sample_point + L * 0.1;
	int temp_id;

	float res = 1.0;
	float depth = MIN_DISTANCE;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {

        float dist = scene_sdf(displaced_origin + depth * L, temp_id);
        
		res = min( res, soft_shadows_factor*dist/depth );
        
		depth += dist;
        
		if ( res < EPSILON || depth > MAX_DISTANCE) {
            break;
        }
    }
	res = clamp( res, 0.0, 1.0 );
    return res*res*(3.0-2.0*res);
}

bool is_shadow(vec3 sample_point, Light light){
    vec3 L = normalize(light.position - sample_point);
	vec3 displaced_origin = sample_point + L * 0.1;
	int temp_id;
	float dist = shortest_distance_to_surface(displaced_origin, L, MIN_DISTANCE, MAX_DISTANCE, temp_id);
	return dist < length(light.position - displaced_origin);
}

vec3 phong_light_contribution(vec3 sample_point, vec3 eye, vec3 normal, Light light, Material material) {

	#if !SOFT_SHADOWS
	if(is_shadow(sample_point, light)){
		return vec3(0.);
	}
	#endif

    vec3 L = normalize(light.position - sample_point);
    float dotLN = dot(L, normal);
    
    if (dotLN < EPSILON) {
        return vec3(0.0, 0.0, 0.0);
    } 
    
    vec3 V = normalize(eye - sample_point);
    vec3 R = normalize(reflect(-L, normal));
    float dotRV = dot(R, V);
	
	
	vec3 color = material.color * light.color * material.diffuse * dotLN;

	#if SOFT_SHADOWS
	color *= calculate_soft_shadow(sample_point, light);
	#endif

    if (dotRV > 0.) {
        color += material.color * light.color * material.specular * pow(dotRV, material.shininess);
    }

    return color;
}

float random(vec2 co)
{
    float a = 12.9898;
    float b = 78.233;
    float c = 43758.5453;
    float dt= dot(co.xy ,vec2(a,b));
    float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

vec3 get_random_hemisphere_ray_direction(vec3 normal, float seed){
	// Radians [0, 2*PI]
	float r1 = 2. * PI * random(vec2(seed,seed+32.));
    // Radians [0, PI/2]
	float r2 = PI * random(vec2(seed+12., seed+684.2)) / 2.;

	float x = cos(r1) * sin(r2);
    float y = sin(r1) * sin(r2);
    float z = cos(r2);

    // Gram Schmidt orthogonalization
    vec3 unit_x = vec3(1.0, 1.0, 1.0);
    vec3 w = normal;
    vec3 u = normalize(cross(normalize(unit_x), w));
    vec3 v = normalize(cross(w, u));
	
    return normalize(u*x+v*y+w*z);
}

float ambient_occlusion_contribution(vec3 sample_point, vec3 normal){
	int intersections = 0;
	int temp_id;

	for(int i = 0; i < NUM_AMBIENT_OCCLUSION_SAMPLES; ++i){
		vec3 random_direction = get_random_hemisphere_ray_direction(normal, float(i));
		vec3 displaced_origin = sample_point + random_direction * 0.1;
		float dist = shortest_distance_to_surface(displaced_origin, random_direction, MIN_DISTANCE, MAX_DISTANCE, temp_id);
		if(dist < MAX_DISTANCE){
			intersections += 1;
		}
	}

	return float(intersections) / float(NUM_AMBIENT_OCCLUSION_SAMPLES);
}

float ambient_occlusion_contribution2(vec3 sample_point, vec3 normal){
	int temp_id;
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<8; i++ )
    {
        float h = 0.001 + 0.15*float(i)/4.0;
        float d = scene_sdf( sample_point + h*normal, temp_id );
        occ += (h-d)*sca;
        sca *= 0.95;
    }
    return 1. - clamp( 1.0 - 1.5*occ, 0.0, 1.0 ); 
}

vec3 compute_lighting(vec3 sample_point, vec3 eye, vec3 normal, Material material) {
    
	vec3 ambient_contribution =  material.color * material.ambient * light_color_ambient;
    vec3 pix_color = 0.8 * ambient_contribution;

	for(int i = 0; i < NUM_LIGHTS; i ++){
		pix_color += phong_light_contribution(sample_point, eye, normal, lights[i], material);
	}

	return pix_color;
}

vec3 compute_pixel_color(vec3 ray_origin, vec3 ray_direction){
	
	float product_coeff = 1.;
	vec3 color = vec3(0.);

	for(int i_reflection = 0; i_reflection < NUM_REFLECTIONS+1; i_reflection++) {
		int material_id;

		float start = MIN_DISTANCE;
		float end = MAX_DISTANCE;
		float dist = shortest_distance_to_surface(ray_origin, ray_direction, start, end, material_id);

		if (dist > end - EPSILON) { // No collision
			#if ENVIRONMENT_MAPPING != 0
			vec4 cube = textureCube(cubemap_texture, ray_direction);
			color += product_coeff * cube.xyz;
			#endif
			break;
		}
		
		Material material = get_mat2(material_id);

		vec3 intersection_point = ray_origin + dist * ray_direction;

		vec3 normal = estimate_normal(intersection_point);
		
		color += (1. - material.mirror) * product_coeff * compute_lighting(intersection_point, ray_origin, normal, material);
		
		if(i_reflection == 0){
			color += (1. - ambient_occlusion_contribution(intersection_point, normal)) * material.color * material.ambient * light_color_ambient;
		}

		product_coeff *= material.mirror;

		ray_origin = intersection_point;
		ray_direction = reflect(ray_direction, normal);
		ray_origin += ray_direction*0.01; // To avoid acne
	}

	return color;
}

void main() {

	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);

	vec3 pix_color = compute_pixel_color(ray_origin, ray_direction);
	
	gl_FragColor = vec4(pix_color, 1.);
}
