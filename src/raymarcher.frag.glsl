precision highp float;

#define PI 3.14159265359

#define NUM_AMBIENT_OCCLUSION_SAMPLES 32
#define MAX_MARCHING_STEPS 255
#define MIN_DISTANCE 0.0
#define MAX_DISTANCE 100.0
#define EPSILON 0.001
#define MAX_RANGE 1e6
//#define NUM_REFLECTIONS

//#define NUM_SPHERES
#if NUM_SPHERES != 0
uniform vec4 spheres_center_radius[NUM_SPHERES]; // ...[i] = [center_x, center_y, center_z, radius]
#endif

//#define NUM_PLANES
#if NUM_PLANES != 0
uniform vec4 planes_normal_offset[NUM_PLANES]; // ...[i] = [nx, ny, nz, d] such that dot(vec3(nx, ny, nz), point_on_plane) = d
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

//#define NUM_CONES
struct Cone {
	vec3 center;
	vec2 sin_cos;
	float height;
};
#if NUM_CONES != 0
uniform Cone cones[NUM_CONES];
#endif

//#define NUM_HEXAGONALS
struct Hexagonal {
	vec3 center;
	vec2 heights;
};
#if NUM_HEXAGONALS != 0
uniform Hexagonal hexagonals[NUM_HEXAGONALS];
#endif

//#define NUM_TRIANGULARS
struct Triangular {
	vec3 center;
	vec2 heights;
};
#if NUM_TRIANGULARS != 0
uniform Triangular triangulars[NUM_TRIANGULARS];
#endif

//#define NUM_SOLIDS
struct Solid {
	vec3 center;
	vec2 sin_cos;
	float radius;
};
#if NUM_SOLIDS != 0
uniform Solid solids[NUM_SOLIDS];
#endif

//#define NUM_ELLIPSOIDS
struct Ellipsoid {
	vec3 center;
	vec3 radius;
};
#if NUM_ELLIPSOIDS != 0
uniform Ellipsoid ellipsoids[NUM_ELLIPSOIDS];
#endif

//#define NUM_OCTAHEDRONS
struct Octahedron {
	vec3 center;
	float length;
};
#if NUM_OCTAHEDRONS != 0
uniform Octahedron octahedrons[NUM_OCTAHEDRONS];
#endif

//#define NUM_PYRAMIDS
struct Pyramid {
	vec3 center;
	float height;
};
#if NUM_PYRAMIDS != 0
uniform Pyramid pyramids[NUM_PYRAMIDS];
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

//#define NUM_TRIANGLES
struct Triangle {
	vec3 vertice1;
	vec3 vertice2;
	vec3 vertice3;
// 	mat3 normals;
};
struct AABB {
	vec3 corner_min;
	vec3 corner_max;
};
#if NUM_TRIANGLES != 0
uniform Triangle triangles[NUM_TRIANGLES];
uniform AABB mesh_extent;
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
#if (NUM_SPHERES != 0) || (NUM_PLANES != 0) || (NUM_CYLINDERS != 0) || (NUM_BOXES != 0) || (NUM_TRIANGLES != 0) || (NUM_LINKS != 0) || (NUM_CONES != 0) || (NUM_HEXAGONALS != 0) || (NUM_TRIANGULARS != 0) || (NUM_SOLIDS != 0) || (NUM_ELLIPSOIDS != 0) || (NUM_OCTAHEDRONS != 0) || (NUM_PYRAMIDS != 0) 
uniform int object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_SOLIDS + NUM_ELLIPSOIDS + NUM_OCTAHEDRONS + NUM_PYRAMIDS];
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



float sphere_sdf(vec3 sample_point, vec3 sphere_center, float sphere_radius) {
    return length(sphere_center - sample_point) - sphere_radius;
}

