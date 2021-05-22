precision highp float;

#define PI 3.14159265359

const int SPHERE_ID = 1;
const int PLANE_ID = 2;
const int CYLINDER_ID = 3;
const int BOX_ID = 4;
const int TORUS_ID = 5;

#define NUM_AMBIENT_OCCLUSION_SAMPLES 32
#define MAX_MARCHING_STEPS 255
#define MIN_DISTANCE 0.0
#define MAX_DISTANCE 100.0
#define EPSILON 0.001
#define MAX_RANGE 1e6
//#define NUM_REFLECTIONS

//#define NUM_SHAPES
struct Shape {
	int shape_id;
	int shape_index;
	int material_id;
};
#if NUM_SHAPES != 0
uniform Shape shapes[NUM_SHAPES];
#endif

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
};
#if NUM_CYLINDERS != 0
uniform Cylinder cylinders[NUM_CYLINDERS];
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
};
#if NUM_BOXES != 0
uniform Box boxes[NUM_BOXES];
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

#if NUM_SPHERES != 0
vec4 get_sphere(int sphere_index){
	for(int i = 0; i < NUM_SPHERES; ++i){
		if(i == sphere_index){
			return spheres_center_radius[i];
		}
	}
	return spheres_center_radius[0];
}
#endif

#if NUM_PLANES != 0
vec4 get_plane(int plane_index){
	for(int i = 0; i < NUM_PLANES; ++i){
		if(i == plane_index){
			return planes_normal_offset[i];
		}
	}
	return planes_normal_offset[0];
}
#endif

#if NUM_CYLINDERS != 0
Cylinder get_cylinder(int cylinder_index) {
	for(int i = 0; i < NUM_CYLINDERS; ++i){
		if(i == cylinder_index){
			return cylinders[i];
		}
	}
	return cylinders[0];
}
#endif

#if NUM_BOXES != 0
Box get_box(int box_index) {
	for(int i = 0; i < NUM_BOXES; ++i){
		if(i == box_index){
			return boxes[i];
		}
	}
	return boxes[0];
}
#endif

#if NUM_TORUSES != 0
Torus get_torus(int torus_index) {
	for(int i = 0; i < NUM_TORUSES; ++i){
		if(i == torus_index){
			return toruses[i];
		}
	}
	return toruses[0];
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

float plane_sdf(vec3 sample_point, vec4 plane_normal_offset) {
	vec3 plane_normal = plane_normal_offset.xyz;
	float plane_offset = plane_normal_offset[3];
	vec3 point_on_plane = plane_normal * plane_offset;
	return abs(dot(sample_point - point_on_plane, plane_normal));
}

float capped_cylinder_sdf(vec3 sample_point, Cylinder cylinder) {
	vec3 bottom_center = cylinder.center + cylinder.axis * cylinder.height/2.;
	vec3 top_center = cylinder.center - cylinder.axis * cylinder.height/2.;

	vec3  ba = top_center - bottom_center;
	vec3  pa = sample_point - bottom_center;
	float baba = dot(ba,ba);
	float paba = dot(pa,ba);
	float x = length(pa*baba-ba*paba) - cylinder.radius*baba;
	float y = abs(paba-baba*0.5)-baba*0.5;
	float x2 = x*x;
	float y2 = y*y*baba;
	float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
	return sign(d)*sqrt(abs(d))/baba;
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
  	return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - box.rounded_edges_radius;
}

float shape_sdf(vec3 sample_point, Shape shape){

	int shape_id = shape.shape_id;

	#if NUM_SPHERES != 0
	if(shape_id == SPHERE_ID){
		return sphere_sdf(sample_point, get_sphere(shape.shape_index));
	}
	#endif

	#if NUM_PLANES != 0
	if (shape_id == PLANE_ID){	
		return plane_sdf(sample_point, get_plane(shape.shape_index));
	} 
	#endif
	
	#if NUM_CYLINDERS != 0
	if (shape_id == CYLINDER_ID){
		return capped_cylinder_sdf(sample_point, get_cylinder(shape.shape_index));
	}
	#endif
	
	#if NUM_BOXES != 0
	if (shape_id == BOX_ID){
		return box_sdf(sample_point, get_box(shape.shape_index));
	}
	#endif
	
	#if NUM_TORUSES != 0
	if (shape_id == TORUS_ID){
		return torus_sdf(sample_point, get_torus(shape.shape_index));
	}
	#endif

	return MAX_RANGE;
}

float scene_sdf(vec3 sample_point, out int material_id) {

	float min_distance = MAX_RANGE;

	#if NUM_SHAPES != 0
	for(int i = 0; i < NUM_SHAPES; ++i) {
		Shape shape = shapes[i];

		float object_distance = shape_sdf(sample_point, shape);

		if(object_distance < min_distance) {
			min_distance = object_distance;
			material_id = shape.material_id;
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
