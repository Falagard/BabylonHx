package com.babylonhx.tools;

/**
 * ...
 * @author Krtolica Vujadin
 */

/**
 * The Observable class is a simple implementation of the Observable pattern.
 * There's one slight particularity though: a given Observable can notify its observer using a particular mask value, 
 * only the Observers registered with this mask value will be notified.
 * This enable a more fine grained execution without having to rely on multiple different Observable objects.
 * For instance you may have a given Observable that have four different types of notifications: 
 * Move (mask = 0x01), Stop (mask = 0x02), Turn Right (mask = 0X04), Turn Left (mask = 0X08).
 * A given observer can register itself with only Move and Stop (mask = 0x03), then it will only be notified when 
 * one of these two occurs and will never be for Turn Left/Right.
 */
class Observable<T> {	
	
	private var _numObserversMarkedAsDeleted = 0;
	private static var _pooledEventState:EventState = null;
	private var _observers:Array<Observer<T>>;
	
	
	public function new() {
		_observers = [];
	}

	/**
	 * Create a new Observer with the specified callback
	 * @param callback the callback that will be executed for that Observer
	 * @param insertFirst if true the callback will be inserted at the first position, hence executed before the others ones.
	 * If false (default behavior) the callback will be inserted at the last position, executed after all the others 
	 * already present.
	 */
	public function add(callback:T->Null<EventState>->Void, mask:Int = -1, insertFirst:Bool = false):Observer<T> {
		if (callback == null) {
			return null;
		}
		
		var observer = new Observer(callback, mask);
		
		if (insertFirst) {
            this._observers.unshift(observer);
        } 
		else {
            this._observers.push(observer);
        }
		
		return observer;
	}

	/**
	 * Remove an Observer from the Observable object
	 * @param observer the instance of the Observer to remove. If it doesn't belong to this Observable, false will be returned.
	 */
	public function remove(observer:Observer<T>, updateCounter = true):Bool {
		var index = this._observers.indexOf(observer);
		
		if (index != -1) {
			if (updateCounter) {
                this._numObserversMarkedAsDeleted--;
            }

			this._observers.splice(index, 1);
			
			return true;
		}
		
		return false;
	}

	/**
	 * Remove a callback from the Observable object
	 * @param callback the callback to remove. If it doesn't belong to this Observable, false will be returned.
	*/
	public function removeCallback(callback:T->Null<EventState>->Void):Bool {
		for (index in 0...this._observers.length) {
			if (this._observers[index].callback == callback) {
				this._observers.splice(index, 1);
				
				return true;
			}
		}
		
		return false;
	}

	// This should only be called when not iterating over _observers to avoid callback skipping.
	// Removes an observer from the _observer Array.
    private function _remove(observer: Observer<T>, updateCounter = true): Bool {
        if (observer == null) {
            return false;
        }

        var index = this._observers.indexOf(observer);

        if (index != -1) {
            if (updateCounter) {
                this._numObserversMarkedAsDeleted--;
            }
            this._observers.splice(index, 1);
            return true;
        }

        return false;
    }

	/**
     * Moves the observable to the top of the observer list making it get called first when notified
     * @param observer the observer to move
     */
	 public function makeObserverTopPriority(observer: Observer<T>) {
        this._remove(observer, false);
        this._observers.unshift(observer);
    }

    /**
     * Moves the observable to the bottom of the observer list making it get called last when notified
     * @param observer the observer to move
     */
    public  function makeObserverBottomPriority(observer: Observer<T>) {
        this._remove(observer, false);
        this._observers.push(observer);
    }

	/**
	 * Notify all Observers by calling their respective callback with the given data
	 * @param eventData
	 */
	public function notifyObservers(eventData:T, mask:Int = -1) {
		var state = Observable._pooledEventState != null ? Observable._pooledEventState.initalize(mask) : new EventState(mask);
        Observable._pooledEventState = null;
		
        for (obs in this._observers) {
            if (obs.mask & mask != 0) {
				obs.callback(eventData, state);
			}
			if (state.skipNextObservers) {
				break;
			}
        }
		
		Observable._pooledEventState = state;
	}
	
	/**
	 * return true is the Observable has at least one Observer registered
	 */
	public function hasObservers():Bool {
		return this._observers.length - this._numObserversMarkedAsDeleted > 0;
		// return this._observers.length > 0;
	}

	/**
	* Clear the list of observers
	*/
	public function clear() {
		this._observers = [];
		this._numObserversMarkedAsDeleted = 0;
	}
	
	/**
	* Clone the current observable
	*/
	public function clone():Observable<T> {
		var result = new Observable<T>();
		
		result._observers = this._observers.slice(0);
		
		return result;
	}
	
	/**
	 * Does this observable handles observer registered with a given mask
	 * @param mask defines the mask to be tested
	 * @return whether or not one observer registered with the given mask is handeled 
	**/
	public function hasSpecificMask(mask:Int = -1):Bool {
		for (obs in this._observers) {
			if (obs.mask & mask != 0 || obs.mask == mask) {
				return true;
			}
		}
		return false;
	}
	
}
