
const float PI = 3.1415926535897932384626433832795;
const float TAU = PI * 2.;

uniform vec2 uResolution;
uniform vec2 uMouse;


varying vec2 vUv;
varying float vTime;


float stroke(float x, float s, float w){
  float d = step(s, x+ w * .5) - step(s, x - w * .5);
  return clamp(d, 0., 1.);
}


void coswarp(inout vec3 trip, float warpsScale ){

  trip.xyz += warpsScale * .1 * cos(3. * trip.yzx + (vTime * .25));
  trip.xyz += warpsScale * .05 * cos(11. * trip.yzx + (vTime * .25));
  trip.xyz += warpsScale * .025 * cos(17. * trip.yzx + (vTime * .25));
}



float triangleDF(vec2 uv){
  uv =(uv * 2. -1.) * 2.;
  return max(
    abs(uv.x) * 0.866025 + uv.y * 0.5 ,
     -1. * uv.y * 0.5);
}



vec2 getRadialUv(vec2 uv) {
	float angle = atan(uv.x, -uv.y);
	angle = abs(angle);
	vec2 radialUv = vec2(0.0);
	radialUv.x = angle / (PI * 2.0) + 0.5;
	radialUv.y = 1.0 - pow(1.0 - length(uv), 4.0);
	return radialUv;
}
vec2 rotate2D (vec2 _st, float _angle) {
    _st -= 0.5;
    _st =  mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) * _st;
    _st += 0.5;
    return _st;
}

vec2 tile (vec2 _st, float _zoom) {
    _st *= _zoom;
    return fract(_st);
}

vec2 rotateTilePattern(vec2 _st){

    //  Scale the coordinate system by 2x2
    _st *= 2.0;

    //  Give each cell an index number
    //  according to its position
    float index = 0.0;
    index += step(1., mod(_st.x,2.0));
    index += step(1., mod(_st.y,2.0))*2.0;

    //      |
    //  2   |   3
    //      |
    //--------------
    //      |
    //  0   |   1
    //      |

    // Make each cell between 0.0 - 1.0
    _st = fract(_st);

    // Rotate each cell according to the index
    if(index == 1.0){
        //  Rotate cell 1 by 90 degrees
        _st = rotate2D(_st,PI*0.5);
    } else if(index == 2.0){
        //  Rotate cell 2 by -90 degrees
        _st = rotate2D(_st,PI*-0.5);
    } else if(index == 3.0){
        //  Rotate cell 3 by 180 degrees
        _st = rotate2D(_st,PI);
    }

    return _st;
}


void main(){
  float alpha = 1.;
  vec2 uv = vUv;

  uv = tile(uv,1.0);
  uv = rotateTilePattern(uv);
  uv = tile(uv,2.0);
  uv = rotateTilePattern(uv*2.);

  vec2 uv2 = getRadialUv(uv );
  uv2 = fract(uv2 * 1.);

  float displacement = sin(5. * uv.x + vTime * .5 ) * sin(5. * uv.y + vTime  )  * 0.25 ;

  vec3 color = vec3(uv.x, uv.y, 1. + displacement) ;

  coswarp(color,3.);

  float trian = stroke(triangleDF(vec2(uv2.x, uv2.y)), .9 , 1.9);

  color *= trian;


 gl_FragColor =  vec4(color, alpha);

}
