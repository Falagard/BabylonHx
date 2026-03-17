package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.IGraphicsProgram;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.utils.GL.GLProgram;
import com.babylonhx.utils.GL.GLUniformLocation;

/**
 * WebGL shader program implementation
 */
class WebGLGraphicsProgram implements IGraphicsProgram {
    private var gl:WebGL2Context;
    private var program:GLProgram;
    private var attributeLocations:Map<String, Int>;
    private var uniformLocations:Map<String, GLUniformLocation>;
    
    public function new(gl:WebGL2Context, program:GLProgram) {
        this.gl = gl;
        this.program = program;
        this.attributeLocations = new Map();
        this.uniformLocations = new Map();
    }
    
    public function bind():Void {
        this.gl.useProgram(this.program);
    }
    
    public function setUniform(name:String, value:Dynamic):Void {
        var location = getUniformLocation(name);
        
        if (Std.is(value, Float)) {
            this.gl.uniform1f(location, cast(value, Float));
        } else if (Std.is(value, Int)) {
            this.gl.uniform1i(location, cast(value, Int));
        } else if (Std.is(value, Array)) {
            var arr:Array<Dynamic> = cast value;
            if (arr.length == 2) {
                this.gl.uniform2f(location, cast(arr[0], Float), cast(arr[1], Float));
            } else if (arr.length == 3) {
                this.gl.uniform3f(location, cast(arr[0], Float), cast(arr[1], Float), cast(arr[2], Float));
            } else if (arr.length == 4) {
                this.gl.uniform4f(location, cast(arr[0], Float), cast(arr[1], Float), cast(arr[2], Float), cast(arr[3], Float));
            }
        }
    }
    
    public function setMatrixUniform(name:String, matrix:Float32Array):Void {
        var location = getUniformLocation(name);
        
        if (matrix.length == 9) {
            this.gl.uniformMatrix3fv(location, false, matrix);
        } else if (matrix.length == 16) {
            this.gl.uniformMatrix4fv(location, false, matrix);
        }
    }
    
    public function setVectorUniform(name:String, x:Float, ?y:Float, ?z:Float, ?w:Float):Void {
        var location = getUniformLocation(name);
        
        if (y == null) {
            this.gl.uniform1f(location, x);
        } else if (z == null) {
            this.gl.uniform2f(location, x, y);
        } else if (w == null) {
            this.gl.uniform3f(location, x, y, z);
        } else {
            this.gl.uniform4f(location, x, y, z, w);
        }
    }
    
    public function setAttribute(name:String, buffer:IGraphicsBuffer, size:Int, ?stride:Int, ?offset:Int):Void {
        if (stride == null) stride = 0;
        if (offset == null) offset = 0;
        
        var location = getAttributeLocation(name);
        enableAttribute(name);
        
        // Cast to WebGL buffer and bind it
        var webglBuffer = cast(buffer, WebGLGraphicsBuffer);
        webglBuffer.bind(GL.ARRAY_BUFFER);
        
        this.gl.vertexAttribPointer(location, size, GL.FLOAT, false, stride, offset);
    }
    
    public function enableAttribute(name:String):Void {
        var location = getAttributeLocation(name);
        this.gl.enableVertexAttribArray(location);
    }
    
    public function disableAttribute(name:String):Void {
        var location = getAttributeLocation(name);
        this.gl.disableVertexAttribArray(location);
    }
    
    public function getAttributeLocation(name:String):Int {
        if (!this.attributeLocations.exists(name)) {
            var location = this.gl.getAttribLocation(this.program, name);
            this.attributeLocations.set(name, location);
        }
        return this.attributeLocations.get(name);
    }
    
    public function getUniformLocation(name:String):GLUniformLocation {
        if (!this.uniformLocations.exists(name)) {
            var location = this.gl.getUniformLocation(this.program, name);
            this.uniformLocations.set(name, location);
        }
        return this.uniformLocations.get(name);
    }
    
    public function dispose():Void {
        this.gl.deleteProgram(this.program);
    }
}
