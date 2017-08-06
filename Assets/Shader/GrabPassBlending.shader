Shader "GrabPassBlending"
{
    Properties
    {
        _MenuTexture ("Menu Texture", 2D) = "white" {}
    }

    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent" "RenderType" = "Transparent" 
        }
        
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        GrabPass
        {
            "_BackgroundTexture"
        }

        Pass
        {
            CGPROGRAM
            
            #pragma vertex ComputeVertex
            #pragma fragment ComputeFragment
            
            #include "UnityCG.cginc"
            
            sampler2D _BackgroundTexture;
            sampler2D _MenuTexture;
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabUV : TEXCOORD1;
            };

            v2f ComputeVertex(appdata input) 
            {
                v2f output;
                
                output.vertex = UnityObjectToClipPos(input.vertex);
                output.grabUV = ComputeGrabScreenPos(output.vertex);
                
                output.uv = input.uv;
                
                return output;
            }

            half4 ComputeFragment(v2f data) : SV_Target
            {
                half4 bgColor = tex2Dproj(_BackgroundTexture, data.grabUV);
                half4 menuColor = tex2D(_MenuTexture, data.uv);
                
                half4 result = menuColor;
                
                if (distance(menuColor, bgColor) < 0.4) {
                    result = menuColor * (1.6 - distance(menuColor, bgColor));
                }
                
                result.a = menuColor.a;
                
                return result;
            }
            
            ENDCG
        }
    }
}