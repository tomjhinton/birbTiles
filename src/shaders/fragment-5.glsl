#ifdef GL_OES_standard_derivatives
    #extension GL_OES_standard_derivatives : enable
#endif


const float PI = 3.1415926535897932384626433832795;
const float TAU = PI * 2.;

uniform vec2 uResolution;
uniform vec2 uMouse;

varying vec2 vUv;
varying float vTime;

void coswarp(inout vec3 trip, float warpsScale ){

  trip.xyz += warpsScale * .1 * cos(3. * trip.yzx + (vTime * .25));
  trip.xyz += warpsScale * .05 * cos(11. * trip.yzx + (vTime * .25));
  trip.xyz += warpsScale * .025 * cos(17. * trip.yzx + (vTime * .25));
}


float aastep(float threshold, float value) {

    float afwidth = 0.7 * length(vec2(dFdx(value), dFdy(value)));
    return smoothstep(threshold-afwidth, threshold+afwidth, value);

}

float fill(float x, float size) {
    return 1.-aastep(size, x);
}


const vec2 s = vec2(1, 1.7320508);


float hex(in vec2 p){

		 p = abs(p);

		 return max(dot(p, s*.5), p.x); // Hexagon.

 }
vec4 getHex(vec2 p){

		 vec4 hC = floor(vec4(p, p - vec2(.5, 1))/s.xyxy) + .5;

		 vec4 h = vec4(p - hC.xy*s, p - (hC.zw + .5)*s);

		 return dot(h.xy, h.xy)<dot(h.zw, h.zw) ? vec4(h.xy, hC.xy) : vec4(h.zw, hC.zw + vec2(.5, 1));

 }

float stroke(float x, float s, float w){
   float d = step(s,x + w * .5) -
   step(s, x-w *.5);


   return clamp(d, 0., 1.);
 }



void main(){
  float alpha = 1.;
  vec2 uv = vUv ;

	vec4 hex_uv = getHex(uv * 10.);

	float hexf = stroke(hex(hex_uv.xy), .5, .1);

	vec4 hex_uv2 = getHex(uv * 10.);
	float hexf2 = fill(hex(hex_uv.xy), .3);

	vec4 hex_uv3 = getHex(uv * 10.);
	float hexf3 = stroke(hex(hex_uv.xy), .5, .3);

  vec3 color = vec3(uv.x, 1.,  uv.y) ;

  coswarp(color,6.);
	color = mix(color, 1.-color, hexf);
	color = mix(color, 1.-color, hexf2);
	color = mix(color, 1.-color, hexf3);

 gl_FragColor =  vec4(color, alpha);

}
