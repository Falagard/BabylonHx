package com.babylonhx.engine.graphics.directx12;

import cpp.RawPointer;
import haxe.ds.StringMap;

/**
 * DirectX 12 Pipeline Cache: PSO caching with state hashing
 * Avoids redundant PSO creation by caching based on pipeline state hash
 */
class DirectXPipelineCache {
    
    // ============================================================
    // Cache Storage
    // ============================================================
    
    // PSO cache: hash -> PSO pointer
    private var psoCache:StringMap<RawPointer<Void>>;
    
    // PSO metadata: hash -> PSO metadata
    private var metadataCache:StringMap<PSOMetadata>;
    
    // Hash statistics
    private var hashStatistics:StringMap<HashStatistics>;
    
    // ============================================================
    // LRU Eviction Policy
    // ============================================================
    
    private var maxCacheSize:Int = 256;
    private var lruOrder:Array<String>; // Tracks most recently used order
    private var accessCount:StringMap<Int>;
    
    // ============================================================
    // Statistics
    // ============================================================
    
    private var totalCacheHits:Int = 0;
    private var totalCacheMisses:Int = 0;
    private var totalEvictions:Int = 0;
    private var totalPSOsCreated:Int = 0;
    private var peakCacheSize:Int = 0;
    
    // ============================================================
    // Configuration
    // ============================================================
    
    private var evictionPolicy:EvictionPolicy = EvictionPolicy.LRU;
    private var enableStatistics:Bool = true;
    
    // ============================================================
    // Initialization
    // ============================================================
    
    public function new() {
        psoCache = new StringMap<RawPointer<Void>>();
        metadataCache = new StringMap<PSOMetadata>();
        hashStatistics = new StringMap<HashStatistics>();
        lruOrder = [];
        accessCount = new StringMap<Int>();
    }
    
    // ============================================================
    // Cache Storage & Retrieval
    // ============================================================
    
    /**
     * Compute cache key hash from pipeline state
     */
    public function computeStateHash(pipeline:DirectXGraphicsPipeline):String {
        #if windows
        
        // Combine all relevant state into hash
        var stateString = "";
        
        // Add blend state
        var blendState = pipeline.getBlendState();
        stateString += "blend:" + blendState.blendEnable + ":" + blendState.srcBlend + ":" + blendState.destBlend;
        
        // Add rasterization state
        var rasterizerState = pipeline.getRasterizerState();
        stateString += "|rast:" + rasterizerState.cullMode + ":" + rasterizerState.fillMode + ":" + rasterizerState.depthClipEnable;
        
        // Add depth/stencil state
        var depthStencilState = pipeline.getDepthStencilState();
        stateString += "|depth:" + depthStencilState.depthEnable + ":" + depthStencilState.depthFunc + ":" + depthStencilState.depthWriteMask;
        
        // Add primitive topology
        stateString += "|topo:" + pipeline.getPrimitiveTopology();
        
        // Add render target formats
        stateString += "|rt:";
        for (i in 0...pipeline.getRenderTargetCount()) {
            stateString += pipeline.getRenderTargetFormat(i) + ",";
        }
        
        // Add depth format
        stateString += "|depth:" + pipeline.getDepthStencilFormat();
        
        // Add input layout
        stateString += "|layout:";
        for (i in 0...pipeline.getInputLayoutElementCount()) {
            var elem = pipeline.getInputLayoutElement(i);
            if (elem != null) {
                stateString += elem.semanticName + "," + elem.format + ";";
            }
        }
        
        // Compute simple hash
        var hash = simpleHash(stateString);
        return hash;
        
        #end
        
        return "";
    }
    
    /**
     * Simple hash function for state string
     */
    private function simpleHash(str:String):String {
        var hash:Int = 5381;
        for (i in 0...str.length) {
            var c = str.charCodeAt(i);
            hash = ((hash << 5) + hash) ^ c; // hash * 33 ^ c
        }
        return StringTools.hex(Math.abs(hash), 8);
    }
    
