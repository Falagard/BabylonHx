package com.babylonhx.engine.graphics.pipeline;

import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;
import com.babylonhx.states._StencilState;
import com.babylonhx.engine.graphics.pipeline.PipelineEnums;
import com.babylonhx.engine.graphics.pipeline.PipelineStates;

/**
 * Maps BabylonHx render states to graphics pipeline states
 * Bridges the gap between BabylonHx's state system and Vulkan/graphics backend pipelines
 */
class PipelineStateMapper {
    
    /**
     * Convert BabylonHx AlphaState to pipeline BlendStateConfig
     */
    public static function mapAlphaState(alphaState:_AlphaState):BlendStateConfig {
        var blendState = new BlendStateConfig();
        
        if (alphaState != null) {
            blendState.enabled = alphaState.alphaBlend;
            
            // Map blend source factor
            blendState.srcColorBlend = mapBlendMode(alphaState.alphaSource);
            blendState.srcAlphaBlend = mapBlendMode(alphaState.alphaSourceAlpha);
            
            // Map blend destination factor
            blendState.dstColorBlend = mapBlendMode(alphaState.alphaDestination);
            blendState.dstAlphaBlend = mapBlendMode(alphaState.alphaDestinationAlpha);
        }
        
        return blendState;
    }
    
    /**
     * Convert BabylonHx DepthCullingState to pipeline states
     */
    public static function mapDepthCullingState(depthState:_DepthCullingState):DepthStencilStateConfig {
        var dssConfig = new DepthStencilStateConfig();
        
        if (depthState != null) {
            dssConfig.depthTestEnabled = false; // Controlled separately
            dssConfig.depthWriteEnabled = depthState.depthMask;
            dssConfig.depthCompareOp = mapComparisonFunction(depthState.depthFunc);
        }
        
        return dssConfig;
    }
    
    /**
     * Convert BabylonHx DepthCullingState to rasterization state
     */
    public static function mapRasterizationState(cullState:_DepthCullingState):RasterizationStateConfig {
        var rastState = new RasterizationStateConfig();
        
        if (cullState != null) {
            // Map culling
            rastState.cullMode = cullState.cullBackFaces ? CullMode.BACK : CullMode.NONE;
            
            // Map depth bias
            if (cullState.zOffset != 0 || cullState.zOffsetUnits != 0) {
                rastState.depthBiasEnabled = true;
                rastState.depthBiasConstantFactor = cullState.zOffset;
                rastState.depthBiasSlopeFactor = cullState.zOffsetUnits;
            }
        }
        
        return rastState;
    }
    
    /**
     * Convert BabylonHx StencilState to pipeline stencil configuration
     */
    public static function mapStencilState(stencilState:_StencilState):DepthStencilStateConfig {
        var dssConfig = new DepthStencilStateConfig();
        
        if (stencilState != null) {
            dssConfig.stencilTestEnabled = stencilState.stencilTest;
            dssConfig.stencilReadMask = 0xFF; // Default
            dssConfig.stencilWriteMask = stencilState.stencilMask;
            dssConfig.stencilReference = stencilState.stencilFunc;
        }
        
        return dssConfig;
    }
    
    /**
     * Map BabylonHx blend mode to pipeline BlendFactor
     */
    private static function mapBlendMode(mode:Int):BlendFactor {
        return switch(mode) {
            case 0: BlendFactor.ZERO;
            case 1: BlendFactor.ONE;
            case 2: BlendFactor.SRC_COLOR;
            case 3: BlendFactor.ONE_MINUS_SRC_COLOR;
            case 4: BlendFactor.DST_COLOR;
            case 5: BlendFactor.ONE_MINUS_DST_COLOR;
            case 6: BlendFactor.SRC_ALPHA;
            case 7: BlendFactor.ONE_MINUS_SRC_ALPHA;
            case 8: BlendFactor.DST_ALPHA;
            case 9: BlendFactor.ONE_MINUS_DST_ALPHA;
            default: BlendFactor.SRC_ALPHA;
        }
    }
    
    /**
     * Map BabylonHx comparison function to pipeline CompareOp
     */
    private static function mapComparisonFunction(func:Int):CompareOp {
        return switch(func) {
            case 0: CompareOp.NEVER;
            case 1: CompareOp.LESS;
            case 2: CompareOp.EQUAL;
            case 3: CompareOp.LESS_OR_EQUAL;
            case 4: CompareOp.GREATER;
            case 5: CompareOp.NOT_EQUAL;
            case 6: CompareOp.GREATER_OR_EQUAL;
            case 7: CompareOp.ALWAYS;
            default: CompareOp.LESS_OR_EQUAL;
        }
    }
}
