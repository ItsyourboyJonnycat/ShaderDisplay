package; 
import openfl.filters.ShaderFilter;
import flixel.FlxG;
import tools.FlxShader; 
 
class CrtEffect {
    public var shader:CrtShader;
    public var curved(default, set):Bool = true;

    public function new() {
        shader = new CrtShader();
        shader.curved.value = [true];
        shader.uTime.value = [0.0];
    }

    public function update(elapsed:Float) {
        shader.uTime.value[0] += elapsed;
    }

    public function getFilter():ShaderFilter {
        return new ShaderFilter(shader);
    }

	public function set_curved(value:Bool):Bool {
		curved = value;
        shader.curved.value = [value];
        return value;
	}
}

class CrtShader extends FlxShader {
    @:glFragmentSource('
    #pragma header

    uniform float uTime;
    uniform bool curved;

    vec2 curve(vec2 uv)
    {
	    return uv;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;

        // Curve
        if (curved)
	        uv = curve( uv );

        float daAlp = flixel_texture2D(bitmap,uv).a;
    
        vec3 col;

        // Chromatic
        col.r = flixel_texture2D(bitmap,vec2(uv.x+0.003,uv.y)).x;
        col.g = flixel_texture2D(bitmap,vec2(uv.x+0.000,uv.y)).y;
        col.b = flixel_texture2D(bitmap,vec2(uv.x-0.003,uv.y)).z;

        col *= step(0.0, uv.x) * step(0.0, uv.y);
        col *= 1.0 - step(1.0, uv.x) * 1.0 - step(1.0, uv.y);

        col *= 0.5 + 0.5*16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y);
        col *= vec3(0.95,1.05,0.95);

        col *= 0.9+0.1*sin(10.0*uTime+uv.y*700.0);

        col *= 0.99+0.01*sin(110.0*uTime);

        gl_FragColor = vec4(col,daAlp);
    }
    ')

    public function new() {
        super();
    }
} 

class GameboyHandler {
    //public var size(default, set):Float = 128.0;
    //public var threshold(default, set):Float = 0.006;
    public var BRIGHTNESS(default, set):Float = 1.0;
    public var shader:GameboyShader = null;
    public function new() {
        shader = new GameboyShader();
        shader.BRIGHTNESS.value = [1.0];
        //shader.threshold.value = [0.006];
    }

	/*function set_size(value:Float):Float {
		size = value;
        shader.size.value = [value];
        return value;
	}
    function set_threshold(value:Float):Float {
		threshold = value;
        shader.threshold.value = [value];
        return value;
	}*/
    function set_BRIGHTNESS(value:Float):Float {
		BRIGHTNESS = value;
        shader.BRIGHTNESS.value = [value];
        return value;
	}
}

