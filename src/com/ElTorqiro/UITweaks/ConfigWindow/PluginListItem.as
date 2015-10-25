import gfx.controls.ListItemRenderer;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.ConfigWindow.PluginListItem extends ListItemRenderer {

	public function PluginListItem() {

    }
	
	public function configUI() : Void {
		super.configUI();
		
		addEventListener( "doubleClick", this, "togglePlugin" );
		addEventListener( "stateChange", this, "updateIcon" );
	}
	
	public function setData( data:Object ) : Void {
        super.setData( data );
		updateIcon();
    }

	private function togglePlugin( event:Object ) : Void {
		data.enabled = !data.enabled;
	}
	
	private function updateIcon() : Void {
		if ( state == "over" || state == "up" ) {
			icon.gotoAndStop( (selected ? "selected_" : "") + (data.enabled ? "enabled" : "disabled") );
		}
	}
	
	/**
	 * properties
	 */
	
	public var icon:MovieClip;
}