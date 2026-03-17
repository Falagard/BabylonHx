package com.babylonhx.materials.shaders;

import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.utils.GL.GLProgram;
import com.babylonhx.utils.GL.GLUniformLocation;

/**
 * Information about a uniform block
 */
class UniformBlockInfo {
    public var name:String;
    public var index:Int;
    public var size:Int;
    public var members:Array<UniformMemberInfo>;
    
    public function new(name:String, index:Int, size:Int) {
        this.name = name;
        this.index = index;
        this.size = size;
        this.members = [];
    }
}

/**
 * Information about a uniform block member
 */
class UniformMemberInfo {
    public var name:String;
    public var type:String; // "mat4", "vec3", "float", etc.
    public var offset:Int;
    public var size:Int;
    
    public function new(name:String, type:String, offset:Int, size:Int) {
        this.name = name;
        this.type = type;
        this.offset = offset;
        this.size = size;
    }
}

/**
 * Information about a sampler uniform
 */
class SamplerInfo {
    public var name:String;
    public var location:Int;
    public var type:String; // "sampler2D", "samplerCube", etc.
    public var binding:Int;
    
    public function new(name:String, location:Int, type:String) {
        this.name = name;
        this.location = location;
        this.type = type;
        this.binding = location; // Default binding same as location
    }
}

/**
 * Information about a vertex attribute
 */
class AttributeInfo {
    public var name:String;
    public var location:Int;
    public var type:String; // "vec3", "mat4", etc.
    public var size:Int; // Number of components
    
    public function new(name:String, location:Int, type:String, size:Int) {
        this.name = name;
        this.location = location;
        this.type = type;
        this.size = size;
    }
}

/**
 * Shader Reflection - Extract information from compiled shaders
 * Used for automatic descriptor set generation, layout inference, etc.
 */
class ShaderReflection {
    private var gl:WebGL2Context;
    private var program:GLProgram;
    
    public var uniformBlocks:Array<UniformBlockInfo>;
    public var samplers:Array<SamplerInfo>;
    public var attributes:Array<AttributeInfo>;
    public var uniforms:Map<String, Dynamic>;
    
    public function new(gl:WebGL2Context, program:GLProgram) {
        this.gl = gl;
        this.program = program;
        this.uniformBlocks = [];
        this.samplers = [];
        this.attributes = [];
        this.uniforms = new Map();
        
        this._reflect();
    }
    
    /**
     * Get information about all active uniforms
     */
    public function getUniforms():Map<String, Dynamic> {
        return this.uniforms;
    }
    
    /**
     * Get information about all attributes
     */
    public function getAttributes():Array<AttributeInfo> {
        return this.attributes;
    }
    
    /**
     * Get information about all samplers
     */
    public function getSamplers():Array<SamplerInfo> {
        return this.samplers;
    }
    
    /**
     * Get information about uniform blocks
     */
    public function getUniformBlocks():Array<UniformBlockInfo> {
        return this.uniformBlocks;
    }
    
    /**
     * Find a uniform by name
     */
    public function getUniform(name:String):Dynamic {
        return this.uniforms.get(name);
    }
    
    /**
     * Find an attribute by name
     */
    public function getAttribute(name:String):AttributeInfo {
        for (attr in this.attributes) {
            if (attr.name == name) {
                return attr;
            }
        }
        return null;
    }
    
    /**
     * Find a sampler by name
     */
    public function getSampler(name:String):SamplerInfo {
        for (sampler in this.samplers) {
            if (sampler.name == name) {
                return sampler;
            }
        }
        return null;
    }
    
    // Private reflection implementation
    
    private function _reflect():Void {
        this._reflectAttributes();
        this._reflectUniforms();
        this._reflectSamplers();
    }
    
    private function _reflectAttributes():Void {
        var numAttribs = this.gl.getProgramParameter(this.program, GL.ACTIVE_ATTRIBUTES);
        
        for (i in 0...numAttribs) {
            var attrib = this.gl.getActiveAttrib(this.program, i);
            var location = this.gl.getAttribLocation(this.program, attrib.name);
            var info = new AttributeInfo(attrib.name, location, this._glTypeToString(attrib.type), attrib.size);
            this.attributes.push(info);
        }
    }
    
    private function _reflectUniforms():Void {
        var numUniforms = this.gl.getProgramParameter(this.program, GL.ACTIVE_UNIFORMS);
        
        for (i in 0...numUniforms) {
            var uniform = this.gl.getActiveUniform(this.program, i);
            var location = this.gl.getUniformLocation(this.program, uniform.name);
            
            var info = {
                name: uniform.name,
                type: this._glTypeToString(uniform.type),
                size: uniform.size,
                location: location
            };
            
            this.uniforms.set(uniform.name, info);
            
            // Check if it's a sampler
            if (this._isSamplerType(uniform.type)) {
                var sampler = new SamplerInfo(uniform.name, i, this._glTypeToString(uniform.type));
                this.samplers.push(sampler);
            }
        }
    }
    
    private function _reflectSamplers():Void {
        // WebGL doesn't have native sampler objects, so samplers are gathered during uniform reflection
        // This method is kept for future use with Vulkan backend
    }
    
    private function _glTypeToString(type:Int):String {
        return switch(type) {
            case GL.FLOAT: "float";
            case GL.FLOAT_VEC2: "vec2";
            case GL.FLOAT_VEC3: "vec3";
            case GL.FLOAT_VEC4: "vec4";
            case GL.INT: "int";
            case GL.INT_VEC2: "ivec2";
            case GL.INT_VEC3: "ivec3";
            case GL.INT_VEC4: "ivec4";
            case GL.BOOL: "bool";
            case GL.BOOL_VEC2: "bvec2";
            case GL.BOOL_VEC3: "bvec3";
            case GL.BOOL_VEC4: "bvec4";
            case GL.FLOAT_MAT2: "mat2";
            case GL.FLOAT_MAT3: "mat3";
            case GL.FLOAT_MAT4: "mat4";
            case GL.SAMPLER_2D: "sampler2D";
            case GL.SAMPLER_CUBE: "samplerCube";
            case GL.SAMPLER_3D: "sampler3D";
            case GL.SAMPLER_2D_SHADOW: "sampler2DShadow";
            default: "unknown";
        }
    }
    
    private function _isSamplerType(type:Int):Bool {
        return switch(type) {
            case GL.SAMPLER_2D: true;
            case GL.SAMPLER_CUBE: true;
            case GL.SAMPLER_3D: true;
            case GL.SAMPLER_2D_SHADOW: true;
            default: false;
        }
    }
}
