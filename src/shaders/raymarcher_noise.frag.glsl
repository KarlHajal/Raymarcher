precision highp float;

varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

#define EPSILON 0.01
#define MAX_ITERATIONS 256.0
#define FAR_PLANE 100.0

uniform float current_time;

vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 perm(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float noise(vec3 p)
{
	vec3 a = floor(p);
	vec3 d = p - a;
	d = d * d * (3.0 - 2.0 * d);
	vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
	vec4 k1 = perm(b.xyxy);
	vec4 k2 = perm(k1.xyxy + b.zzww);
	vec4 c = k2 + a.zzzz;
	vec4 k3 = perm(c);
	vec4 k4 = perm(c + 1.0);
	vec4 o1 = fract(k3 * (1.0 / 41.0));
	vec4 o2 = fract(k4 * (1.0 / 41.0));
	vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
	vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);
	return o4.y * d.y + o4.x * (1.0 - d.y);
}

float fbm(vec3 x) {
	float v = 0.0;
	float a = 0.5;
	vec3 shift = vec3(100);
	for (int i = 0; i < 5; ++i) {
		v += a * noise(x);
		x = x * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}

float noise_sdf(vec3 ray)
{
	return fbm(ray) - 1.0;
}

vec3 compute_pixel_color(vec3 origin, vec3 ray, vec2 uv)
{
    vec3 color = vec3(1.0);
    float depth = 0.1;
    for (int i = 0; i < int(MAX_ITERATIONS); i++)
    {
        float d = noise_sdf(ray * depth + origin) + clamp(1.0 - depth / 6.0, 0.0, 1.0);
        if (d < EPSILON)
        {
            float t = current_time / 10.0;
            color.r = cos(uv.x + 5.+ sin(uv.y));
            color.g = sin(uv.y + 5. + cos(uv.x));
            color.b = 0.0;
            color = color * 0.5 + 0.5;
            float a = float(i) / MAX_ITERATIONS;
            return color * (1.0 - a) + a * vec3(1.0);
        }
        depth += d;
        if (depth > FAR_PLANE) { break; }
    }
    return color;
}

void main() {
	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);

    ray_origin[2] += current_time/50.0;
    vec3 pix_color = compute_pixel_color(ray_origin, ray_direction, ray_direction.xy);
	
	gl_FragColor = vec4(pix_color, 1.);
}
