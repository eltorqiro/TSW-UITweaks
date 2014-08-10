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
    
	public function ScrollingListEnableDisableListItemRenderer()
    {
        super();

        m_IsConfigured = false;
    }
	private function configUI()
	{
		super.configUI();
        m_IsConfigured = true;
        UpdateVisuals();
	}
		
	public function setData(data:Object)
	{
        super.setData( data );

		icon.gotoAndStop( data.enabled ? 'enabled' : 'disabled' );
		
        if ( m_IsConfigured )
        {
            UpdateVisuals();
        }
    }

    private function UpdateVisuals()
    {
        if (data == undefined)
		{
			_visible = false;
			return;
		}
        else
		{
			_visible = true;
			
			textField.text = data.label;
			//textField.filters = [ new DropShadowFilter( 0, 90, 0x000000, 1, 4, 4, 3, 3, false, false, false ) ];
		}
    }
}