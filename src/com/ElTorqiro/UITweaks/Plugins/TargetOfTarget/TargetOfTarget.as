import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.PluginWrapper;
import com.GameInterface.Game.Character
import com.Utils.ID32;
import gfx.controls.TextArea;
import GUIFramework.ClipNode;
import GUIFramework.SFClipLoader;
import com.Components.HealthBar;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:Character;
	private var _offensiveTargetOfTarget:Character;
	private var _defensiveTargetOfTarget:Character;
	private var offtot:ClipNode;
	private var defftot:ClipNode;
	private var m_OFFHealthBar:HealthBar;
	private var m_DEFFHealthBar:HealthBar;
	private var m_DragProxy:MovieClip;
	private var _dragObjects:Array;

	public function TargetOfTarget(wrapper:PluginWrapper) {
		super(wrapper);
	}

	private function Activate() {
		super.Activate();
		
		_character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);
		offtot = SFClipLoader.LoadClip( 'ElTorqiro_UITweaks/plugins/TargetOfTarget/TOTDisplay.swf', 'TOTDisplay_Offensive', false, 3, 2);
		offtot.SignalLoaded.Connect( OFFClipLoaded, this );
		defftot = SFClipLoader.LoadClip( 'ElTorqiro_UITweaks/plugins/TargetOfTarget/TOTDisplay.swf', 'TOTDisplay_Deffensive', false, 3, 2);
		defftot.SignalLoaded.Connect(Layout, this);
	}

	private function Deactivate() {
		super.Deactivate();
		_character.SignalOffensiveTargetChanged.Disconnect(UserTargetChanged, this);
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		}
		offtot.m_Movie.UnloadClip();
		defftot.m_Movie.UnloadClip();
	}
	
	
	function OFFClipLoaded():Void {
		
		UserTargetChanged();
		ClearCharacter();
		Layout();
	}
	
	
	private function UserTargetChanged():Void {
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		} else {
			ClearCharacter();
		}
		_target = Character.GetCharacter( _character.GetOffensiveTarget() );
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		_target.SignalDefensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		TargetOfTargetDisplay();
	}
   
	private function TargetOfTargetDisplay():Void 
	{
		_offensiveTargetOfTarget = Character.GetCharacter( _target.GetOffensiveTarget() );
		_defensiveTargetOfTarget = Character.GetCharacter( _target.GetDefensiveTarget() );
			
		if ( _offensiveTargetOfTarget != undefined ) {
			m_OFFHealthBar = HealthBar(offtot.m_Movie.m_HealthBar);
			m_OFFHealthBar.SetCharacter(_offensiveTargetOfTarget);
			offtot.m_Movie.m_NameBox.i_NameField.text = _offensiveTargetOfTarget.GetName();
			if ( offtot.m_Movie._visible == false) offtot.m_Movie._visible = true;
		} else {
			ClearCharacter();
		}
		
		if ( _defensiveTargetOfTarget != undefined ){
			UtilsBase.PrintChatText("DEFFTOT: " + _defensiveTargetOfTarget.GetName());
			
			m_DEFFHealthBar = HealthBar(defftot.m_Movie.m_HealthBar);
			m_DEFFHealthBar.SetCharacter(_defensiveTargetOfTarget);
			defftot.m_Movie.m_NameBox.i_NameField.text = _defensiveTargetOfTarget.GetName();
			if ( defftot.m_Movie._visible == false) defftot.m_Movie._visible = true;
			
		}else {
			ClearCharacerDEFF();
		}
	}

	private function ClearCharacter():Void {
		//set to true for debug
		offtot.m_Movie._visible = true;
		defftot.m_Movie._visible = true;
		
		_offensiveTargetOfTarget = undefined;
		m_OFFHealthBar.SetCharacter(_offensiveTargetOfTarget);
		offtot.m_Movie.m_NameBox.i_NameField.text = "";
		ClearCharacerDEFF();
	}
	
	private function ClearCharacerDEFF():Void {
		//Commented For Debug
		//defftot.m_Movie._visible = false;
		_defensiveTargetOfTarget = undefined;
		m_DEFFHealthBar.SetCharacter(_defensiveTargetOfTarget);
		defftot.m_Movie.m_NameBox.i_NameField.text = "";
	}
	/**
	 * 
	 * Testing Making It Movable
	 * 
	 * */
	
	private function Layout():Void {
		offtot.m_Movie._x = defftot.m_Movie._x = 5; 
		offtot.m_Movie._y = 20;
		defftot.m_Movie._y = offtot.m_Movie._y + offtot.m_Movie._height;
		offtot.m_Movie._xscale = offtot.m_Movie._yscale = 65;
		defftot.m_Movie._xscale = defftot.m_Movie._yscale = 65;
		}

	private function DragStartHandler(event:Object):Void {

		m_DragProxy = m_DragProxy.createEmptyMovieClip("m_DragProxy", m_DragProxy.getNextHighestDepth());
		_dragObjects = [ offtot.m_Movie, defftot.m_Movie ];
		m_DragProxy.onMouseMove = DragMovementHandler;
		m_DragProxy.startDrag();
		
	}
	
	private function DragMovementHandler():Void {
		
		for ( var i:Number = 0; i < _dragObjects.length; i++ ) {
			
			var moveObject:MovieClip = _dragObjects[i];
			moveObject._x += m_DragProxy._x - m_DragProxy._prevX;
			moveObject._y += m_DragProxy._y - m_DragProxy._prevY;
			
		}
		
		m_DragProxy._prevX = m_DragProxy._x;
		m_DragProxy._prevY = m_DragProxy._y;		
	}
	
	private function DragEndHandler(event:Object):Void {

		_dragObjects = undefined;
		
		m_DragProxy.onMouseMove = undefined;
		m_DragProxy.stopDrag();
		m_DragProxy.unloadMovie();
		m_DragProxy.removeMovieClip();
	}
}