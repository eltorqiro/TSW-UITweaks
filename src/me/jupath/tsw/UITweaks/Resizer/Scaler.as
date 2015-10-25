import com.GameInterface.DistributedValue;
import com.Utils.Signal;
import mx.utils.Delegate;
import com.ElTorqiro.UITweaks.AddonUtils.WaitFor;

//To override the private method MoveDragHandler and have 'this' references function correctly, need to extend WinComp.
class me.jupath.tsw.UITweaks.Resizer.Scaler extends com.Components.WinComp {

	private var waitForId:Number;
	private var _dv:DistributedValue;
	private var _signal:Signal;
	private var _windowName:String;
	private var _zoom:Boolean;
	private var _scale:Number;
	private var _delay:Number;

	public function Scaler(dv:DistributedValue, signal:Signal, windowName:String, zoom:Boolean) {
		_dv = dv;
		_signal = signal;
		if (_signal == null && _dv != null) _signal = _dv.SignalChanged;
		_windowName = windowName;
		_zoom = zoom;
		_scale = 100;
	}
	
	public function Activate():Void {
		if (_signal != null) _signal.Connect(DoScale, this);
		DoScale();
	}

	public function Deactivate():Void {
		if (_signal != null) _signal.Disconnect(DoScale, this);
		if ((_dv == null || _dv.GetValue() == true) && _root[_windowName] != undefined) {
			UnscaleWindow(_root[_windowName]);
		}
	}
	
	private function ScaleWindow(window, scale:Number):Void {
		var mWindow = window.m_Window;
		if (mWindow != undefined) {
			//Keep top left corner of content in the same place
			mWindow._x = (mWindow._x * window._xscale / 100.0) * (1.0 / (scale / 100.0));
			mWindow._y = (mWindow._y * window._yscale / 100.0) * (1.0 / (scale / 100.0));
			//Override the positioning restrictions to fit the new scale
			mWindow.m_Background.onPress = Delegate.create(mWindow, MoveDragHandlerOverride);
		}
		//Adjust scale
		window._xscale = window._yscale = scale;
	}
	private function UnscaleWindow(window):Void {
		var mWindow = window.m_Window;
		if (mWindow != undefined) {
			//Keep top left corner of content in the same place
			mWindow._x = mWindow._x * window._xscale / 100.0;
			mWindow._y = mWindow._y * window._yscale / 100.0;
			//Remove the positioning override
			mWindow.m_Background.onPress = Delegate.create(mWindow, MoveDragHandler);
		}
		//Undo scale
		window._xscale = window._yscale = 100;
		//Undo zoom
		window._x = window._y = 0;
	}
	private function ZoomWindow(window, scale:Number):Void {
		//Keep center of stage in the same place
		var visibleRect:Object = Stage["visibleRect"];
		window._x = (visibleRect.width - (visibleRect.width * scale / 100)) / 2;
		window._y = (visibleRect.height - (visibleRect.height * scale / 100)) / 2;
		//Adjust scale
		window._xscale = window._yscale = scale;
	}
	
	//Same as the original method except for the last two arguments to startDrag
	private function MoveDragHandlerOverride():Void {
		if (m_IsDraggable) {
			if (!Mouse["IsMouseOver"](m_Content)) {
				SignalSelected.Emit(this);
				var visibleRect = Stage["visibleRect"];
				this.startDrag (false,
					0 - this._width + DRAG_PADDING - m_DropShadow._x,
					0 - this._height + DRAG_PADDING - m_DropShadow._y,
					(visibleRect.width * (1.0 / (_parent._xscale / 100))) - DRAG_PADDING,
					(visibleRect.height * (1.0 / (_parent._yscale / 100))) - DRAG_PADDING
				);
			}
		}
	}

	private function DoScale():Void {
		if (_dv == null || _dv.GetValue() == true) {
			waitForId = WaitFor.start( Delegate.create(this, waitForWindow), 10, 2000, Delegate.create(this, Scale) );
		}
	}
	
	private function waitForWindow():Boolean {
		return _root[_windowName];
	}
	
	public function stopWaitFor() : Void {
		WaitFor.stop( waitForId );
		waitForId = undefined;
	}

	private function Scale():Void {
		stopWaitFor();

		var window = _root[_windowName];
		if (window != undefined) {
			if (_zoom) ZoomWindow(window, _scale);
			else ScaleWindow(window, _scale);
		}
	}
	
	public function get scale():Number { return _scale };
	public function set scale(value:Number):Void {
		if ( value == undefined ) return;
		_scale = value;
		DoScale();
	}
	
}
