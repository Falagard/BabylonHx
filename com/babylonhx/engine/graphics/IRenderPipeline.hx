package com.babylonhx.engine.graphics;

import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;

/**
 * Interface for render pipeline state abstraction
 * Maps BabylonHx render states to backend-specific pipeline states
 */
interface IRenderPipeline {
    /**
     * Set blend/alpha state
     * @param alphaState The alpha blending state
     */
    function setBlendState(alphaState:_AlphaState):Void;
    
    /**
     * Set depth and stencil state
     * @param depthState The depth culling state
     */
    function setDepthStencilState(depthState:_DepthCullingState):Void;
    
    /**
     * Set rasterization state (culling, fill mode, etc.)
     * @param cullState The culling state
     */
    function setRasterizationState(cullState:_DepthCullingState):Void;
    
    /**
     * Set the shader program for this pipeline
     * @param program The shader program
     */
    function setProgram(program:IGraphicsProgram):Void;
    
    /**
     * Bind vertex buffer
     * @param buffer The vertex buffer
     */
    function setVertexBuffer(buffer:IGraphicsBuffer):Void;
    
    /**
     * Bind index buffer
     * @param buffer The index buffer
     */
    function setIndexBuffer(buffer:IGraphicsBuffer):Void;
    
    /**
     * Finalize and create the pipeline
     * Must be called after all state has been set
     */
    function finalize():Void;
    
    /**
     * Check if pipeline is ready to use
     */
    function isValid():Bool;
    
    /**
     * Dispose the pipeline and free resources
     */
    function dispose():Void;
}
