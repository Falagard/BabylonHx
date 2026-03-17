package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.*;
import com.babylonhx.states._AlphaState;
import com.babylonhx.states._DepthCullingState;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;

/**
 * WebGL render pipeline state implementation
 * Maps BabylonHx state objects to WebGL state calls
 */
class WebGLRenderPipeline implements IRenderPipeline {
    private var gl:WebGL2Context;
    private var program:IGraphicsProgram;
    private var vertexBuffer:IGraphicsBuffer;
    private var indexBuffer:IGraphicsBuffer;
    private var isValid:Bool = false;
    
    public function new(gl:WebGL2Context) {
        this.gl = gl;
    }
    
    public function setBlendState(alphaState:_AlphaState):Void {
        // Apply alpha blending state
        if (alphaState.alphaBlend) {
            this.gl.enable(GL.BLEND);
            this.gl.blendFuncSeparate(
                mapBlendMode(alphaState.alphaSource),
                mapBlendMode(alphaState.alphaDestination),
                mapBlendMode(alphaState.alphaSourceAlpha),
                mapBlendMode(alphaState.alphaDestinationAlpha)
            );
        } else {
            this.gl.disable(GL.BLEND);
        }
    }
    
    public function setDepthStencilState(depthState:_DepthCullingState):Void {
        // Set depth testing
        if (depthState.zOffset > 0 || depthState.zOffsetUnits > 0) {
            this.gl.enable(GL.POLYGON_OFFSET_FILL);
            this.gl.polygonOffset(depthState.zOffsetUnits, depthState.zOffset);
        } else {
            this.gl.disable(GL.POLYGON_OFFSET_FILL);
        }
        
        // Set depth function
        this.gl.depthFunc(mapComparisonFunction(depthState.depthFunc));
        
        // Set depth write
        this.gl.depthMask(depthState.depthMask);
    }
    
    public function setRasterizationState(cullState:_DepthCullingState):Void {
        // Set face culling
        if (cullState.cullBackFaces) {
            this.gl.enable(GL.CULL_FACE);
            this.gl.cullFace(GL.BACK);
        } else {
            this.gl.disable(GL.CULL_FACE);
        }
    }
    
    public function setProgram(program:IGraphicsProgram):Void {
        this.program = program;
        if (this.program != null) {
            this.program.bind();
        }
    }
    
    public function setVertexBuffer(buffer:IGraphicsBuffer):Void {
        this.vertexBuffer = buffer;
    }
    
    public function setIndexBuffer(buffer:IGraphicsBuffer):Void {
        this.indexBuffer = buffer;
    }
    
    public function finalize():Void {
        // Validate pipeline state
        this.isValid = (this.program != null);
    }
    
    public function isValid():Bool {
        return this.isValid;
    }
    
    public function dispose():Void {
        // Nothing to dispose for WebGL pipelines
    }
    
    private function mapBlendMode(mode:Int):Int {
        return switch(mode) {
            case 0: GL.ZERO;
            case 1: GL.ONE;
            case 2: GL.SRC_COLOR;
            case 3: GL.ONE_MINUS_SRC_COLOR;
            case 4: GL.DST_COLOR;
            case 5: GL.ONE_MINUS_DST_COLOR;
            case 6: GL.SRC_ALPHA;
            case 7: GL.ONE_MINUS_SRC_ALPHA;
            case 8: GL.DST_ALPHA;
            case 9: GL.ONE_MINUS_DST_ALPHA;
            default: GL.ONE;
        }
    }
    
    private function mapComparisonFunction(func:Int):Int {
        return switch(func) {
            case 0: GL.NEVER;
            case 1: GL.LESS;
            case 2: GL.EQUAL;
            case 3: GL.LEQUAL;
            case 4: GL.GREATER;
            case 5: GL.NOTEQUAL;
            case 6: GL.GEQUAL;
            case 7: GL.ALWAYS;
            default: GL.LEQUAL;
        }
    }
}