    /**
     * Look up PSO in cache
     */
    public function get(stateHash:String):RawPointer<Void> {
        if (psoCache.exists(stateHash)) {
            if (enableStatistics) {
                totalCacheHits++;
                
                // Update LRU
                if (lruOrder.indexOf(stateHash) >= 0) {
                    lruOrder.remove(stateHash);
                }
                lruOrder.push(stateHash);
                
                // Update access count
                if (accessCount.exists(stateHash)) {
                    accessCount.set(stateHash, accessCount.get(stateHash) + 1);
                } else {
                    accessCount.set(stateHash, 1);
                }
            }
            
            return psoCache.get(stateHash);
        }
        
        if (enableStatistics) {
            totalCacheMisses++;
        }
        
        return null;
    }
    
    /**
     * Store PSO in cache
     */
    public function put(stateHash:String, pso:RawPointer<Void>, metadata:PSOMetadata):Void {
        // Check if already cached
        if (psoCache.exists(stateHash)) {
            return; // Already cached
        }
        
        // Evict if cache is full
        if (psoCache.size() >= maxCacheSize) {
            evictOne();
        }
        
        // Store PSO and metadata
        psoCache.set(stateHash, pso);
        metadataCache.set(stateHash, metadata);
        lruOrder.push(stateHash);
        accessCount.set(stateHash, 0);
        
        // Update statistics
        if (enableStatistics) {
            totalPSOsCreated++;
            peakCacheSize = haxe.math.Math.max(peakCacheSize, psoCache.size());
        }
    }
    
    /**
     * Evict one PSO based on policy
     */
    private function evictOne():Void {
        if (lruOrder.length == 0) {
            return;
        }
        
        var hashToEvict:String = "";
        
        switch (evictionPolicy) {
            case LRU:
                // Evict least recently used (first in LRU order)
                hashToEvict = lruOrder.shift();
            case FIFO:
                // Evict first inserted
                hashToEvict = lruOrder.shift();
            case LFU:
                // Evict least frequently used
                var minAccess = Int.MAX_VALUE;
                for (hash in lruOrder) {
                    var count = accessCount.exists(hash) ? accessCount.get(hash) : 0;
                    if (count < minAccess) {
                        minAccess = count;
                        hashToEvict = hash;
                    }
                }
                lruOrder.remove(hashToEvict);
        }
        
        if (hashToEvict != "") {
            #if windows
            
            var pso = psoCache.get(hashToEvict);
            if (pso != null) {
                DirectXBindings.COM_Release(pso);
            }
            
            #end
            
            psoCache.remove(hashToEvict);
            metadataCache.remove(hashToEvict);
            accessCount.remove(hashToEvict);
            
            if (enableStatistics) {
                totalEvictions++;
            }
        }
    }
    
    // ============================================================
    // Cache Management
    // ============================================================
    
    /**
     * Clear entire cache
     */
    public function clear():Void {
        #if windows
        
        // Release all PSOs
        for (pso in psoCache.iterator()) {
            DirectXBindings.COM_Release(pso);
        }
        
        #end
        
        psoCache.clear();
        metadataCache.clear();
        hashStatistics.clear();
        lruOrder = [];
        accessCount.clear();
    }
    
    /**
     * Prewarm cache with known pipelines
     */
    public function prewarm(pipelines:Array<DirectXGraphicsPipeline>):Void {
        for (pipeline in pipelines) {
            var hash = computeStateHash(pipeline);
            
            // Would compile and cache each pipeline
            // pipeline.build(device);
            // pipeline.create();
            // put(hash, pipeline.getPSO(), metadata);
        }
    }
    
    /**
     * Check if PSO is cached
     */
    public function isCached(stateHash:String):Bool {
        return psoCache.exists(stateHash);
    }
    
    /**
     * Get cache size
     */
    public function getCacheSize():Int {
        return psoCache.size();
    }
    
    // ============================================================
    // Configuration
    // ============================================================
    
    /**
     * Set maximum cache size before eviction
     */
    public function setMaxCacheSize(size:Int):Void {
        maxCacheSize = size;
    }
    
    /**
     * Set eviction policy
     */
    public function setEvictionPolicy(policy:EvictionPolicy):Void {
        evictionPolicy = policy;
    }
    
    /**
     * Enable/disable statistics tracking
     */
    public function setStatisticsEnabled(enabled:Bool):Void {
        enableStatistics = enabled;
    }
    
