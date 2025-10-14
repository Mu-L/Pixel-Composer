#pragma use(sampler_simple)

#region -- sampler_simple -- [1729740692.1417658]
    uniform int  sampleMode;
    
    vec4 sampleTexture( sampler2D texture, vec2 pos) {
        if(pos.x >= 0. && pos.y >= 0. && pos.x <= 1. && pos.y <= 1.)
            return texture2D(texture, pos);
        
             if(sampleMode <= 1) return vec4(0.);
        else if(sampleMode == 2) return texture2D(texture, clamp(pos, 0., 1.));
        else if(sampleMode == 3) return texture2D(texture, fract(pos));
        else if(sampleMode == 4) return vec4(vec3(0.), 1.);
        
        return vec4(0.);
    }
#endregion -- sampler_simple --
#pragma use(curve)

#region -- curve -- [1742009781.2228172]

    #ifdef _YY_HLSL11_ 
        #define CURVE_MAX  512
    #else 
        #define CURVE_MAX  256
    #endif

    uniform int   curve_offset;

    float eval_curve_segment_t(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float prog) {
        float p = prog;
        float i = 1. - p;
        
        return _y0 *      i*i*i + 
            ay0 * 3. * i*i*p + 
            by1 * 3. * i*p*p + 
            _y1 *      p*p*p;
    }

    float eval_curve_segment_x(in float _y0, in float ax0, in float ay0, in float bx1, in float by1, in float _y1, in float _x) {
        float st = 0.;
        float ed = 1.;
        float _prec = 0.0001;
        
        float _xt = _x;
        int _binRep = 8;
        
        if(_x <= 0.) return _y0;
        if(_x >= 1.) return _y1;
        if(_y0 == ay0 && _y0 == by1 && _y0 == _y1) return _y0;
        
        for(int i = 0; i < _binRep; i++) {
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.);
            
            if(abs(_ftx - _x) < _prec)
                return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
            
            if(_xt < _x) st = _xt;
            else		 ed = _xt;
            
            _xt = (st + ed) / 2.;
        }
        
        int _newRep = 16;
        
        for(int i = 0; i < _newRep; i++) {
            float slope = (  9. * ax0 - 9. * bx1 + 3.) * _xt * _xt
                        + (-12. * ax0 + 6. * bx1) * _xt
                        +    3. * ax0;
            float _ftx = 3. * pow(1. - _xt, 2.) * _xt * ax0 
                    + 3. * (1. - _xt) * pow(_xt, 2.) * bx1
                    + pow(_xt, 3.)
                    - _x;
            
            _xt -= _ftx / slope;
            
            if(abs(_ftx) < _prec)
                break;
        }
        
        _xt = clamp(_xt, 0., 1.);
        return eval_curve_segment_t(_y0, ax0, ay0, bx1, by1, _y1, _xt);
    }

    float curveEval(in float[CURVE_MAX] curve, in int amo, in float _x) {
        
        int   _segs  = (amo - curve_offset) / 6 - 1;
        float _shift = curve[0];
        float _scale = curve[1];
        float _type  = curve[2];
        
        _x = _x / _scale - _shift;
        _x = clamp(_x, 0., 1.);
        
        if(_type == 0.) {
            for( int i = 0; i < _segs; i++ ) {
                int ind    = curve_offset + i * 6;
                float _x0  = curve[ind + 2];
                float _y0  = curve[ind + 3];
                float _x1  = curve[ind + 6 + 2];
                float _y1  = curve[ind + 6 + 3];

                float _dx0 = curve[ind + 4];
                float _dy0 = curve[ind + 5];
                float _dx1 = curve[ind + 6 + 0];
                float _dy1 = curve[ind + 6 + 1];

                if(abs(_dx0) + abs(_dx1) > 1.) {
                    float _total = abs(_dx0) + abs(_dx1);
                    _dx0 /= _total;
                    _dx1 /= _total;
                }

                float ax0  = _x0 + _dx0;
                float ay0  = _y0 + _dy0;
                float bx1  = _x1 + _dx1;
                float by1  = _y1 + _dy1;
                
                if(_x < _x0) continue;
                if(_x > _x1) continue;

                float t = (_x - _x0) / (_x1 - _x0);
                if(curve[ind + 4] == 0. && curve[ind + 5] == 0. && curve[ind + 6 + 0] == 0. && curve[ind + 6 + 1] == 0.)
                    return mix(_y0, _y1, t);
                
                return eval_curve_segment_x(_y0, ax0, ay0, bx1, by1, _y1, t);
            }

        } else if(_type == 1.) {
            float y0 = curve[curve_offset + 3];

            for( int i = 0; i < _segs; i++ ) {
                int ind   = curve_offset + i * 6;
                float _x0 = curve[ind + 2];

                if(_x < _x0) return y0;
                y0 = curve[ind + 3];
            }

            return y0;
        }

        return curve[amo - 3];
    }

#endregion -- curve --

varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float seed;
uniform float strength;
uniform float dist;
uniform int	  useMap;
uniform sampler2D strengthMap;

uniform float alpha_curve[CURVE_MAX];
uniform int   alpha_amount;

uniform float randomAmount;

