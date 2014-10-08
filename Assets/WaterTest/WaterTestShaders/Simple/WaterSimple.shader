Shader "Water/Simple/Bumped" {
    Properties {
	_WaveSpeed ("Wave speed", Vector) = (0,-1,0,0)
	_Exposure ("Exposure", Float) = 1	
    _MainTex ("SurfaceWaveTexture", 2D) = "white" {}
    _BumpMap ("Waves Normalmap ", 2D) = "" { }
    }
    SubShader {
//    ZWrite Off //n ZTest Equal  
//	  Cull Off
//    Offset 1, 1
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
    //float2 uv_BumpMap;
};
sampler2D _MainTex;
sampler2D _BumpMap;
sampler2D _Caustic;

uniform float _Exposure;
uniform float4 _WaveSpeed;
  
void surf (Input IN, inout SurfaceOutput o) 
{
	fixed4 tex = tex2D(_MainTex, float2(IN.uv_MainTex.x +(_WaveSpeed.x * _Time.x),IN.uv_MainTex.y+(_WaveSpeed.y * _Time.x)));
	o.Albedo = tex.rgb *_Exposure ; 
	o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_MainTex));
}
ENDCG
}
Fallback "BumpedDiffuse"
}