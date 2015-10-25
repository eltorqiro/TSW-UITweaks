
/**
 * shared constants used throughout the app
 * 
 */
class com.ElTorqiro.UITweaks.Const {
	
	// static class only, cannot be instantiated
	private function Const() { }

	// app information
	public static var AppID:String = "ElTorqiro_UITweaks";
	public static var AppName:String = "UITweaks";
	public static var AppAuthor:String = "ElTorqiro";
	public static var AppVersion:String = "1.0.0";
	
	public static var PrefsVersion:Number = 10000;
	
	public static var IconClipPath:String = "ElTorqiro_UITweaks\\Icon.swf";
	public static var IconClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerMiddle;
	public static var IconClipSubDepth:Number = 0;
	
	public static var ConfigWindowClipPath:String = "ElTorqiro_UITweaks\\ConfigWindow.swf";
	public static var ConfigWindowClipDepthLayer:Number = _global.Enums.ViewLayer.e_ViewLayerTop;
	public static var ConfigWindowClipSubDepth:Number = 0;
	
	public static var PrefsName:String = "ElTorqiro_UITweaks_Preferences";
	
	public static var ShowConfigWindowDV:String = "ElTorqiro_UITweaks_ShowConfigWindow";
	public static var DebugModeDV:String = "ElTorqiro_UITweaks_Debug";
	
	public static var MinIconScale:Number = 30;
	public static var MaxIconScale:Number = 200;
	
}