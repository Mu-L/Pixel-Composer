//
// Description : Array and textureless GLSL 2D/3D/4D simplex 
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : stegu
//     Lastmod : 20201014 (stegu)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//               https://github.com/stegu/webgl-noise
// 

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform vec2  dimension;
uniform vec2  position;
uniform float rotation;
uniform float seed;

uniform vec2      scale;
uniform int       scaleUseSurf;
uniform sampler2D scaleSurf;

uniform vec2      iteration;
uniform int       iterationUseSurf;
uniform sampler2D iterationSurf;

uniform float itrScaling;
uniform float itrAmplitude;

uniform int  colored;
uniform vec2 colorRanR;
uniform vec2 colorRanG;
uniform vec2 colorRanB;

uniform float phase;

#define TAU 6.283185307179586

vec2 sca;
float itrMax, itr;

vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 10.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float ian_noise(vec3 vec) {
	vec3 v  = vec * 4.;
	
	const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
	const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

	// First corner
	vec3 i  = floor(v + dot(v, C.yyy));
	vec3 x0 =   v - i + dot(i, C.xxx);
	
	// Other corners
	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min( g.xyz, l.zxy );
	vec3 i2 = max( g.xyz, l.zxy );
	
	//   x0 = x0 - 0.0 + 0.0 * C.xxx;
	//   x1 = x0 - i1  + 1.0 * C.xxx;
	//   x2 = x0 - i2  + 2.0 * C.xxx;
	//   x3 = x0 - 1.0 + 3.0 * C.xxx;
	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy; //  2.0 * C.x       =  1/3 =  C.y
	vec3 x3 = x0 - D.yyy;      // -1.0 + 3.0 * C.x = -0.5 = -D.y

	// Permutations
	i = mod289(i);
	
	vec4 p = permute( permute( permute( 
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
	
	// Gradients: 7x7 points over a square, mapped onto an octahedron.
	// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
	float n_ = 0.142857142857; // 1.0/7.0
	vec3  ns = n_ * D.wyz - D.xzx;
	
	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)
	
	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
	
	vec4 x = x_ * ns.x + ns.yyyy;
	vec4 y = y_ * ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);
	
	vec4 b0 = vec4( x.xy, y.xy );
	vec4 b1 = vec4( x.zw, y.zw );
	
	//vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
	//vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
	vec4 s0 = floor(b0) * 2.0 + 1.0;
	vec4 s1 = floor(b1) * 2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));
	
	vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;
	
	vec3 p0 = normalize(vec3(a0.xy, h.x));
	vec3 p1 = normalize(vec3(a0.zw, h.y));
	vec3 p2 = normalize(vec3(a1.xy, h.z));
	vec3 p3 = normalize(vec3(a1.zw, h.w));
	
	// Mix final noise value
	vec4 m = max(0.5 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
	m = m * m;
	
	float n = 105.0 * dot( m * m, vec4( dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3) ) );
	n = mix(0.0, 0.5 + 0.5 * n, smoothstep(0.0, 0.003, vec.z));
	return n;
}

vec2 iq_hash( vec2 p ) {
	p = vec2( dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)) );
	return -1.0 + 2.0 * fract(sin(p) * (seed / 100.));
}

float iq_noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	
	vec2  i = floor( p + (p.x + p.y) * K1 );
	vec2  a = p - i + (i.x + i.y) * K2;
    float m = step(a.y, a.x); 
    vec2  o = vec2(m, 1.0 - m);
    vec2  b = a - o + K2;
	vec2  c = a - 1.0 + 2.0 * K2;
	
    vec3  h = max( 0.5 - vec3(dot(a, a), dot(b, b), dot(c, c) ), 0.0 );
	vec3  n = h * h * h * h * vec3( dot(a, iq_hash(i + 0.0)), dot(b, iq_hash(i + o)), dot(c, iq_hash(i + 1.0)));
    return dot( n, vec3(70.0) ) * .75 + .65;
}

float simplex(in vec2 st) {
    vec2 p = st / 2.;
	
    float inAmp = 1. / itrAmplitude;
	float amp   = pow(inAmp, float(itr) - 1.)  / (pow(inAmp, float(itr)) - 1.);
    float n     = 0.;
    
	for(float i = 0.; i < itrMax; i++) {
		if(i >= itr) break;
		
		n += iq_noise(p) * amp;
		p *= itrScaling;
		
		amp *= itrAmplitude;
	}
	
	return n;
}

void main() {
	vec2 ntx = v_vTexcoord * vec2(1., dimension.y / dimension.x);
	
	sca = scale;
	if(scaleUseSurf == 1) {
		vec4 _vMap = texture2D( scaleSurf, ntx );
		sca = vec2(mix(scale.x, scale.y, (_vMap.r + _vMap.g + _vMap.b) / 3.));
	}
	sca = dimension / sca;
	
	itr    = iteration.x;
	itrMax = max(iteration.x, iteration.y);
	if(iterationUseSurf == 1) {
		vec4 _vMap = texture2D( iterationSurf, ntx );
		itr = mix(iteration.x, iteration.y, (_vMap.r + _vMap.g + _vMap.b) / 3.);
	}
	
	vec2  pos = position / dimension;
	float ang = rotation;
	vec2  st  = (ntx - pos) * mat2(cos(ang), -sin(ang), sin(ang), cos(ang)) * sca;
	
	if(colored == 0) {
		gl_FragColor = vec4(vec3(simplex(st)), 1.0);
		
	} else if(colored == 1) {
		float randR = colorRanR[0] + simplex(st) * (colorRanR[1] - colorRanR[0]);
		float randG = colorRanG[0] + simplex(st + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randB = colorRanB[0] + simplex(st + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(randR, randG, randB, 1.0);
		
	} else if(colored == 2) {
		float randH = colorRanR[0] + simplex(st) * (colorRanR[1] - colorRanR[0]);
		float randS = colorRanG[0] + simplex(st + vec2(1.7227, 4.55529)) * (colorRanG[1] - colorRanG[0]);
		float randV = colorRanB[0] + simplex(st + vec2(6.9950, 6.82063)) * (colorRanB[1] - colorRanB[0]);
		
		gl_FragColor = vec4(hsv2rgb(vec3(randH, randS, randV)), 1.0);
	}
}