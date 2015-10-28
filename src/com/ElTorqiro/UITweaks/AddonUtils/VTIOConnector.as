import com.Utils.Signal;
import com.GameInterface.DistributedValue;


/**
 * Provides a convenient wrapper for VTIO registration functionality, which can be used in as little as a single line in an addon
 * 
 */
class com.ElTorqiro.UITweaks.AddonUtils.VTIOConnector {
	
	public function VTIOConnector( id:String, author:String, version:String, dv:String, icon:MovieClip, callback:Function ) {
		
		VTIOIsLoadedMonitor = DistributedValue.Create( "VTIO_IsLoaded" );
		
		SignalAddonRegistered = new Signal();
		
		if ( id != undefined ) {
			register( id, author, version, dv, icon, callback );
		}
	}
	
	/**
	 * registers addon with VTIO
	 * will delay registration until VTIO is ready, if necessary
	 * 
	 * SignalAddonRegistered is emitted, and the callback function is called, once registration is complete
	 * 
	 * @param	id			addon id, passed to VTIO
	 * @param	author		addon author, passed to VTIO
	 * @param	version		addon version string, passed to VTIO
	 * @param	dv			name of distributed value which toggles the addon active state, passed to VTIO
	 * @param	icon		optional; reference to MovieClip containing the app icon VTIO will duplicate for its topbar slot
	 * @param	callback	optional; callback function to call when registration has occurred
	 */
	public function register( id:String, author:String, version:String, dv:String, icon:MovieClip, callback:Function ) : Void {

		this.id = id;
		this.author = author;
		this.version = version;
		this.dv = dv;
		this.icon = icon;
		this.callback = callback;

		VTIOIsLoadedMonitor.SignalChanged.Connect( doRegistration, this );
		
		doRegistration();
	}

	/**
	 * attempts to register addon with VTIO
	 */
	private function doRegistration( param ) : Void {

		if ( !VTIOIsLoaded || isRegistered ) return;

		VTIOIsLoadedMonitor.SignalChanged.Disconnect( doRegistration, this );

		DistributedValue.SetDValue( "VTIO_RegisterAddon", id + "|" + author + "|" + version + "|" + dv + "|" + icon.toString() );
		_isRegistered = true;

		this.callback();
		
		SignalAddonRegistered.Emit( id );
	}
	

	/*
	 * internal variables
	 */

	private var VTIOIsLoadedMonitor:DistributedValue;	

	
	/*
	 * properties
	 */
	
	public var id:String;
	public var author:String;
	public var version:String;
	public var dv:String;
	public var icon:MovieClip;
	public var callback:Function;
	 
	public var SignalAddonRegistered:Signal;

	public function get VTIOIsLoaded() : Boolean {
		return Boolean( VTIOIsLoadedMonitor.GetValue() );
	}
	
	private var _isRegistered:Boolean = false;
	public function get isRegistered() : Boolean {
	
		// TODO: can this method work?
		//_root.viper_topbarinformationoverload.m_AddonList[ id ] != undefined
		
		return _isRegistered;
	}
	
	/**
	 * the layer and depth that VTIO icons have to be in so they appear correctly in VTIO
	 */
	public static var e_VtioDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerTop;
	public static var e_VtioSubDepth:Number = 2;
}