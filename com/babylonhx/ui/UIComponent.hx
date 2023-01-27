package com.babylonhx.ui;

import haxe.ui.core.ComponentContainer;
import com.babylonhx.engine.Engine;

class UIComponent {

	var _scene : Scene = null;

    var children : Array<UIComponent>;

    /**
		The parent container of this Component.
		See `UIComponent.contentChanged` for more details.
	**/
    var parentContainer : UIComponent;

    /**
		The parent object in the scene tree.
	**/
	public var parent(default, null) : UIComponent;

    /**
		The x position (in pixels) of the object relative to its parent.
	**/
	public var x(default,set) : Float = 0;

	/**
		The y position (in pixels) of the object relative to its parent.
	**/
	public var y(default, set) : Float = 0;

	/**
		The amount of horizontal scaling of this object.
	**/
	public var scaleX(default,set) : Float = 1;

	/**
		The amount of vertical scaling of this object.
	**/
	public var scaleY(default,set) : Float = 1;

	/**
		The rotation angle of this object, in radians.
	**/
	public var rotation(default, set) : Float = 0;

	/**
		Is the object and its children are displayed on screen.
	**/
	public var visible(default, set) : Bool = true;

    inline function set_x(v) {
		posChanged = true;
		return x = v;
	}

	inline function set_y(v) {
		posChanged = true;
		return y = v;
	}

	inline function set_scaleX(v) {
		posChanged = true;
		return scaleX = v;
	}

	inline function set_scaleY(v) {
		posChanged = true;
		return scaleY = v;
	}

	inline function set_rotation(v) {
		posChanged = true;
		return rotation = v;
	}

    function set_visible(b) {
		if( visible == b )
			return b;
		visible = b;
		onContentChanged();
		return b;
	}

	/**
		The amount of transparency of the Component.
	**/
	public var alpha : Float = 1.;

    var matA : Float;
	var matB : Float;
	var matC : Float;
	var matD : Float;
	var absX : Float;
	var absY : Float;

	/**
		A flag that indicates that the object transform was modified and absolute position recalculation is required.

		Automatically cleared on `UIComponent.sync` and can be manually synced with the `UIComponent.syncPos`.
	**/
	@:dox(show)
	var posChanged : Bool;
	/**
		A flag that indicates whether the object was allocated or not.

		When adding children to allocated objects, `onAdd` is being called immediately,
		otherwise it's delayed until the whole tree is added to a currently active `Scene`.
	**/
	@:dox(show)
	var allocated : Bool;
	var lastFrame : Int;

	/**
		How many immediate children this object has.
	**/
	public var numChildren(get, never) : Int;

	inline function get_numChildren() {
		return children.length;
	}

	/**
		Create a new empty object.
		@param parent An optional parent `UIComponent` instance to which Object adds itself if set.
	**/
	public function new( ?parent : UIComponent, ?scene: Scene ) {

		this._scene = scene != null ? scene : Engine.LastCreatedScene;

		matA = 1; matB = 0; matC = 0; matD = 1; absX = 0; absY = 0;
		posChanged = parent != null;
		children = [];
		if( parent != null )
			parent.addChild(this);
	}

	/**
	 * Gets the scene of the node
	 * @returns a {BABYLON.Scene}
	 */
	 inline public function getScene():Scene {
		return this._scene;
	}

    /**
		Add a child object at the end of the children list.
	**/
	public function addChild( s : UIComponent ) : Void {
		addChildAt(s, children.length);
	}

	/**
		Insert a child object at the specified position of the children list.
	**/
	public function addChildAt( s : UIComponent, pos : Int ) : Void {
		if( pos < 0 ) pos = 0;
		if( pos > children.length ) pos = children.length;
		var p = this;
		while( p != null ) {
			if( p == s ) throw "Recursive addChild";
			p = p.parent;
		}
		if( s.parent != null ) {
			// prevent calling onRemove
			var old = s.allocated;
			s.allocated = false;
			s.parent.removeChild(s);
			s.allocated = old;
		}
		children.insert(pos, s);
		if( !allocated && s.allocated )
			s.onRemove();
		s.parent = this;
		s.parentContainer = parentContainer;
		s.posChanged = true;
		// ensure that proper alloc/delete is done if we change parent
		if( allocated ) {
			if( !s.allocated )
				s.onAdd();
			else
				s.onHierarchyMoved(true);
		}
		onContentChanged();
	}

    /**
		Remove the given object from the immediate children list of the object if it's part of it.
	**/
	public function removeChild( s : UIComponent ) {
		if( children.remove(s) ) {
			if( s.allocated ) s.onRemove();
			s.parent = null;
			if( s.parentContainer != null ) s.setParentContainer(null);
			s.posChanged = true;
			onContentChanged();
		}
	}

	/**
		Remove all children from the immediate children list.
	**/
	public function removeChildren() {
		while( numChildren>0 )
			removeChild( getChildAt(0) );
	}

	/**
		Return the `n`th element among the immediate children list of this object, or `null` if there is no Object at this position.
	**/
	public function getChildAt( n ) {
		return children[n];
	}

	/**
		Same as `parent.removeChild(this)`, but does nothing if parent is null.
	**/
	public inline function remove() {
		if( this != null && parent != null ) parent.removeChild(this);
	}

    /**
		Sets the parent container for this Object and it's children.
		See `Object.contentChanged` for more details.
	**/
	function setParentContainer( c : UIComponent ) {
		parentContainer = c;
		for( s in children )
			s.setParentContainer(c);
	}

