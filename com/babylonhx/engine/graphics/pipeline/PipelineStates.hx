package com.babylonhx.engine.graphics.pipeline;

import com.babylonhx.engine.graphics.pipeline.PipelineEnums;

/**
 * Blend state configuration
 */
class BlendStateConfig {
    public var enabled:Bool = false;
    public var srcColorBlend:BlendFactor = BlendFactor.SRC_ALPHA;
    public var dstColorBlend:BlendFactor = BlendFactor.ONE_MINUS_SRC_ALPHA;
    public var srcAlphaBlend:BlendFactor = BlendFactor.ONE;
    public var dstAlphaBlend:BlendFactor = BlendFactor.ZERO;
    public var colorBlendOp:BlendOp = BlendOp.ADD;
    public var alphaBlendOp:BlendOp = BlendOp.ADD;
    public var colorWriteMask:Int = 0xF; // RGBA
    
    public function new() {
    }
    
    public function clone():BlendStateConfig {
        var clone = new BlendStateConfig();
        clone.enabled = this.enabled;
        clone.srcColorBlend = this.srcColorBlend;
        clone.dstColorBlend = this.dstColorBlend;
        clone.srcAlphaBlend = this.srcAlphaBlend;
        clone.dstAlphaBlend = this.dstAlphaBlend;
        clone.colorBlendOp = this.colorBlendOp;
        clone.alphaBlendOp = this.alphaBlendOp;
        clone.colorWriteMask = this.colorWriteMask;
        return clone;
    }
    
    public function equals(other:BlendStateConfig):Bool {
        if (other == null) return false;
        return this.enabled == other.enabled &&
               this.srcColorBlend == other.srcColorBlend &&
               this.dstColorBlend == other.dstColorBlend &&
               this.srcAlphaBlend == other.srcAlphaBlend &&
               this.dstAlphaBlend == other.dstAlphaBlend &&
               this.colorBlendOp == other.colorBlendOp &&
               this.alphaBlendOp == other.alphaBlendOp &&
               this.colorWriteMask == other.colorWriteMask;
    }
    
    public function getHash():String {
        return Std.string(enabled) + "_" +
               Std.string(srcColorBlend) + "_" +
               Std.string(dstColorBlend) + "_" +
               Std.string(srcAlphaBlend) + "_" +
               Std.string(dstAlphaBlend) + "_" +
               Std.string(colorBlendOp) + "_" +
               Std.string(alphaBlendOp) + "_" +
               Std.string(colorWriteMask);
    }
}

/**
 * Depth and stencil state configuration
 */
class DepthStencilStateConfig {
    public var depthTestEnabled:Bool = true;
    public var depthWriteEnabled:Bool = true;
    public var depthCompareOp:CompareOp = CompareOp.LESS_OR_EQUAL;
    
    public var stencilTestEnabled:Bool = false;
    public var frontStencilCompareOp:CompareOp = CompareOp.ALWAYS;
    public var frontStencilFailOp:StencilOp = StencilOp.KEEP;
    public var frontStencilDepthFailOp:StencilOp = StencilOp.KEEP;
    public var frontStencilPassOp:StencilOp = StencilOp.KEEP;
    public var backStencilCompareOp:CompareOp = CompareOp.ALWAYS;
    public var backStencilFailOp:StencilOp = StencilOp.KEEP;
    public var backStencilDepthFailOp:StencilOp = StencilOp.KEEP;
    public var backStencilPassOp:StencilOp = StencilOp.KEEP;
    public var stencilReadMask:Int = 0xFF;
    public var stencilWriteMask:Int = 0xFF;
    public var stencilReference:Int = 0;
    
    public function new() {
    }
    
    public function clone():DepthStencilStateConfig {
        var clone = new DepthStencilStateConfig();
        clone.depthTestEnabled = this.depthTestEnabled;
        clone.depthWriteEnabled = this.depthWriteEnabled;
        clone.depthCompareOp = this.depthCompareOp;
        clone.stencilTestEnabled = this.stencilTestEnabled;
        clone.frontStencilCompareOp = this.frontStencilCompareOp;
        clone.frontStencilFailOp = this.frontStencilFailOp;
        clone.frontStencilDepthFailOp = this.frontStencilDepthFailOp;
        clone.frontStencilPassOp = this.frontStencilPassOp;
        clone.backStencilCompareOp = this.backStencilCompareOp;
        clone.backStencilFailOp = this.backStencilFailOp;
        clone.backStencilDepthFailOp = this.backStencilDepthFailOp;
        clone.backStencilPassOp = this.backStencilPassOp;
        clone.stencilReadMask = this.stencilReadMask;
        clone.stencilWriteMask = this.stencilWriteMask;
        clone.stencilReference = this.stencilReference;
        return clone;
    }
    
    public function getHash():String {
        return Std.string(depthTestEnabled) + "_" +
               Std.string(depthWriteEnabled) + "_" +
               Std.string(depthCompareOp) + "_" +
               Std.string(stencilTestEnabled) + "_" +
               Std.string(stencilReadMask) + "_" +
               Std.string(stencilWriteMask) + "_" +
               Std.string(stencilReference);
    }
}

/**
 * Rasterization state configuration
 */
class RasterizationStateConfig {
    public var cullMode:CullMode = CullMode.BACK;
    public var frontFace:FrontFace = FrontFace.COUNTER_CLOCKWISE;
    public var polygonMode:PolygonMode = PolygonMode.FILL;
    public var depthBiasEnabled:Bool = false;
    public var depthBiasConstantFactor:Float = 0.0;
    public var depthBiasSlopeFactor:Float = 0.0;
    public var depthBiasClamp:Float = 0.0;
    public var lineWidth:Float = 1.0;
    
    public function new() {
    }
    
    public function clone():RasterizationStateConfig {
        var clone = new RasterizationStateConfig();
        clone.cullMode = this.cullMode;
        clone.frontFace = this.frontFace;
        clone.polygonMode = this.polygonMode;
        clone.depthBiasEnabled = this.depthBiasEnabled;
        clone.depthBiasConstantFactor = this.depthBiasConstantFactor;
        clone.depthBiasSlopeFactor = this.depthBiasSlopeFactor;
        clone.depthBiasClamp = this.depthBiasClamp;
        clone.lineWidth = this.lineWidth;
        return clone;
    }
    
    public function getHash():String {
        return Std.string(cullMode) + "_" +
               Std.string(frontFace) + "_" +
               Std.string(polygonMode) + "_" +
               Std.string(depthBiasEnabled) + "_" +
               Std.string(lineWidth);
    }
}
