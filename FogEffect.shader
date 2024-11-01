Shader "Custom/FogEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PFogColor ("Primary Fog Color", Color) = (1,1,1,1)
        _SFogColor("Secondary Fog Color", Color) = (1,1,1,1)
        _SkyBoxFogColor("Skybox Fog Color", Color) = (1,1,1,1)
        _FogDensity ("Fog Density", Float) = 0.1 // Controls fog intensity
        _SkyBoxFogDensity ("Sky Box Fog Density", Float) = 1 // Controls fog intensity
        _FogOffset ("Fog Offset", Float) = 1 // Distance from which fog starts to apply
        _SecondaryOffset ("Secondary Offset", Float) = 1
        _GradientStrength("Gradient Strength", Float) = 0.7
        _FogScattering("Fog Scattering", Float) = 1.0
        _NoiseTex ("Noise Texture", 2D) = "white" {} // Add noise texture
        _NoiseScale ("Noise Scale", Float) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1; // For volumetric fog
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            Float _NoiseScale;
            Float _NoiseSpeed;
            sampler2D _CameraDepthTexture;
            float4 _PFogColor;
            float4 _SFogColor;
            float4 _SkyBoxFogColor;
            float _FogDensity;
            float _SkyBoxFogDensity;
            float _FogOffset;
            float _SecondaryOffset;
            float _GradientStrength;
            float _FogScattering;

            v2f vert (appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldPos = v.vertex.xyz; // Pass world position to fragment shader
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // Sample the main texture color
                float4 sceneColor = tex2D(_MainTex, i.uv);
                float4 noiseValue = tex2D(_NoiseTex, i.uv);

                // Sample and linearize the depth
                float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
                depth = Linear01Depth(depth);

                // Calculate view distance
                float viewDistance = depth * _ProjectionParams.z;

                // Calculate fog factor
                float fogFactor = exp(-viewDistance * _FogDensity);

                // Add volumetric fog effect
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float noise = tex2D(_NoiseTex, i.uv * _NoiseScale + (_Time.y * _NoiseSpeed)).r; // Use noise for variation
                fogFactor *= lerp(1.0, noise, _FogScattering); // Combine fog density with noise

                if (depth >= 1) {
                    float4 finalFogColor = lerp(sceneColor, _SkyBoxFogColor, _SkyBoxFogDensity);
                    return finalFogColor;
                }

                // Calculate distance factor for color interpolation
                float distanceFactor = pow(saturate((viewDistance - _FogOffset) / _SecondaryOffset), _GradientStrength);
                // Interpolate between primary and secondary fog colors
                float4 finalFogColor = lerp(_PFogColor, _SFogColor, distanceFactor);

                // Final color blending
                float4 finalColor = lerp(finalFogColor, sceneColor, saturate(fogFactor));
                return finalColor;
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}
