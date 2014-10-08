Shader "Water/ReflectiveFakeDepthAnimated" {
    Properties {
	_WaveSpeed ("Wave speed", Vector) = (0,-1,0,0)
	_Exposure ("Exposure", Float) = 1
	_Distortion ("Distortion", Range(-10,.5)) = 0
	_Reflection ("Reflection", Range(0,.5)) = 0			
    _MainTex ("SurfaceWaveTexture", 2D) = "white" {}
    _BottomTex ("BottomTexture", 2D) = "white" {}
	_Cube ("Cubemap", CUBE) = "" {}
	
	_PhaseOffset ("PhaseOffset", Range(0,1)) = 0
	_Speed ("Speed", Range(0.3,10)) = 1.0
	_Depth ("Depth", Range(0.0,1)) = 0.2
	_Smoothing ("Smoothing", Range(0,1)) = 0.0
	_XDrift ("X Drift", Range(0.0,2.0)) = 0.05
	_ZDrift ("Z Drift", Range(0.0,2.0)) = 0.12
	_Scale ("Scale", Range(0.1,10)) = 1.0
    }
    SubShader {
    	Tags { "RenderType"="Opaque" }
		LOD 250
      	CGPROGRAM
		#pragma surface surf MobileBlinnPhong exclude_path:prepass nolightmap noforwardadd halfasview vertex:vert
		//#pragma surface surf BlinnPhong vertex:vert
		#pragma target 3.0
		
		#define PI 3.14
		
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
			float3 worldPos;
			float3 worldRefl;
			float3 worldNormal;
//			half3 debugColor;
			//INTERNAL_DATA
      	};
	
      	sampler2D _MainTex;
      	sampler2D _BottomTex;
	  	samplerCUBE _Cube;
	 	uniform float _Exposure;
	  	uniform float _Distortion;
	  	uniform float4 _WaveSpeed;
	  	float _Reflection;
	  	
	  	float _PhaseOffset;
		float _Speed;
		float _Depth;
		float _Smoothing;
		float _XDrift;
		float _ZDrift;
		float _Scale;
		
		void vert( inout appdata_full v, out Input o )
		{
			// Note that, to start off, all work is in object (local) space.
			// We will eventually move normals to world space to handle arbitrary object orientation.
			// There is no real need for tangent space in this case.
			
			// Do all work in world space
			float3 v0 = mul( _Object2World, v.vertex ).xyz;
			
			// Create two fake neighbor vertices.
			// The important thing is that they be distorted in the same way that a real vertex in their location would.
			// This is pretty easy since we're just going to do some trig based on position, so really any samples will do.
			float3 v1 = v0 + float3( 0.05, 0, 0 ); // +X
			float3 v2 = v0 + float3( 0, 0, 0.05 ); // +Z
			
			// Some animation values
			float phase = _PhaseOffset * (PI * 2);
			float phase2 = _PhaseOffset * (PI * 1.123);
			float speed = _Time.y * _Speed;
			float speed2 = _Time.y * (_Speed * 0.33 );
			float _Depth2 = _Depth * 1.0;
			float v0alt = v0.x * _XDrift + v0.z * _ZDrift;
			float v1alt = v1.x * _XDrift + v1.z * _ZDrift;
			float v2alt = v2.x * _XDrift + v2.z * _ZDrift;
			
			// Modify the real vertex and two theoretical samples by the distortion algorithm (here a simple sine wave on Y, driven by local X pos)
			v0.y += sin( phase  + speed  + ( v0.x  * _Scale ) ) * _Depth;
			v0.y += sin( phase2 + speed2 + ( v0alt * _Scale ) ) * _Depth2; // This is just another wave being applied for a bit more complexity.
			
			v1.y += sin( phase  + speed  + ( v1.x  * _Scale ) ) * _Depth;
			v1.y += sin( phase2 + speed2 + ( v1alt * _Scale ) ) * _Depth2;
			
			v2.y += sin( phase  + speed  + ( v2.x  * _Scale ) ) * _Depth;
			v2.y += sin( phase2 + speed2 + ( v2alt * _Scale ) ) * _Depth2;
			
			// By reducing the delta on Y, we effectively restrict the amout of variation the normals will exhibit.
			// This appears like a smoothing effect, separate from the actual displacement depth.
			// It's basically undoing the change to the normals, leaving them straight on Y.
			v1.y -= (v1.y - v0.y) * _Smoothing;
			v2.y -= (v2.y - v0.y) * _Smoothing;
			
			// Solve worldspace normal
			float3 vna = cross( v2-v0, v1-v0 );
			
			// Put normals back in object space
			float3 vn = mul( float3x3(_World2Object), vna );
			
			// Normalize
			v.normal = normalize( vn );
			
			// Put vertex back in object space, Unity will automatically do the MVP projection
			v.vertex.xyz = mul( float3x3(_World2Object), v0 );
		}


		void surf (Input IN, inout SurfaceOutput o) 
		{
			half4 c = tex2D(_MainTex, float2(IN.uv_BottomTex.x +(_WaveSpeed.x * _Time.x),IN.uv_BottomTex.y+(_WaveSpeed.y * _Time.x)));
			half3 tex = c.rgb *_Distortion;
			half3 tex2 = tex2D(_BottomTex, float2(IN.uv_MainTex.x+tex.b+(_WaveSpeed.z * _Time.x),IN.uv_MainTex.y+tex.g)+(_WaveSpeed.w * _Time.x)).rgb*_Exposure;
			half3 emis1 = texCUBE (_Cube, IN.worldRefl).rgb * _Reflection;
			o.Albedo = tex2; 
			//o.Gloss = _Glos;
			o.Emission = emis1;
		}
	ENDCG
	}
	Fallback "Diffuse"
}