#region //////////////////////////////////// GRADIENT ////////////////////////////////////
	#define GRADIENT_LIMIT 128
	
	uniform int		  gradient_blend;
	uniform vec4	  gradient_color[GRADIENT_LIMIT];
	uniform float	  gradient_time[GRADIENT_LIMIT];
	uniform int		  gradient_keys;
	uniform int       gradient_use_map;
	uniform vec4      gradient_map_range;
	uniform sampler2D gradient_map;

	vec3 linearToGamma(vec3 c) { return pow(c, vec3(     2.2)); }
	vec3 gammaToLinear(vec3 c) { return pow(c, vec3(1. / 2.2)); }
	
	vec3 rgbMix(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = linearToGamma(c1);
		vec3 k2 = linearToGamma(c2);
		
		return gammaToLinear(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2oklab(vec3 c) { #region
		const mat3 kCONEtoLMS = mat3(                
	         0.4121656120,  0.2118591070,  0.0883097947,
	         0.5362752080,  0.6807189584,  0.2818474174,
	         0.0514575653,  0.1074065790,  0.6302613616);
	    
		c = pow(c, vec3(2.2));
		c = pow( kCONEtoLMS * c, vec3(1.0 / 3.0) );
		
		return c;
	} #endregion
	
	vec3 oklab2rgb(vec3 c) { #region
		const mat3 kLMStoCONE = mat3(
	         4.0767245293, -1.2681437731, -0.0041119885,
	        -3.3072168827,  2.6093323231, -0.7034763098,
	         0.2307590544, -0.3411344290,  1.7068625689);
        
		c = kLMStoCONE * (c * c * c);
		c = pow(c, vec3(1. / 2.2));
		
	    return c;
	} #endregion

	vec3 oklabMax(vec3 c1, vec3 c2, float t) { #region
		vec3 k1 = rgb2oklab(c1);
		vec3 k2 = rgb2oklab(c2);
		
		return oklab2rgb(mix(k1, k2, t));
	} #endregion 
	
	vec3 rgb2hsv(vec3 c) { #region
		vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

	    float d = q.x - min(q.w, q.y);
	    float e = 0.0000000001;
	    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
	} #endregion

	vec3 hsv2rgb(vec3 c) { #region
	    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
	} #endregion

	float hueDist(float a0, float a1, float t) { #region
		float da = fract(a1 - a0);
	    float ds = fract(2. * da) - da;
	    return a0 + ds * t;
	} #endregion

	vec3 hsvMix(vec3 c1, vec3 c2, float t) { #region
		vec3 h1 = rgb2hsv(c1);
		vec3 h2 = rgb2hsv(c2);
	
		vec3 h = vec3(0.);
		h.x = h.x + hueDist(h1.x, h2.x, t);
		h.y = mix(h1.y, h2.y, t);
		h.z = mix(h1.z, h2.z, t);
	
		return hsv2rgb(h);
	} #endregion

	vec4 gradientEval(in float prog) { #region
		if(gradient_use_map == 1) {
			vec2 samplePos = mix(gradient_map_range.xy, gradient_map_range.zw, prog);
			return texture2D( gradient_map, samplePos );
		}
	
		vec4 col = vec4(0.);
	
		for(int i = 0; i < GRADIENT_LIMIT; i++) {
			if(gradient_time[i] == prog) {
				col = gradient_color[i];
				break;
			} else if(gradient_time[i] > prog) {
				if(i == 0) 
					col = gradient_color[i];
				else {
					float t  = (prog - gradient_time[i - 1]) / (gradient_time[i] - gradient_time[i - 1]);
					vec3  c0 = gradient_color[i - 1].rgb;
					vec3  c1 = gradient_color[i].rgb;
					float a  = mix(gradient_color[i - 1].a, gradient_color[i].a, t);
					
					if(gradient_blend == 0)
						col = vec4(mix(c0, c1, t), a);
						
					else if(gradient_blend == 1)
						col = gradient_color[i - 1];
						
					else if(gradient_blend == 2)
						col = vec4(hsvMix(c0, c1, t), a);
						
					else if(gradient_blend == 3)
						col = vec4(oklabMax(c0, c1, t), a);
					
					else if(gradient_blend == 4)
						col = vec4(rgbMix(c0, c1, t), a);
				}
				break;
			}
			if(i >= gradient_keys - 1) {
				col = gradient_color[gradient_keys - 1];
				break;
			}
		}
	
		return col;
	} #endregion
	
#endregion //////////////////////////////////// GRADIENT ////////////////////////////////////

float frandom (in vec2 st, in float _seed) {
	float f = fract(sin(dot(st.xy, vec2(12.9898, 78.233)) * mod(15.15 + seed, 32.156 + _seed) * 12.588) * 43758.5453123);
    return mix(-1., 1., f);
}

vec2 vrandom (in vec2 st) {
    return vec2(frandom(st, 165.874), frandom(st, 98.601));
}

void main() {
	vec2 _pos = v_vTexcoord;
	float str = strength;
	
	vec2 _vec = vrandom(_pos) * str * dist;
	
	if(useMap == 1) {
		vec4 _map = texture2D( strengthMap, _pos);
		_vec.x *= _map.r;
		_vec.y *= _map.g;
		str *= dot(_map.rg, _map.rg);
	}
	
	str += frandom(_pos, 12.01) * abs(.1) * str;
	
	vec2 _new_pos = _pos - _vec;
	vec4 _col = vec4(0.);
	
	// if(_new_pos.x >= 0. && _new_pos.x <= 1. && _new_pos.y >= 0. && _new_pos.y <= 1.) {
		_col = sampleTexture( gm_BaseTexture, _new_pos );
		vec4 cc = gradientEval(str + frandom(_pos, 1.235) * randomAmount);
		_col.rgb *= cc.rgb;
		_col.a   *= cc.a   * curveEval(alpha_curve, alpha_amount, str + frandom(_pos, 2.984) * randomAmount);
	// }
	
    gl_FragColor = _col;
}