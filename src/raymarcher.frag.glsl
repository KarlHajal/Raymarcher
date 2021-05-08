precision highp float;

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
};
#if NUM_CYLINDERS != 0
uniform Cylinder cylinders[NUM_CYLINDERS];
#endif


//#define NUM_TRIANGLES
struct Triangle {
	mat3 vertices;
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
#if (NUM_SPHERES != 0) || (NUM_PLANES != 0) || (NUM_CYLINDERS != 0) || (NUM_TRIANGLES != 0)
uniform int object_material_id[NUM_SPHERES+NUM_PLANES+NUM_CYLINDERS];
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

float sphere_sdf(vec3 sample_point, vec3 sphere_center, float sphere_radius) {
    return length(sphere_center - sample_point) - sphere_radius;
}

float plane_sdf(vec3 sample_point, vec3 plane_normal, vec3 point_on_plane)
{
	return abs(dot(sample_point - point_on_plane, plane_normal));
}

float capped_cylinder_sdf(vec3 p, vec3 cylinder_center, vec3 cylinder_axis, float cylinder_height, float cylinder_radius)
{
	vec3 bottom_center = cylinder_center + cylinder_axis * cylinder_height/2.;
	vec3 top_center = cylinder_center - cylinder_axis * cylinder_height/2.;

	vec3  ba = top_center - bottom_center;
	vec3  pa = p - bottom_center;
	float baba = dot(ba,ba);
	float paba = dot(pa,ba);
	float x = length(pa*baba-ba*paba) - cylinder_radius*baba;
	float y = abs(paba-baba*0.5)-baba*0.5;
	float x2 = x*x;
	float y2 = y*y*baba;
	float d = (max(x,y)<0.0)?-min(x2,y2):(((x>0.0)?x2:0.0)+((y>0.0)?y2:0.0));
	return sign(d)*sqrt(abs(d))/baba;
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
		float object_distance = capped_cylinder_sdf(sample_point, cylinder.center, cylinder.axis, cylinder.height, cylinder.radius);

		if (object_distance < min_distance) {
			min_distance = object_distance;
			material_id =  object_material_id[NUM_SPHERES+NUM_PLANES+i];
		}
	}
	#endif

    return min_distance;
}

/*
vec3 estimate_normal(vec3 p) {
	int temp_id;
    return normalize(vec3(
        sceneSDF(vec3(p.x + EPSILON, p.y, p.z), temp_id) - sceneSDF(vec3(p.x - EPSILON, p.y, p.z), temp_id),
        sceneSDF(vec3(p.x, p.y + EPSILON, p.z), temp_id) - sceneSDF(vec3(p.x, p.y - EPSILON, p.z), temp_id),
        sceneSDF(vec3(p.x, p.y, p.z  + EPSILON), temp_id) - sceneSDF(vec3(p.x, p.y, p.z - EPSILON), temp_id)
    ));
}
*/

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

float ambient_occlusion_contribution(vec3 p, vec3 normal){
	return 0.; 
}

vec3 compute_lighting(vec3 p, vec3 eye, vec3 normal, Material material) {
    
	vec3 ambient_contribution =  material.color * material.ambient * light_color_ambient;
    vec3 pix_color = ambient_contribution;

	pix_color += ambient_contribution * ambient_occlusion_contribution(p, normal);

	for(int i = 0; i < NUM_LIGHTS; i ++){
		pix_color += phong_light_contribution(p, eye, normal, lights[i], material);
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
		
		Material intersected_material = get_mat2(material_id);

		vec3 p = ray_origin + dist * ray_direction;

		vec3 normal = estimate_normal(p);
		
		color += (1. - intersected_material.mirror) * product_coeff * compute_lighting(p, ray_origin, normal, intersected_material);
		product_coeff *= intersected_material.mirror;

		ray_origin = p;
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
