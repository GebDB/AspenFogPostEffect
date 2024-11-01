using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;

[Serializable, VolumeComponentMenuForRenderPipeline("Custom/FogEffect", typeof(UniversalRenderPipeline))]

public class FogEffectComponent : VolumeComponent, IPostProcessComponent
{

    public ColorParameter primaryFogColor = new ColorParameter(Color.white, true, true, true);
    public ColorParameter secondaryFogColor = new ColorParameter(Color.white, true, true, true);
    public ColorParameter skyBoxFogColor = new ColorParameter(Color.white, true, true, true);
    public MinFloatParameter fogDensity = new MinFloatParameter(0.0f, 0.0f);
    public MinFloatParameter skyBoxFogDensity = new MinFloatParameter(0.0f, 0.0f);
    public FloatParameter fogOffset = new FloatParameter(1f);
    public FloatParameter secondaryOffset = new FloatParameter(1.5f);
    public FloatParameter gradientStrength = new FloatParameter(0.7f);
    public FloatParameter fogScattering = new FloatParameter(1.0f);
    public TextureParameter noiseTexture = new TextureParameter(null);
    public FloatParameter noiseScale = new FloatParameter(1.0f);
    public FloatParameter noiseSpeed = new FloatParameter(1.0f);

    public FloatParameter heightFactor = new FloatParameter(1.0f);
    public FloatParameter heightOffset = new FloatParameter(1.0f);
    // public FloatParameter anisotropy = new FloatParameter(0.7f);

    public bool IsActive() => fogDensity != 0;
    public bool IsTileCompatible() => false;
}