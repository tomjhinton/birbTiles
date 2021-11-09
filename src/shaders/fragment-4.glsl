
const float PI = 3.1415926535897932384626433832795;
const float TAU = 2.* PI;

uniform vec2 uResolution;

varying vec2 vUv;
varying float vTime;



const int RAYMARCH_MAX_STEPS = 200;
const float RAYMARCH_MAX_DIST = 50.;
const float EPSILON = 0.0001;

// pos period of repition and limit
#define clamprepetition(p,per,l) p=p-per*clamp(floor(p/per +.5), -l, l)

mat2 rot (float a) {
	return mat2(cos(a),sin(a),-sin(a),cos(a));
}

// p: position c: corner
float sdBox(vec3 p, vec3 c) {
  vec3 q = abs(p) - c;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdBoxFrame( vec3 p, vec3 b, float e )
{
  p = abs(p  )-b;
  vec3 q = abs(p+e)-e;
  return min(min(
      length(max(vec3(p.x,q.y,q.z),0.0))+min(max(p.x,max(q.y,q.z)),0.0),
      length(max(vec3(q.x,p.y,q.z),0.0))+min(max(q.x,max(p.y,q.z)),0.0)),
      length(max(vec3(q.x,q.y,p.z),0.0))+min(max(q.x,max(q.y,p.z)),0.0));
}

float scene(vec3 pos) {
	pos.yz *= rot(atan(1./sqrt(2.)));
	pos.xz *= rot(PI/4.);

	float period = 8.*(sin(vTime*.5)*0.5+1.);

	clamprepetition(pos.xz, 3., 4. );
	float box = sdBoxFrame(pos, vec3( 1.), .05);

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
  float warpsScale =  sin(vTime) ;
  vec4 bgColor = vec4(1., uv.x, uv.y, 1.);

  bgColor.xyz += warpsScale * .1 * cos(3. * bgColor.yzx + vTime);
  bgColor.xyz += warpsScale * .05 * cos(11. * bgColor.yzx + vTime);
  bgColor.xyz += warpsScale * .025 * cos(17. * bgColor.yzx + vTime);
  bgColor.xyz += warpsScale * .0125 * cos(21. * bgColor.yzx + vTime);


  vec3 color1 = vec3(uv.x, uv.y, 1.);
  color1.xyz += warpsScale * .1 * cos(3. * color1.yzx + vTime);

  vec3 color2 = vec3(uv.y, uv.x, uv.y);
  color2.xyz += warpsScale * .1 * sin(3. * color2.yzx + vTime);

 	for (int i=0; i < RAYMARCH_MAX_STEPS; i++) {
     	// steps traveled
		vec3 new_p = pos + rayDir * rayDepth;
		currentDist = scene(new_p);
		rayDepth += currentDist;

		vec3 normals = getnormalsmall(new_p);
		float lighting = max(0.,dot(normals,light));



 		vec4 shapeColor = mix(
			vec4(color1, 1.0),
			vec4(color2, 1.0),
			lighting
		);


 	    if (currentDist < EPSILON) return shapeColor;
 		if (rayDepth > RAYMARCH_MAX_DIST) return bgColor;
	}

	return bgColor;
}

void main() {
	vec2 uv =vUv;

	vec3 camPos = vec3(uv*6.,20.); // x, y, z axis
	vec3 rayDir = normalize(vec3(0.,0., -1.0)); // DOF

  vec4 final = vec4(raymarch(rayDir, camPos));

  gl_FragColor = final;
}
