Shader "Water/Simple/Blended" {
    Properties {
	_WaveSpeed ("Wave speed", Vector) = (1,-1,0.1,0.1)
	_Exposure ("Exposure", Float) = 0.05
	_Distortion ("Distortion", Range(-10,.5)) = 0
    _MainTex ("SurfaceWaveTexture", 2D) = "white" {}
    _BottomTex ("BottomTexture", 2D) = "white" {}
    }
    SubShader {
    
	Tags { "RenderType"="Opaque" }
	LOD 250
    CGPROGRAM
	#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview
	inline fixed4 LightingMobileBlinnPhong (SurfaceOutput s, fixed3 lightDir, fixed3 halfDir, fixed atten)
	{
		fixed diff = max (0, dot (s.Normal, lightDir));
		fixed nh = max (0, dot (s.Normal, halfDir));
		fixed spec = pow (nh, s.Specular*128) * s.Gloss;
	
		fixed4 c;
		c.rgb = (s.Albedo * _LightColor0.rgb * diff + _LightColor0.rgb * spec) * (atten*2);
		c.a = 0.0;
		return c;
	}
    struct Input {
    	float2 uv_MainTex;
        float2 uv_BottomTex;
    };
    sampler2D _MainTex;
    sampler2D _BottomTex;
	uniform float _Exposure;
	uniform float _Distortion;
	uniform float4 _WaveSpeed;
	float _Shininess;
	  
	void surf (Input IN, inout SurfaceOutput o) 
	{
		half3 tex = tex2D(_MainTex, float2(IN.uv_MainTex.x +(_WaveSpeed.x * _Time.x),IN.uv_MainTex.y+(_WaveSpeed.y * _Time.x))).rgb *_Distortion;
		half3 tex2 = tex2D(_BottomTex, float2(IN.uv_BottomTex.x+tex.b+(_WaveSpeed.z * _Time.x),IN.uv_BottomTex.y+tex.g)+(_WaveSpeed.w * _Time.x)).rgb*_Exposure;
		o.Albedo = tex2; 
	}
ENDCG
	}
Fallback "Diffuse"
}