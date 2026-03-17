package com.babylonhx.engine.graphics.webgl;

import com.babylonhx.engine.graphics.IGraphicsBuffer;
import com.babylonhx.utils.GL;
import com.babylonhx.utils.GL.WebGL2Context;
import com.babylonhx.utils.GL.GLBuffer;

/**
 * WebGL buffer implementation
 */
class WebGLGraphicsBuffer implements IGraphicsBuffer {
    private var gl:WebGL2Context;
    private var buffer:GLBuffer;
    private var size:Int;
    private var usage:Int;
    
    public function new(gl:WebGL2Context, buffer:GLBuffer, ?data:ArrayBufferView, usage:Int) {
        this.gl = gl;
        this.buffer = buffer;
        this.usage = usage;
        
        if (data != null) {
            bind(GL.COPY_WRITE_BUFFER);
            this.gl.bufferData(GL.COPY_WRITE_BUFFER, data, usage);
            this.size = data.byteLength;
        } else {
            this.size = 0;
        }
    }
    
    public function bind(target:Int):Void {
        this.gl.bindBuffer(target, this.buffer);
    }
    
    public function write(data:ArrayBufferView, offset:Int):Void {
        bind(GL.COPY_WRITE_BUFFER);
        this.gl.bufferSubData(GL.COPY_WRITE_BUFFER, offset, data);
    }
    
    public function update(data:ArrayBufferView):Void {
        bind(GL.COPY_WRITE_BUFFER);
        this.gl.bufferData(GL.COPY_WRITE_BUFFER, data, this.usage);
        this.size = data.byteLength;
    }
    
    public function getSize():Int {
        return this.size;
    }
    
    public function dispose():Void {
        this.gl.deleteBuffer(this.buffer);
    }
}
