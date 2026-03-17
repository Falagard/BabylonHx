package com.babylonhx.engine.graphics.pipeline;

import com.babylonhx.engine.graphics.pipeline.PipelineStates;

/**
 * Pipeline cache for optimizing state changes
 * Tracks current pipeline states to avoid redundant GPU commands
 * Provides fast lookup of previously created pipelines
 */
class PipelineCache {
    
    /**
     * Cached pipelines keyed by state hash
     */
    private var _pipelineCache:Map<String, Dynamic> = new Map();
    
    /**
     * Current blend state
     */
    private var _currentBlendState:BlendStateConfig;
    
    /**
     * Current depth/stencil state
     */
    private var _currentDepthStencilState:DepthStencilStateConfig;
    
    /**
     * Current rasterization state
     */
    private var _currentRasterizationState:RasterizationStateConfig;
    
    /**
     * Statistics for cache performance
     */
    private var _cacheHits:Int = 0;
    private var _cacheMisses:Int = 0;
    
    public function new() {
        _currentBlendState = new BlendStateConfig();
        _currentDepthStencilState = new DepthStencilStateConfig();
        _currentRasterizationState = new RasterizationStateConfig();
    }
    
    /**
     * Get or create a pipeline for the given state configuration
     * @param blendState Blend state configuration
     * @param depthStencilState Depth/stencil state configuration
     * @param rastState Rasterization state configuration
     * @param creator Function to create the pipeline if not cached
     */
    public function getPipeline(
        blendState:BlendStateConfig,
        depthStencilState:DepthStencilStateConfig,
        rastState:RasterizationStateConfig,
        creator:Void->Dynamic):Dynamic {
        
        var hash = getPipelineHash(blendState, depthStencilState, rastState);
        
        if (_pipelineCache.exists(hash)) {
            _cacheHits++;
            return _pipelineCache.get(hash);
        }
        
        _cacheMisses++;
        var pipeline = creator();
        _pipelineCache.set(hash, pipeline);
        
        return pipeline;
    }
    
    /**
     * Check if a pipeline state has changed since last call
     */
    public function hasBlendStateChanged(blendState:BlendStateConfig):Bool {
        return !_currentBlendState.equals(blendState);
    }
    
    /**
     * Check if depth/stencil state has changed
     */
    public function hasDepthStencilStateChanged(depthStencilState:DepthStencilStateConfig):Bool {
        return _currentDepthStencilState.getHash() != depthStencilState.getHash();
    }
    
    /**
     * Check if rasterization state has changed
     */
    public function hasRasterizationStateChanged(rastState:RasterizationStateConfig):Bool {
        return _currentRasterizationState.getHash() != rastState.getHash();
    }
    
    /**
     * Update current state snapshots
     */
    public function updateBlendState(blendState:BlendStateConfig):Void {
        _currentBlendState = blendState.clone();
    }
    
    public function updateDepthStencilState(depthStencilState:DepthStencilStateConfig):Void {
        _currentDepthStencilState = depthStencilState.clone();
    }
    
    public function updateRasterizationState(rastState:RasterizationStateConfig):Void {
        _currentRasterizationState = rastState.clone();
    }
    
    /**
     * Get combined state hash for quick lookup
     */
    public function getPipelineHash(
        blendState:BlendStateConfig,
        depthStencilState:DepthStencilStateConfig,
        rastState:RasterizationStateConfig):String {
        
        return blendState.getHash() + "|" + 
               depthStencilState.getHash() + "|" + 
               rastState.getHash();
    }
    
    /**
     * Clear the pipeline cache
     */
    public function clear():Void {
        _pipelineCache.clear();
        _cacheHits = 0;
        _cacheMisses = 0;
    }
    
    /**
     * Get cache statistics
     */
    public function getCacheStats():{hits: Int, misses: Int, hitRate: Float} {
        var total = _cacheHits + _cacheMisses;
        var hitRate = total > 0 ? _cacheHits / total : 0.0;
        
        return {
            hits: _cacheHits,
            misses: _cacheMisses,
            hitRate: hitRate
        };
    }
    
    /**
     * Reset cache statistics
     */
    public function resetStats():Void {
        _cacheHits = 0;
        _cacheMisses = 0;
    }
    
    /**
     * Get current states
     */
    public function getCurrentBlendState():BlendStateConfig {
        return _currentBlendState.clone();
    }
    
    public function getCurrentDepthStencilState():DepthStencilStateConfig {
        return _currentDepthStencilState.clone();
    }
    
    public function getCurrentRasterizationState():RasterizationStateConfig {
        return _currentRasterizationState.clone();
    }
}
