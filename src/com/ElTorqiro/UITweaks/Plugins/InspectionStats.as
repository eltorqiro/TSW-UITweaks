import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.ElTorqiro.UITweaks.Enums.States;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.ProjectUtils;
import com.Utils.GlobalSignal;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Faction;
import com.GameInterface.LoreBase;
import com.Utils.Colors;
import flash.filters.GlowFilter;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.ElTorqiro.UITweaks.Plugins.InspectionStats_.ContentBuilder;

class com.ElTorqiro.UITweaks.Plugins.InspectionStats extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _findMCThrashCount:Number = 0;

	// configurable settings
	private var _iconSize:Number = 25;
	private var _iconPadding:Number = 3;
	private var _gearOffset:Number = 10;
	private var _statSectionSpacing:Number = _iconPadding * 3;
	

	public function InspectionStats() {
		super();
		
		//AddonUtils.FindGlobalEnum( 'weapon' );
		
	}
	
	private function Activate() {
		super.Activate();
		
		// create listener
		GlobalSignal.SignalShowInspectWindow.Connect( AttachToWindow, this );
	}
	
	private function Deactivate() {
		super.Deactivate();

		// detach from listener
		GlobalSignal.SignalShowInspectWindow.Disconnect( AttachToWindow, this );
		
		Restore();
	}
	
	private function AttachToWindow( characterID:ID32 ):Void {
		
		// hack to wait for default window to finish rendering
		_global.setTimeout( Delegate.create( this, Attach ), 200, characterID );
	}
	
	
	private function Attach( characterID:ID32 ):Void {

		var inspectionWindowContent = _root.inspectioncontroller.m_InspectionWindows[characterID].m_Content;
		
		// don't re-render if already done so
		if( inspectionWindowContent.UITweaksContentBuilder == undefined ) {
			inspectionWindowContent.UITweaksContentBuilder = new ContentBuilder( _root.inspectioncontroller.m_InspectionWindows[characterID].m_Content );
		}
	}	
	
	private function Restore():Void {
/*
		try {
		
			var windows:Array = _root.inspectioncontroller.m_InspectionWindows;
			
			for( var i:String in windows ) {
				
				var content:MovieClip = windows[i].m_Content;
				
				content.m_StatInfoList._visible = true;
				content.m_StatsBgBox._visible = true;
			}
			
		}
		
		catch (e) {
			
		}
*/
	}

}