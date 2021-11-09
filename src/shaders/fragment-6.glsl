#ifdef GL_OES_standard_derivatives
    #extension GL_OES_standard_derivatives : enable
#endif

const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.* PI;

uniform vec2 uResolution;
uniform vec2 uMouse;


varying vec2 vUv;
varying float vTime;



//	Classic Perlin 2D Noise
//	by Stefan Gustavson
//
vec4 permute(vec4 x)
{
    return mod(((x*34.0)+1.0)*x, 289.0);
}


vec2 fade(vec2 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float cnoise(vec2 P){
  vec4 Pi = floor(P.xyxy) + vec4(0.0, 0.0, 1.0, 1.0);
  vec4 Pf = fract(P.xyxy) - vec4(0.0, 0.0, 1.0, 1.0);
  Pi = mod(Pi, 289.0); // To avoid truncation effects in permutation
  vec4 ix = Pi.xzxz;
  vec4 iy = Pi.yyww;
  vec4 fx = Pf.xzxz;
  vec4 fy = Pf.yyww;
  vec4 i = permute(permute(ix) + iy);
  vec4 gx = 2.0 * fract(i * 0.0243902439) - 1.0; // 1/41 = 0.024...
  vec4 gy = abs(gx) - 0.5;
  vec4 tx = floor(gx + 0.5);
  gx = gx - tx;
  vec2 g00 = vec2(gx.x,gy.x);
  vec2 g10 = vec2(gx.y,gy.y);
  vec2 g01 = vec2(gx.z,gy.z);
  vec2 g11 = vec2(gx.w,gy.w);
  vec4 norm = 1.79284291400159 - 0.85373472095314 *
    vec4(dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11));
  g00 *= norm.x;
  g01 *= norm.y;
  g10 *= norm.z;
  g11 *= norm.w;
  float n00 = dot(g00, vec2(fx.x, fy.x));
  float n10 = dot(g10, vec2(fx.y, fy.y));
  float n01 = dot(g01, vec2(fx.z, fy.z));
  float n11 = dot(g11, vec2(fx.w, fy.w));
  vec2 fade_xy = fade(Pf.xy);
  vec2 n_x = mix(vec2(n00, n01), vec2(n10, n11), fade_xy.x);
  float n_xy = mix(n_x.x, n_x.y, fade_xy.y);
  return 2.3 * n_xy;
}


const int RAYMARCH_MAX_STEPS = 200;
const float RAYMARCH_MAX_DIST = 50.;
const float EPSILON = 0.0001;

// // pos period of repition and limit
#define clamprepetition(p,per,l) p=p-per*clamp(floor(p/per +.5), -l, l);

mat2 rot (float a) {
	return mat2(cos(a),sin(a),-sin(a),cos(a));
}

// p: position c: corner
float sdBox(vec3 p, vec3 c) {
  vec3 q = abs(p) - c;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}


float scene(vec3 pos) {
	pos.yz *= rot(atan(1./sqrt(2.)));
	pos.xz *= rot(PI/4.);

	float period = 2.*(1.);
	clamprepetition(pos.yz, 4. , 5. );
  pos.xyz += 4. * .1 * cos(3. * pos.yzx);
	float box = sdBox(pos, vec3( 1. ));

	return box;
}

vec3 getnormalsmall (vec3 p)
{
		vec2 epsilon = vec2(0.001, 0.);
		return normalize(scene(p) - vec3(scene(p-epsilon.xyy),
										   scene(p-epsilon.yxy),
										   scene(p-epsilon.yyx))
						);
}

vec4 raymarch(vec3 rayDir, vec3 pos) {

	float currentDist = 0.0; 
	float rayDepth = 0.0;
	vec3 rayLength = vec3(0.0);
	vec3 light = normalize(vec3(1.,sin(vTime),2.));
  vec2 uv = vUv;
	vec3 gradient = mix(vec3(0.0, 0.0, sin(vTime)*.2), vec3(0.5, 0.0 ,0.5), rayDir.y);
     float warpsScale =  4. ;


	vec4 bgColor = vec4( 1.);

  vec3 color1 = vec3(uv.x, uv.y, cnoise(uv * 10.));
  color1.xyz += warpsScale * .1 * cos(3. * color1.yzx + vTime);

  vec3 color2 = vec3(uv.y, uv.x, uv.y);
  color2.xyz += warpsScale * .1 * sin(3. * color2.yzx + vTime);

	// shooting the ray
 	for (int i=0; i < RAYMARCH_MAX_STEPS; i++) {
     	// steps traveled
		vec3 new_p = pos + rayDir * rayDepth;
		currentDist = scene(new_p);
		rayDepth += currentDist;

		vec3 normals = getnormalsmall(new_p);
		float lighting = max(0.,dot(normals,light));



 		vec4 shapeColor = mix(
			vec4(color1, 1.),
			vec4(color2, 1.),
			lighting
		);


 	    if (currentDist < EPSILON) return shapeColor;
 		if (rayDepth > RAYMARCH_MAX_DIST) return bgColor;
	}

	return bgColor;
}

void main() {
	vec2 uv = vUv-.5;

	vec3 camPos = vec3(uv*25. ,30.); // x, y, z axis
	vec3 rayDir = normalize(vec3(0.,0., -1.0)); // DOF

  vec4 final = vec4(raymarch(rayDir, camPos));
  gl_FragColor = final;
}
