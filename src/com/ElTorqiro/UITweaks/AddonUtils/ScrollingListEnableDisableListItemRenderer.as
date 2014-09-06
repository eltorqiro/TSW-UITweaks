import flash.filters.DropShadowFilter;
import gfx.controls.ListItemRenderer;
import com.GameInterface.Utils;
import com.Utils.ID32;
import com.Utils.LDBFormat;

class com.ElTorqiro.UITweaks.AddonUtils.ScrollingListEnableDisableListItemRenderer extends ListItemRenderer
{
    private var textField:TextField;
	private var icon:MovieClip;
	private var m_IsConfigured:Boolean;
    
	public function ScrollingListEnableDisableListItemRenderer() {
        m_IsConfigured = false;
    }
	
	private function configUI():Void {
		super.configUI();

        m_IsConfigured = true;
        UpdateVisuals();
	}
		
	public function setData(data:Object):Void {
        super.setData( data );

		icon.gotoAndStop( data.plugin.enabled ? 'enabled' : 'disabled' );
		
        if ( m_IsConfigured ) {
            UpdateVisuals();
        }
    }

	private function UpdateVisuals():Void {

		visible = data != undefined;
		label = data.label;
    }
}