class GameboyShader extends FlxShader {
    @:glFragmentSource('
    #pragma header
    //#define GAMEBOY
    //#define GAMEBOY
    uniform float BRIGHTNESS;

    vec3 iscloser (in vec3 color, in vec3 current, inout float dmin) 
    {
        vec3 closest = current;
        float dcur = distance (color, current);
        if (dcur < dmin) 
        {
            dmin = dcur;
            closest = color;	
        }
        return closest;
    }
    
    vec3 find_closest (vec3 ref) {	
        vec3 old = vec3 (100.0*255.0);		
        #define TRY_COLOR(new) old = mix (new, old, step (length (old-ref), length (new-ref)));	
        
        //#ifdef GAMEBOY
        TRY_COLOR (vec3 (156.0, 189.0, 15.0));
        TRY_COLOR (vec3 (140.0, 173.0, 15.0));
        TRY_COLOR (vec3 (48.0, 98.0, 48.0));
        TRY_COLOR (vec3 (15.0, 56.0, 15.0));
        //#endif
        
        return old;
    }
    
    
    float dither_matrix (float x, float y) {
        return mix(mix(mix(mix(mix(mix(0.0,32.0,step(1.0,y)),mix(8.0,40.0,step(3.0,y)),step(2.0,y)),mix(mix(2.0,34.0,step(5.0,y)),mix(10.0,42.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(48.0,16.0,step(1.0,y)),mix(56.0,24.0,step(3.0,y)),step(2.0,y)),mix(mix(50.0,18.0,step(5.0,y)),mix(58.0,26.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(1.0,x)),mix(mix(mix(mix(12.0,44.0,step(1.0,y)),mix(4.0,36.0,step(3.0,y)),step(2.0,y)),mix(mix(14.0,46.0,step(5.0,y)),mix(6.0,38.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(60.0,28.0,step(1.0,y)),mix(52.0,20.0,step(3.0,y)),step(2.0,y)),mix(mix(62.0,30.0,step(5.0,y)),mix(54.0,22.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(3.0,x)),step(2.0,x)),mix(mix(mix(mix(mix(3.0,35.0,step(1.0,y)),mix(11.0,43.0,step(3.0,y)),step(2.0,y)),mix(mix(1.0,33.0,step(5.0,y)),mix(9.0,41.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(51.0,19.0,step(1.0,y)),mix(59.0,27.0,step(3.0,y)),step(2.0,y)),mix(mix(49.0,17.0,step(5.0,y)),mix(57.0,25.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(5.0,x)),mix(mix(mix(mix(15.0,47.0,step(1.0,y)),mix(7.0,39.0,step(3.0,y)),step(2.0,y)),mix(mix(13.0,45.0,step(5.0,y)),mix(5.0,37.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),mix(mix(mix(63.0,31.0,step(1.0,y)),mix(55.0,23.0,step(3.0,y)),step(2.0,y)),mix(mix(61.0,29.0,step(5.0,y)),mix(53.0,21.0,step(7.0,y)),step(6.0,y)),step(4.0,y)),step(7.0,x)),step(6.0,x)),step(4.0,x));
    }
    
    vec3 dither (vec3 color, vec2 uv) {	
        color *= 255.0 * BRIGHTNESS;	
        color += dither_matrix (mod (uv.x, 8.0), mod (uv.y, 8.0));
        color = find_closest (clamp (color, 0.0, 255.0));
        return color / 255.0;
    }
    
    
    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        vec4 tc = flixel_texture2D(bitmap, uv);
        float daAlp = tc.a;
        gl_FragColor =  vec4 (dither (tc.xyz, uv),daAlp);		
    }')

    public function new() {
        super();
    }
} 

class GlitchEffect
{
    public var shader(default, null):GlitchShader = new GlitchShader();
    //public var intensity(default, set):Int = 10;

    // increass if u want more gitches squares, or decrease (min is 3)
    public var NUM_SAMPLES(default, set):Int = 10;
    // strength of effect
    public var glitchMultiply(default, set):Float = 1;
    // offset of the effect, updated along with iTime.
    public var iMouse(default, set):Float = 779;

    public function new():Void
	{
        shader.iMouseX.value = [779];
		shader.uTime.value = [0];
        shader.NUM_SAMPLES.value = [10];
        shader.glitchMultiply.value = [1];
	}

    // update this manually
	public function update(elapsed:Float):Void
	{
        //shader.iMouseX.value[0] = FlxG.mouse.x;
        shader.iMouseX.value[0] = iMouse; //much better if self adjusted.
		shader.uTime.value[0] += elapsed;
	}

	function set_NUM_SAMPLES(value:Int):Int {
		NUM_SAMPLES = value;
        shader.NUM_SAMPLES.value[0] = value;
        return value;
	}

	function set_glitchMultiply(value:Float):Float {
		glitchMultiply = value;
        shader.glitchMultiply.value[0] = value;
        return value;
	}

    function set_iMouse(value:Float):Float {
		iMouse = value;
        return value;
	}
}

class GlitchShader extends FlxShader {
    @:glFragmentSource('
    #pragma header

    uniform float uTime;
    uniform float iMouseX;
    uniform int NUM_SAMPLES;
    uniform float glitchMultiply;
    
    float sat( float t ) {
        return clamp( t, 0.0, 1.0 );
    }
    
    vec2 sat( vec2 t ) {
        return clamp( t, 0.0, 1.0 );
    }
    
    //remaps inteval [a;b] to [0;1]
    float remap  ( float t, float a, float b ) {
        return sat( (t - a) / (b - a) );
    }
    
    //note: /\\ t=[0;0.5;1], y=[0;1;0]
    float linterp( float t ) {
        return sat( 1.0 - abs( 2.0*t - 1.0 ) );
    }
    
    vec3 spectrum_offset( float t ) {
        float t0 = 3.0 * t - 1.5;
        return clamp( vec3( -t0, 1.0-abs(t0), t0), 0.0, 1.0);
        /*
        vec3 ret;
        float lo = step(t,0.5);
        float hi = 1.0-lo;
        float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
        float neg_w = 1.0-w;
        ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
        return pow( ret, vec3(1.0/2.2) );
    */
    }
    
    //note: [0;1]
    float rand( vec2 n ) {
      return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
    }
    
    //note: [-1;1]
    float srand( vec2 n ) {
        return rand(n) * 2.0 - 1.0;
    }
    
    float mytrunc( float x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }
    vec2 mytrunc( vec2 x, float num_levels )
    {
        return floor(x*num_levels) / num_levels;
    }

    void main()
    {
        float aspect = openfl_TextureSize.x / openfl_TextureSize.y;
        vec2 uv = openfl_TextureCoordv;
        // uv.y = 1.0 - uv.y;
        
        float time = mod(uTime, 32.0); // + modelmat[0].x + modelmat[0].z;
    
        float GLITCH = (0.1 + iMouseX / openfl_TextureSize.x) * glitchMultiply;
        
        //float rdist = length( (uv - vec2(0.5,0.5))*vec2(aspect, 1.0) )/1.4;
        //GLITCH *= rdist;
        
        float gnm = sat( GLITCH );
        float rnd0 = rand( mytrunc( vec2(time, time), 6.0 ) );
        float r0 = sat((1.0-gnm)*0.7 + rnd0);
        float rnd1 = rand( vec2(mytrunc( uv.x, 10.0*r0 ), time) ); //horz
        //float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
        float r1 = 0.5 - 0.5 * gnm + rnd1;
        r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
        float rnd2 = rand( vec2(mytrunc( uv.y, 40.0*r1 ), time) ); //vert
        float r2 = sat( rnd2 );
    
        float rnd3 = rand( vec2(mytrunc( uv.y, 10.0*r0 ), time) );
        float r3 = (1.0-sat(rnd3+0.8)) - 0.1;
    
        float pxrnd = rand( uv + time );
    
        float ofs = 0.05 * r2 * GLITCH * ( rnd0 > 0.5 ? 1.0 : -1.0 );
        ofs += 0.5 * pxrnd * ofs;
    
        uv.y += 0.1 * r3 * GLITCH;
    
        // const int NUM_SAMPLES = 10;
        // const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
        float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
        
        vec4 sum = vec4(0.0);
        vec3 wsum = vec3(0.0);
        for( int i=0; i<NUM_SAMPLES; ++i )
        {
            float t = float(i) * RCP_NUM_SAMPLES_F;
            uv.x = sat( uv.x + ofs * t );
            vec4 samplecol = texture2D( bitmap, uv );
            vec3 s = spectrum_offset( t );
            samplecol.rgb = samplecol.rgb * s;
            sum += samplecol;
            wsum += s;
        }
        sum.rgb /= wsum;
        sum.a *= RCP_NUM_SAMPLES_F;
    
        //gl_FragColor = vec4( sum.bbb, 1.0 ); return;
        
        gl_FragColor.a = sum.a;
        gl_FragColor.rgb = sum.rgb; // * outcol0.a;
    }')

    public function new() {
        super();
    }
} 

class VhsHandler
{
    public var shader:VhsShader;
    public var noise(default, set):Float = 0.0;
    public var intensity(default,set):Float = 0.2;

	public function new()
	{
		//super();
        shader = new VhsShader();
    	shader.iTime.value = [0.0];
	    shader.noisePercent.value = [0.0];
        shader.intensity.value = [0.2];
	}

	public function update(elapsed:Float)
	{
    	shader.iTime.value[0] += elapsed;
	}

	function set_noise(value:Float):Float {
	    shader.noisePercent.value = [value];
        noise = value;
        return value;
	}
	function set_intensity(value:Float):Float {
    	shader.intensity.value = [value];
        intensity = value;
        return value;
	}
}

class VhsShader extends FlxShader {
    @:glFragmentSource('
    #pragma header
    
    uniform float iTime;
    uniform sampler2D noiseTexture;
    uniform float noisePercent;
    uniform float intensity;
    
    float rand(vec2 co)
    {
        //no highp, crashes bullshit.
        float a = 12.9898;
        float b = 78.233;
        float c = 43758.5453;
        float dt= dot(co.xy ,vec2(a,b));
        float sn= mod(dt,3.14);
        return fract(sin(sn) * c);
    }
        
    float noise(vec2 p)
    {
        return rand(p) * noisePercent;
    }
    
    float onOff(float a, float b, float c)
    {
        return step(c, sin(iTime + a*cos(iTime*b)));
    }

    float ramp(float y, float start, float end)
    {
        float inside = step(start,y) - step(end,y);
        float fact = (y-start)/(end-start)*inside;
        return (1.-fact) * inside;
    }

    float stripes(vec2 uv)
    {
        float noi = noise(uv*vec2(0.5,1.) + vec2(1.,3.));
        return ramp(mod(uv.y*4. + iTime/2.+sin(iTime + sin(iTime*0.63)),1.),0.5,0.6)*noi;
    }

    vec4 getVideo(vec2 uv)
    {
        vec2 look = uv;
        float window = 1./(1.+20.*(look.y-mod(iTime/4.,1.))*(look.y-mod(iTime/4.,1.)));
        look.x = look.x + sin(look.y*10. + iTime)/50.*onOff(4.,4.,.3)*(1.+cos(iTime*80.))*window;
        float vShift = 0.4*onOff(2.,3.,.9) * (sin(iTime)*sin(iTime*20.) + (0.5 + 0.1*sin(iTime*200.)*cos(iTime)));
        look.y = mod(look.y + vShift, 1.);
        vec4 video = vec4(flixel_texture2D(bitmap,mix(uv,look,intensity)));
        return video;
    }

    vec2 screenDistort(vec2 uv)
    {
        uv -= vec2(.5,.5);
        uv = uv*1.2*(1./1.2+2.*uv.x*uv.x*uv.y*uv.y);
        uv += vec2(.5,.5);
        return uv;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        uv = screenDistort(uv);
        vec4 video = getVideo(uv);
        float daAlp = video.a; // we dont want a black camera with the efx on it.
        float vigAmt = 3.+.3*sin(iTime + 5.*cos(iTime*5.));
        float vignette = (1.-vigAmt*(uv.y-.5)*(uv.y-.5))*(1.-vigAmt*(uv.x-.5)*(uv.x-.5));
        
        video += stripes(uv);
        video += noise(uv*2.)/2.;
        video *= vignette;
        video *= (12.+mod(uv.y*30.+iTime,1.))/13.;
        
        gl_FragColor = vec4(video.rgb,daAlp);
    }
    ')
    public function new() {
        super();
    }
} 

class VignetteEffect
{
    public var shader(default, null):VignetteShader2 = new VignetteShader2();

    public var radius(default, set):Float = 0.5;
    public var smoothness(default, set):Float = 0.5;

    function set_radius(value:Float):Float {
		radius = value;
        shader.uRadius.value = [value];
        return value;
	}

	function set_smoothness(value:Float):Float {
		smoothness = value;
        shader.uSmoothness.value = [value];
        return value;
	}

    public function new() {
        shader.uRadius.value = [0.5];
        shader.uSmoothness.value = [0.5];
        //to prevent null object
    }
}

class VignetteShader2 extends FlxShader
{ //NOTE: DONT ADD VALUES TO uRadius or uSmoothness IN GLFRAGMENTSOURCE!!!!!!!!!!!! DO IT VIA SET FUNCTIONS INSTEAD
    @:glFragmentSource('
    #pragma header

    uniform float uRadius;
    uniform float uSmoothness;

    float vignette(vec2 uv, float radius, float smoothness) {
        float diff = radius - distance(uv, vec2(0.5, 0.5));
        return smoothstep(-smoothness, smoothness, diff);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        
        float vignetteValue = vignette(uv, uRadius, uSmoothness);

        vec4 color = texture2D(bitmap, uv);
        color.rgb *= vignetteValue;
        gl_FragColor = color;
    }')
    
    public function new() {
        super();
    }
}