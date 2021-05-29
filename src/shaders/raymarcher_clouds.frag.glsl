precision highp float;

varying vec3 v2f_ray_origin;
varying vec3 v2f_ray_direction;

//uniform samplerCube cubemap_texture;

#define EPSILON 0.01
#define MAX_ITERATIONS 256.0
#define FAR_PLANE 100.0

const float tau = 6.28318530717958647692;

// Gamma correction
#define GAMMA 2.2

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

vec4 map( vec3 p )
{
	float den = -1.0 - (abs(p.y-0.5)+0.5)/2.0;

    // clouds
	float f;
	vec3 q = p*.5 - vec3(0.0,0.0,1.5)*current_time + vec3(sin(0.7*current_time),0,0);
    f  = 0.50000*noise( q ); q = q*2.02 - vec3(0.0,0.0,0.0)*current_time;
    f += 0.25000*noise( q ); q = q*2.03 - vec3(0.0,0.0,0.0)*current_time;
    f += 0.12500*noise( q ); q = q*2.01 - vec3(0.0,0.0,0.0)*current_time;
    f += 0.06250*noise( q ); q = q*2.02 - vec3(0.0,0.0,0.0)*current_time;
    f += 0.03125*noise( q );

	den = clamp( den + 4.0*f, 0.0, 1.0 );
	
	vec3 col = mix( vec3(1.0, 1.0, 1.0), vec3(0.6,0.5,0.4), den*.5 );// + 0.05*sin(p);
	
	return vec4( col, den*.7 );
}

const vec3 sunDir = vec3(-1,.2,-1);

float testshadow( vec3 p, float dither )
{
	float shadow = 1.0;
	float s = 0.0; // this causes a problem in chrome: .05*dither;
	for ( int j=0; j < 5; j++ )
	{
		vec3 shadpos = p + s*sunDir;
		shadow = shadow - map(shadpos).a*shadow;
		
		s += .05;
	}
	return shadow;
}

vec3 raymarch( vec3 ro, vec3 rd )
{
	vec4 sum = vec4( 0 );
	
	float t = 0.0;

    // dithering	
	float dither = noise(rd);
	t += 0.1*dither;
	
	for( int i=0; i<65; i++ )
	{
		if( sum.a > 0.99 ) continue;
		
		vec3 pos = ro + (t+.2*t*t)*rd;
		vec4 col = map( pos );

		float shadow = testshadow(pos, dither);
		col.xyz *= mix( vec3(0.4,0.47,0.6), vec3(1.0,1.0,1.0), shadow );
		
		col.rgb *= col.a;

		sum = sum + col*(1.0 - sum.a);	

		t += 0.1;
	}

	vec4 bg = mix( vec4(.3,.4,.5,0), vec4(.5,.7,1,0), smoothstep(-.4,.0,rd.y) ); // sky/ocean

	sum += bg*(1.0 - sum.a);
	
	return clamp( sum.xyz, 0.0, 1.0 );
}

vec3 to_gamma_color( vec3 col )
{
	// convert back into colour values, so the correct light will come out of the monitor
	return pow( col, vec3(1.0/GAMMA) );
}

void main() {
	vec3 ray_origin = v2f_ray_origin;
	vec3 ray_direction = normalize(v2f_ray_direction);
	
    // raymarch	
	vec3 col = raymarch( ray_origin, ray_direction );

	col = to_gamma_color(col);
	gl_FragColor = vec4(col, 1.);
}