    // ============================================================
    // Statistics & Diagnostics
    // ============================================================
    
    /**
     * Get cache hit rate
     */
    public function getHitRate():Float {
        if (totalCacheHits + totalCacheMisses == 0) {
            return 0.0;
        }
        return totalCacheHits / (totalCacheHits + totalCacheMisses);
    }
    
    /**
     * Get total cache hits
     */
    public function getTotalHits():Int {
        return totalCacheHits;
    }
    
    /**
     * Get total cache misses
     */
    public function getTotalMisses():Int {
        return totalCacheMisses;
    }
    
    /**
     * Get total evictions
     */
    public function getTotalEvictions():Int {
        return totalEvictions;
    }
    
    /**
     * Get total PSOs created
     */
    public function getTotalPSOsCreated():Int {
        return totalPSOsCreated;
    }
    
    /**
     * Get peak cache size
     */
    public function getPeakCacheSize():Int {
        return peakCacheSize;
    }
    
    /**
     * Get detailed cache report
     */
    public function getReport():String {
        var report = "Pipeline Cache Report:\n";
        report += "Cache Size: " + psoCache.size() + "/" + maxCacheSize + "\n";
        report += "Peak Size: " + peakCacheSize + "\n";
        report += "Total PSOs Created: " + totalPSOsCreated + "\n";
        report += "Cache Hits: " + totalCacheHits + "\n";
        report += "Cache Misses: " + totalCacheMisses + "\n";
        report += "Hit Rate: " + Math.round(getHitRate() * 10000) / 100 + "%\n";
        report += "Evictions: " + totalEvictions + "\n";
        report += "Eviction Policy: " + evictionPolicy.getName() + "\n";
        return report;
    }
    
    /**
     * Get top access patterns (hot PSOs)
     */
    public function getHotPSOs(topN:Int = 10):Array<String> {
        var sorted:Array<KeyValue> = [];
        
        for (hash in accessCount.keys()) {
            sorted.push(new KeyValue(hash, accessCount.get(hash)));
        }
        
        // Sort by access count descending
        sorted.sort(function(a, b) { return b.value - a.value; });
        
        var result:Array<String> = [];
        for (i in 0...Math.min(topN, sorted.length)) {
            result.push(sorted[i].key);
        }
        
        return result;
    }
    
    /**
     * Reset statistics
     */
    public function resetStatistics():Void {
        totalCacheHits = 0;
        totalCacheMisses = 0;
        totalEvictions = 0;
        totalPSOsCreated = 0;
        peakCacheSize = psoCache.size();
        
        for (hash in accessCount.keys()) {
            accessCount.set(hash, 0);
        }
    }
    
    // ============================================================
    // Cleanup
    // ============================================================
    
    public function dispose():Void {
        clear();
    }
}

/**
 * PSO metadata for cache diagnostics
 */
class PSOMetadata {
    public var hash:String;
    public var creationTime:Float;
    public var pipelineStateBits:Int;
    public var primitiveTopology:Int;
    public var renderTargetCount:Int;
    public var hasDepthStencil:Bool;
    public var vertexInputCount:Int;
    
    public function new(hash:String) {
        this.hash = hash;
        this.creationTime = haxe.Timer.stamp();
        this.pipelineStateBits = 0;
        this.primitiveTopology = 0;
        this.renderTargetCount = 0;
        this.hasDepthStencil = false;
        this.vertexInputCount = 0;
    }
}

/**
 * Eviction policy enumeration
 */
enum EvictionPolicy {
    LRU;  // Least Recently Used
    FIFO; // First In First Out
    LFU;  // Least Frequently Used
}

// Helper to get policy name
extension EvictionPolicyExt on EvictionPolicy {
    public function getName():String {
        return switch(this) {
            case LRU: "LRU (Least Recently Used)";
            case FIFO: "FIFO (First In First Out)";
            case LFU: "LFU (Least Frequently Used)";
        }
    }
}

/**
 * Helper class for key-value pair sorting
 */
private class KeyValue {
    public var key:String;
    public var value:Int;
    
    public function new(key:String, value:Int) {
        this.key = key;
        this.value = value;
    }
}