float plane_sdf(vec3 sample_point, vec3 plane_normal, vec3 point_on_plane) {
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


float triangle_sdf( vec3 p, vec3 a, vec3 b, vec3 c ){
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

float link_sdf( vec3 p, float le, float r1, float r2 , vec3 center)
{
	vec3 p2 = p - center; 
	vec3 q = vec3( p2.x, max(abs(p2.y)-le,0.0), p2.z);
	return length(vec2(length(q.xy)-r1,q.z)) - r2 ;
}

vec3 transform_point_to_centered_shape(vec3 point, vec3 shape_center, float shape_rotation_x, float shape_rotation_y, float shape_rotation_z){
	vec4 translated_point = vec4((point - shape_center), 1.0);
	return (translated_point * rotation_x(-shape_rotation_x) * rotation_y(-shape_rotation_y) * rotation_z(-shape_rotation_z)).xyz;
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

float cone_sdf( in vec3 p, in vec2 c, float h, vec3 center )
{
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

float hex_prism_sdf( vec3 p, vec3 center, vec2 h )
{
	vec3 p2 = p - center;
	const vec3 k = vec3(-0.8660254, 0.5, 0.57735);
	p2 = abs(p2);
	p2.xy -= 2.0*min(dot(k.xy, p2.xy), 0.0)*k.xy;
	vec2 d = vec2(
		length(p2.xy-vec2(clamp(p2.x,-k.z*h.x,k.z*h.x), h.x))*sign(p2.y-h.x),
		p2.z-h.y );
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float triangular_sdf( vec3 p, vec3 center, vec2 h )
{
	p = p - center;
	vec3 q = abs(p);
	return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float solid_angle_sdf(vec3 p, vec3 center, vec2 c, float ra)
{
  // c is the sin/cos of the angle
  p = p - center;
  vec2 q = vec2( length(p.xz), p.y );
  float l = length(q) - ra;
  float m = length(q - c*clamp(dot(q,c),0.0,ra) );
  return max(l,m*sign(c.y*q.x-c.x*q.y));
}

float ellipsoid_sdf( vec3 p, vec3 center, vec3 r )
{
	p = p - center;
	float k0 = length(p/r);
	float k1 = length(p/(r*r));
	return k0*(k0-1.0)/k1;
}

float octahedron_sdf( vec3 p, vec3 center, float s)
{
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

float pyramid_sdf( vec3 p, vec3 center, float h)
{
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

float sceneSDF(vec3 sample_point, out int material_id) {

	float min_distance = MAX_RANGE;

	#if NUM_SPHERES != 0
	for(int i = 0; i < NUM_SPHERES; i++) {

		vec3 sphere_center = spheres_center_radius[i].xyz;
		float sphere_radius = spheres_center_radius[i][3];

		float object_distance = sphere_sdf(sample_point, sphere_center, sphere_radius);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[i];
		}
	}
	#endif


	#if NUM_PLANES != 0 
	for(int i = 0; i < NUM_PLANES; i++) {

		vec3 plane_normal = planes_normal_offset[i].xyz;
		float plane_offset = planes_normal_offset[i][3];
		vec3 point_on_plane = plane_normal * plane_offset;
	
		float object_distance = plane_sdf(sample_point, plane_normal, point_on_plane);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES+i];
		}
	}
	#endif


	#if NUM_CYLINDERS != 0 
	for(int i = 0; i < NUM_CYLINDERS; i++) {
		Cylinder cylinder = cylinders[i];
		float object_distance = capped_cylinder_sdf(sample_point, cylinder);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + i];
		}
	}
	#endif


	#if NUM_BOXES != 0
	for(int i = 0; i < NUM_BOXES; ++i) {
		Box box = boxes[i];
		float object_distance = box_sdf(sample_point, box);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + i];
		}
	}
	#endif

	#if NUM_TRIANGLES != 0
	for(int i = 0; i < NUM_TRIANGLES; i++) {


		float object_distance = triangle_sdf(sample_point, triangles[i].vertice1, triangles[i].vertice2, triangles[i].vertice3);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + i];
		}
	}
	#endif

	#if NUM_LINKS != 0
	for(int i = 0; i < NUM_LINKS; i++) {


		float object_distance = link_sdf(sample_point, links[i].length, links[i].radius1, links[i].radius2, links[i].center);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + i];
		}
	}
	#endif

	#if NUM_CONES != 0
	for(int i = 0; i < NUM_CONES; i++) {


		float object_distance = cone_sdf(sample_point, cones[i].sin_cos, cones[i].height, cones[i].center);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + i];
		}
	}
	#endif

	#if NUM_HEXAGONALS != 0
	for(int i = 0; i < NUM_HEXAGONALS; i++) {


		float object_distance = hex_prism_sdf(sample_point, hexagonals[i].center, hexagonals[i].heights);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + i];
		}
	}
	#endif

	#if NUM_TRIANGULARS != 0
	for(int i = 0; i < NUM_TRIANGULARS; i++) {


		float object_distance = triangular_sdf(sample_point, triangulars[i].center, triangulars[i].heights);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + i];
		}
	}
	#endif

	#if NUM_SOLIDS != 0
	for(int i = 0; i < NUM_SOLIDS; i++) {


		float object_distance = solid_angle_sdf(sample_point, solids[i].center, solids[i].sin_cos, solids[i].radius);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + i];
		}
	}
	#endif

	#if NUM_ELLIPSOIDS != 0
	for(int i = 0; i < NUM_ELLIPSOIDS; i++) {


		float object_distance = ellipsoid_sdf(sample_point, ellipsoids[i].center, ellipsoids[i].radius);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_SOLIDS + i];
		}
	}
	#endif

	#if NUM_OCTAHEDRONS != 0
	for(int i = 0; i < NUM_OCTAHEDRONS; i++) {


		float object_distance = octahedron_sdf(sample_point, octahedrons[i].center, octahedrons[i].length);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_SOLIDS + NUM_ELLIPSOIDS + i];
		}
	}
	#endif

	#if NUM_PYRAMIDS != 0
	for(int i = 0; i < NUM_PYRAMIDS; i++) {


		float object_distance = pyramid_sdf(sample_point, pyramids[i].center, pyramids[i].height);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES + NUM_PLANES + NUM_CYLINDERS + NUM_BOXES + NUM_TRIANGLES + NUM_LINKS + NUM_CONES + NUM_HEXAGONALS + NUM_TRIANGULARS + NUM_SOLIDS + NUM_ELLIPSOIDS + NUM_OCTAHEDRONS + i];
		}
	}
	#endif

    return min_distance;
}