    /**
		Sent when object is removed from the allocated scene.

		Do not remove the super call when overriding.
	**/
	function onRemove() {
		allocated = false;
		var i = children.length - 1;
		while( i >= 0 ) {
			var c = children[i--];
			if( c != null ) c.onRemove();
		}
	}

    /**
		Sent when object was already allocated and moved within scene object tree hierarchy.

		Do not remove the super call when overriding.

		@param parentChanged Whether Object was moved withing same parent (through `Layers.ysort` for example) or relocated to a new one.
	**/
	@:dox(show)
	function onHierarchyMoved( parentChanged : Bool ) {
		for ( c in children )
			c.onHierarchyMoved(parentChanged);
	}

	/**
		Sent when object is being added to an allocated scene.

		Do not remove the super call when overriding.
	**/
	function onAdd() {
		allocated = true;
		for( c in children )
			c.onAdd();
	}

    /**
		Should be called when Object content was changed in order to notify parent container. See `UIComponent.contentChanged`.
	**/
	inline function onContentChanged() {
		if( parentContainer != null ) parentContainer.contentChanged(this);
	}

    /**
		<span class="label">Advanced usage</span>
		Called by the children of a container object if they have `parentContainer` defined in them.
		Primary use-case is when the child size got changed, requiring content to reevaluate positioning such as `Flow` layouts,
		but also can be used for other purposes.
	**/
	function contentChanged( s : UIComponent ) {
	}

    public function drawRec(engine: Engine) {
		if( !visible ) return;
		// fallback in case the object was added during a sync() event and we somehow didn't update it
		if( posChanged ) {
			// only sync anim, don't update() (prevent any event from occuring during draw())
			// if( currentAnimation != null ) currentAnimation.sync();
			calcAbsPos();
			for( c in children )
				c.posChanged = true;
			posChanged = false;
		}

        //var scene = this.getScene();
		//var engine = scene.getEngine();

        //var old = engine.globalAlpha;
        //ctx.globalAlpha *= alpha;
        drawContent(engine);
        //ctx.globalAlpha = old;
		
	}

	function drawContent(engine: Engine) {
		var front2back: Bool = false; //store front to back in engine?
		if ( front2back ) {
			var i = children.length;
			while ( i-- > 0 ) children[i].drawRec(engine);
			draw(engine);
		} else {
			draw(engine);
			for ( c in children ) c.drawRec(engine);
		}
	}

	function draw( engine: Engine ) {
		//baseShader.absoluteMatrixA.set(obj.matA, obj.matC, obj.absX);
		//baseShader.absoluteMatrixB.set(obj.matB, obj.matD, obj.absY);
		//trace('draw -> absX ${absX} absY ${absY} matA ${matA} matB ${matB} matC ${matC} matD ${matD}');
	}

	/**
		<span class="label">Internal usage</span>
		Calculates the absolute object position transform.
		See `Object.syncPos` for a safe position sync method.
		This method does not ensure that object parents also have up-to-date transform nor does it clear the `Object.posChanged` flag.
	**/
	function calcAbsPos() {
		if( parent == null ) {
			var cr, sr;
			if( rotation == 0 ) {
				cr = 1.; sr = 0.;
				matA = scaleX;
				matB = 0;
				matC = 0;
				matD = scaleY;
			} else {
				cr = Math.cos(rotation);
				sr = Math.sin(rotation);
				matA = scaleX * cr;
				matB = scaleX * sr;
				matC = scaleY * -sr; 
				matD = scaleY * cr;
			}
			absX = x;
			absY = y;
		} else {
			// M(rel) = S . R . T
			// M(abs) = M(rel) . P(abs)
			if( rotation == 0 ) {
				matA = scaleX * parent.matA;
				matB = scaleX * parent.matB;
				matC = scaleY * parent.matC;
				matD = scaleY * parent.matD;
			} else {
				var cr = Math.cos(rotation);
				var sr = Math.sin(rotation);
				var tmpA = scaleX * cr;
				var tmpB = scaleX * sr;
				var tmpC = scaleY * -sr;
				var tmpD = scaleY * cr;
				matA = tmpA * parent.matA + tmpB * parent.matC;
				matB = tmpA * parent.matB + tmpB * parent.matD;
				matC = tmpC * parent.matA + tmpD * parent.matC;
				matD = tmpC * parent.matB + tmpD * parent.matD;
			}
			absX = x * parent.matA + y * parent.matC + parent.absX;
			absY = x * parent.matB + y * parent.matD + parent.absY;
		}

		//var comp:ComponentContainer = cast this;
		trace('calcAbsPos -> absX ${absX} absY ${absY} matA ${matA} matB ${matB} matC ${matC} matD ${matD}');
	}

	/**
		Performs a sync of data for rendering (such as absolute position recalculation).
		While this method can be used as a substitute to an update loop, it's primary purpose it to prepare the Object to be rendered.

		Do not remove the super call when overriding.
	**/
	public function sync(engine: Engine) {
		var changed = posChanged;
		if( changed ) {
			calcAbsPos();
			posChanged = false;
		}

		//lastFrame = ctx.frame;
		var p = 0, len = children.length;
		while( p < len ) {
			var c = children[p];
			if( c == null )
				break;
			//if( c.lastFrame != ctx.frame ) { //CL todo track frame changes to prevent synching multiple times per frame
				if( changed ) c.posChanged = true;
				c.sync(engine);
			//}
			// if the object was removed, let's restart again.
			// our lastFrame ensure that no object will get synched twice
			if( children[p] != c ) {
				p = 0;
				len = children.length;
			} else
				p++;
		}
	}

}