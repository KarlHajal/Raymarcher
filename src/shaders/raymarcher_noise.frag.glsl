precision highp float;

varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

//uniform samplerCube cubemap_texture;

#define EPSILON 0.01
#define MAX_ITERATIONS 256.0
#define FAR_PLANE 100.0

const float tau = 6.28318530717958647692;

// Gamma correction
#define GAMMA (2.2)

uniform float current_time;

vec3 sky_color(){
	return vec3(0.7, 0.87, 0.98);
}

vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 perm(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }

float hash(float n) { return fract(sin(n) * 1e4); }
float hash(vec2 p) { return fract(1e4 * sin(17.0 * p.x + p.y * 0.1) * (0.1 + abs(sin(p.y * 13.0 + p.x)))); }

float noise(vec2 x) {
	vec2 i = floor(x);
	vec2 f = fract(x);

	// Four corners in 2D of a tile
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	// Simple 2D lerp using smoothstep envelope between the values.
	// return vec3(mix(mix(a, b, smoothstep(0.0, 1.0, f.x)),
	//			mix(c, d, smoothstep(0.0, 1.0, f.x)),
	//			smoothstep(0.0, 1.0, f.y)));

	// Same code, with the clamps in smoothstep and common subexpressions
	// optimized away.
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

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

float Waves( vec3 pos )
{
	pos *= .2*vec3(1,1,1);
	
	const int octaves = 5;
	float f = 0.0;

	// need to do the octaves from large to small, otherwise things don't line up
	// (because I rotate by 45 degrees on each octave)
	pos += ((current_time/10.))*vec3(0,.1,.1);
	for ( int i=0; i < octaves; i++ )
	{
		pos = (pos.yzx + pos.zyx*vec3(1,-1,1))/sqrt(2.0);
		//f  = f*2.0+abs(Noise(pos).x-.5)*2.0;
        f  = f*2.0+abs(noise(pos)-.5)*2.0;
		pos *= 2.0;
	}
	f /= exp2(float(octaves));
	
	return (.5-f)*1.0;
}

float WavesDetail( vec3 pos )
{
	pos *= .2*vec3(1,1,1);
	
	const int octaves = 8;
	float f = 0.0;

	// need to do the octaves from large to small, otherwise things don't line up
	// (because I rotate by 45 degrees on each octave)
    pos += ((current_time/10.))*vec3(0,.1,.1);
	for ( int i=0; i < octaves; i++ )
	{
		pos = (pos.yzx + pos.zyx*vec3(1,-1,1))/sqrt(2.0);
		//f  = f*2.0+abs(NoisePrecise(pos).x-.5)*2.0;
        f  = f*2.0+abs(noise(pos)-.5)*2.0;
		pos *= 2.0;
	}
	f /= exp2(float(octaves));
	
	return (.5-f)*1.0;
}

float OceanDistanceField( vec3 pos )
{
	return pos.y - Waves(pos);
}

float OceanDistanceFieldDetail( vec3 pos )
{
	return pos.y - WavesDetail(pos);
}

float TraceOcean( vec3 pos, vec3 ray )
{
	float h = 1.0;
	float t = 0.0;
	for ( int i=0; i < 100; i++ )
	{
		if ( h < .01 || t > 100.0 )
			break;
		h = OceanDistanceField( pos+t*ray );
		t += h;
	}
	
	if ( h > .1 )
		return 0.0;
	
	return t;
}

vec3 OceanNormal( vec3 pos )
{
	vec3 norm;
	vec2 d = vec2(.01*length(pos),0);
	
	norm.x = OceanDistanceFieldDetail( pos+d.xyy )-OceanDistanceFieldDetail( pos-d.xyy );
	norm.y = OceanDistanceFieldDetail( pos+d.yxy )-OceanDistanceFieldDetail( pos-d.yxy );
	norm.z = OceanDistanceFieldDetail( pos+d.yyx )-OceanDistanceFieldDetail( pos-d.yyx );

	return normalize(norm);
}

float WaveCrests( vec3 ipos, vec2 fragCoord )
{
	vec3 pos = ipos;
	pos *= .2*vec3(1,1,1);
	
	const int octaves1 = 6;
	const int octaves2 = 16;
	float f = 0.0;

	// need to do the octaves from large to small, otherwise things don't line up
	// (because I rotate by 45 degrees on each octave)
	pos += ((current_time/10.))*vec3(0,.1,.1);
	vec3 pos2 = pos;
	for ( int i=0; i < octaves1; i++ )
	{
		pos = (pos.yzx + pos.zyx*vec3(1,-1,1))/sqrt(2.0);
        f  = f*1.5+abs(noise(pos)-.5)*2.0;
		pos *= 2.0;
	}
	pos = pos2 * exp2(float(octaves1));
	pos.y = -.05*((current_time/10.));
	for ( int i=octaves1; i < octaves2; i++ )
	{
		pos = (pos.yzx + pos.zyx*vec3(1,-1,1))/sqrt(2.0);
		f  = f*1.5+pow(abs(noise(pos)-.5)*2.0,1.0);
		pos *= 2.0;
	}
	f /= 1500.0;
	
	f -= noise(vec2(fragCoord.xy))*.01;
	
	return pow(smoothstep(.4,-.1,f),6.0);
}

vec3 ShadeOcean( vec3 pos, vec3 ray, vec2 fragCoord )
{
	vec3 norm = OceanNormal(pos);
	float ndotr = dot(ray,norm);

	float fresnel = pow(1.0-abs(ndotr),5.0);
	
	vec3 reflectedRay = ray-2.0*norm*ndotr;
	
    //vec3 reflection = textureCube(cubemap_texture, reflectedRay).xyz;
	vec3 reflection = sky_color();
	vec3 col = vec3(0,.04,.04); // under-sea colour
	col = mix( col, reflection, fresnel );
	// foam
	col = mix( col, vec3(1), WaveCrests(pos,fragCoord) );
	
	return col;
}

vec3 ToGamma( vec3 col )
{
	// convert back into colour values, so the correct light will come out of the monitor
	return pow( col, vec3(1.0/GAMMA) );
}

void main() {
	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);
	
    float to = TraceOcean( ray_origin, ray_direction );

    vec3 result;
	if ( to > 0.0 ){
        result = ShadeOcean( ray_origin+ray_direction*to, ray_direction, vec2(0., 1.0) );
    }
	else{
        //result = textureCube(cubemap_texture, ray_direction).xyz;
		result = sky_color();
    }

    vec3 pix_color = ToGamma(result);

	gl_FragColor = vec4(pix_color, 1.);
}