vec3 estimate_normal(vec3 p ) // Tetrahedron technique
{
    const float h = 0.0001; // replace by an appropriate value
    const vec2 k = vec2(1,-1);
	int temp_id;
    return normalize( k.xyy*sceneSDF( p + k.xyy*h, temp_id ) + 
                      k.yyx*sceneSDF( p + k.yyx*h, temp_id ) + 
                      k.yxy*sceneSDF( p + k.yxy*h, temp_id ) + 
                      k.xxx*sceneSDF( p + k.xxx*h, temp_id ) );
}


float shortest_distance_to_surface(vec3 ray_origin, vec3 marching_direction, float start, float end, out int material_id) {
    float depth = start;
    for (int i = 0; i < MAX_MARCHING_STEPS; i++) {

        float dist = sceneSDF(ray_origin + depth * marching_direction, material_id);
        
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

bool is_shadow(vec3 p, Light light){
    vec3 L = normalize(light.position - p);
	vec3 displaced_origin = p + L * 0.1;
	int temp_id;
	float dist = shortest_distance_to_surface(displaced_origin, L, MIN_DISTANCE, MAX_DISTANCE, temp_id);
	return dist < length(light.position - displaced_origin);
}

vec3 phong_light_contribution(vec3 p, vec3 eye, vec3 normal, Light light, Material material) {

	if(is_shadow(p, light)){
		return vec3(0.);
	}

    vec3 L = normalize(light.position - p);
    float dotLN = dot(L, normal);
    
    if (dotLN < EPSILON) {
        return vec3(0.0, 0.0, 0.0);
    } 
    
    vec3 V = normalize(eye - p);
    vec3 R = normalize(reflect(-L, normal));
    float dotRV = dot(R, V);

	vec3 color = material.color * light.color * material.diffuse * dotLN;

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
			gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
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
