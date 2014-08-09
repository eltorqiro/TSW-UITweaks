import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.GameInterface.Game.Character
import com.Utils.ID32;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import com.Components.HealthBar;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:Character;
	private var _offensiveTargetOfTarget:Character;
	private var _defensiveTargetOfTarget:Character;
	private var clipNode:ClipNode;
	public var m_HealthBar:HealthBar;
	
	public function TargetOfTarget() {
		super();
	}

	private function Activate() {
		super.Activate();
		
		_character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);
		
		clipNode = SFClipLoader.LoadClip( 'ElTorqiro_UITweaks/TOTDisplay.swf', 'AAA_TOTDisplay', false, 3, 2);
		clipNode.SignalLoaded.Connect( ClipLoaded, this );
		
	}

	private function Deactivate() {
		super.Deactivate();
		
		_character.SignalOffensiveTargetChanged.Disconnect(UserTargetChanged, this);
	    
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		}
		clipNode.m_Movie.UnloadClip();
	}
	
	
	function ClipLoaded():Void {
		
		UserTargetChanged();
		//OffensiveHeathBar(3, 12);
		
		clipNode.m_Movie._x = 5; 
		clipNode.m_Movie._y = 20;
		
		ClearCharacter();
		
	}
	
	
	private function UserTargetChanged():Void {
		
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		}else {
			ClearCharacter();
		}

		_target = Character.GetCharacter( _character.GetOffensiveTarget() );
		
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		_target.SignalDefensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		
		TargetOfTargetDisplay();
		
		/**
		* Debug: Just Uncomment The Following CMD
		**/
			//UtilsBase.PrintChatText("My Target: " + _target.GetName());

	}
   
	private function TargetOfTargetDisplay():Void 
	{
		_offensiveTargetOfTarget = Character.GetCharacter( _target.GetOffensiveTarget() );
		_defensiveTargetOfTarget = Character.GetCharacter( _target.GetDefensiveTarget() );
			
		if ( _offensiveTargetOfTarget != undefined ) {
			UtilsBase.PrintChatText("OFFTOT: " + _offensiveTargetOfTarget.GetName());
			
			//m_HealthBar = attachMovie("HealthBar2", "aaa_tot_health", clipNode.m_Movie.getNextHighestDepth());
			//m_HealthBar.SetTextType(com.Components.HealthBar.STATTEXT_NUMBER);
			
			m_HealthBar.SetCharacter(_offensiveTargetOfTarget);
			clipNode.m_Movie._visible = true;

		} else {
			ClearCharacter();
		}
		
		if ( _defensiveTargetOfTarget != undefined ){
			UtilsBase.PrintChatText("DEFFTOT: " + _defensiveTargetOfTarget.GetName());
		}
	}

	
	
	private function ClearCharacter():Void {
		_offensiveTargetOfTarget = undefined;
		m_HealthBar.SetCharacter(_offensiveTargetOfTarget);
		clipNode.m_Movie._visible = false
		
	}
	
}