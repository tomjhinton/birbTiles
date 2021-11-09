
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

vec2 rotateUV(vec2 uv, vec2 pivot, float rotation) {
  mat2 rotation_matrix=mat2(  vec2(sin(rotation),-cos(rotation)),
                              vec2(cos(rotation),sin(rotation))
                              );
  uv -= pivot;
  uv= uv*rotation_matrix;
  uv += pivot;
  return uv;
}




float random (in vec2 _st) {
    return fract(sin(dot(_st.xy,
                         vec2(12.9898,78.233)))*
        43758.5453123);
}




vec2 rotate2D (vec2 _st, float _angle) {
    _st -= 0.5;
    _st =  mat2(cos(_angle),-sin(_angle),
                sin(_angle),cos(_angle)) * _st;
    _st += 0.5;
    return _st;
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

vec2 random2( vec2 p ) {
    return fract(sin(vec2(dot(p,vec2(127.1,311.7)),dot(p,vec2(269.5,183.3))))*43758.5453);
}

vec2 barrelPincushion(vec2 uv, float k) {
    vec2 st = uv - 0.5;
    float theta = atan(st.x, st.y);
    float radius = sqrt(dot(st, st));
    radius *= 1.0 + k * pow(radius, 2.0);

    return 0.5 + vec2(sin(theta), cos(theta)) * radius;
}


void main(){
  const int one = 1;
  float alpha = 1.;
  vec2 uv = vUv - .5;

  float effectRadius = 1.5;
  float effectAngle = 1. * PI ;

  vec2 center = vec2(.5, .5);

  vec2 st = uv;

  vec2 rote = rotateUV(uv, vec2(.0), PI * vTime * .05);
  vec2 roteC = rotateUV(uv, vec2(.0), -PI * vTime * .05);

  vec3 color = vec3( 0.);

    st *= 5. * (uMouse.x/uMouse.y) ;

    st = barrelPincushion(st, 10.);

    vec2 i_st = floor(st);
    vec2 f_st = fract(st);

    float m_dist = 1.;  // minimum distance
    vec2 m_point;        // minimum point

    for (int j=-1; j<=one; j++ ) {
        for (int i=-1; i<=one; i++ ) {
            vec2 neighbor = vec2(float(i),float(j));
            vec2 point = random2(i_st + neighbor);

            point = 0.5 + 0.5*cos(vTime + 6.2831*point);
            vec2 diff = neighbor + point - f_st;
            float dist = length(diff);

            if( dist < m_dist ) {
                m_dist = dist;
                m_point = point;
            }
        }
    }

    vec2 st2 = rote;
    st2 *= 6. * (uMouse.y/uMouse.x) ;;

    // Tile the space
    vec2 i_st2 = floor(st2);
    vec2 f_st2 = fract(st2);

    float m_dist2 = 1.;  // minimum dist2ance
    vec2 m_point2;        // minimum point

    for (int k=-1; k<=one; k++ ) {
        for (int l=-1; l<=one; l++ ) {
            vec2 neighbor = vec2(float(k),float(l));
            vec2 point = random2(i_st2 + neighbor);

            point = 0.5 + 0.5*sin(vTime + 6.2831*point);
            vec2 diff = neighbor + point - f_st2;
            float dist2 = length(diff);

            if( dist2 < m_dist2 ) {
                m_dist2 = dist2;
                m_point2 = point;
            }
        }
    }

    vec2 st3 = roteC;
    st3 *= 9. / (uMouse.x/uMouse.y) ;;

    vec2 i_st3 = floor(st3);
    vec2 f_st3 = fract(st3);

    float m_dist3 = 1.;  // minimum dist2ance
    vec2 m_point3;        // minimum point

    for (int m=-1; m<=one; m++ ) {
        for (int n=-1; n<=one; n++ ) {
            vec2 neighbor = vec2(float(m),float(n));
            vec2 point = random2(i_st3 + neighbor);

            point = 0.5 + 0.5*sin(vTime + 6.2831*point);
            vec2 diff = neighbor + point - f_st3;
            float dist3 = length(diff);

            if( dist3 < m_dist3 ) {
                m_dist3 = dist3;
                m_point3 = point;
            }
        }
    }

    color.r = dot(m_point,vec2(.3,.2));
    color.g = dot(m_point2,vec2(.3,.2));
    color.b = dot(m_point3,vec2(.3,.2));
    color.rg = barrelPincushion(color.rg, 3. * sin(vTime));

    coswarp(color, 3.);




 gl_FragColor =  vec4(color, alpha);

}
