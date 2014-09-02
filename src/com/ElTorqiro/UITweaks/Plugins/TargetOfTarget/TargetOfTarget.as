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
import mx.utils.Delegate;
import gfx.core.UIComponent;

class com.ElTorqiro.UITweaks.Plugins.TargetOfTarget.TargetOfTarget extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _character:Character;
	private var _target:Character;
	private var _offensiveTargetOfTarget:Character;
	private var _defensiveTargetOfTarget:Character;
	
	// offensive & defensive panels
	private var m_Offensive:MovieClip;
	private var m_Defensive:MovieClip;
	

	//Stuff For Moving
	private var m_DragProxy:MovieClip;
	private var _dragObjects:Array;
	
	private var _dragging:Boolean = false;
	private var _mouseDown:Number = -1;

	// behaviour modifier keys
	public var dualDragModifier:Number = Key.CONTROL;
	public var dualDragButton:Number = 0;

	public var singleDragModifier:Number = Key.CONTROL;
	public var singleDragButton:Number = 1;

	
	public function TargetOfTarget(wrapper:PluginWrapper) {
		super(wrapper);
	}

	private function Activate() {
		super.Activate();
		
		_character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);
		
		m_Offensive = _wrapper.mc.attachMovie( 'totPanel', 'm_Offensive', _wrapper.mc.getNextHighestDepth() );
		m_Defensive = _wrapper.mc.attachMovie( 'totPanel', 'm_Defensive', _wrapper.mc.getNextHighestDepth() );

		m_Offensive.onClick = function() {
			UtilsBase.PrintChatText( 'offensive onClick' );
		};
		
		m_Defensive.onClick = function() {
			UtilsBase.PrintChatText( 'defensive onClick' );
		};
		
		UserTargetChanged();
		Layout();

		SetupGlobalMouseHandlers( m_Offensive );
		SetupGlobalMouseHandlers( m_Defensive );
	}

	private function Deactivate() {
		super.Deactivate();
		_character.SignalOffensiveTargetChanged.Disconnect(UserTargetChanged, this);
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		}
	}
	
	
	private function UserTargetChanged():Void {
		if ( _target != undefined ) {
			_target.SignalOffensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
			_target.SignalDefensiveTargetChanged.Disconnect( TargetOfTargetDisplay, this );
		}
		
		_target = Character.GetCharacter( _character.GetOffensiveTarget() );
		_target.SignalOffensiveTargetChanged.Connect(TargetOfTargetDisplay, this);
		_target.SignalDefensiveTargetChanged.Connect(TargetOfTargetDisplay, this);

		TargetOfTargetDisplay();
	}

	
	private function TargetOfTargetDisplay():Void {
		
		_offensiveTargetOfTarget = Character.GetCharacter( _target.GetOffensiveTarget() );
		UpdatePanel( m_Offensive, _offensiveTargetOfTarget );
		
		_defensiveTargetOfTarget = Character.GetCharacter( _target.GetDefensiveTarget() );
		UpdatePanel( m_Defensive, _defensiveTargetOfTarget );
	}
	
	private function UpdatePanel(panel:MovieClip, character:Character):Void {
			
		if ( character != undefined ) {
			
			HealthBar( panel.m_HealthBar ).SetCharacter( character );
			panel.m_NameBox.i_NameField.text = character.GetName();
			panel._visible = true;
		}
		
		else {
			panel._visible = false;
		}
		
	}
	
	
	private function Layout():Void {

		//m_Offensive._xscale = m_Offensive._yscale = m_Defensive._xscale = m_Defensive._yscale = 65;
		
		m_Offensive._x = m_Defensive._x = 5; 
		m_Offensive._y = m_Defensive._y + m_Defensive._height;
	}

	
	private function DragStartHandler(clips:Array):Void {

		m_DragProxy = _wrapper.mc.createEmptyMovieClip("m_DragProxy", _wrapper.mc.getNextHighestDepth());
		_dragObjects = clips;
		m_DragProxy.onMouseMove = Delegate.create( this, DragMovementHandler );
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
	
	private function DragEndHandler():Void {

		_dragObjects = undefined;
		
		m_DragProxy.onMouseMove = undefined;
		m_DragProxy.stopDrag();
		m_DragProxy.unloadMovie();
		m_DragProxy.removeMovieClip();
	}
	
	private function SetupGlobalMouseHandlers(mc:MovieClip) {
		
		if ( !mc ) return;
		
		mc.onPress = mc.onPressAux = Delegate.create(this, handleMousePress);
		mc.onRelease = mc.onReleaseAux = Delegate.create(this, handleMouseRelease);
		mc.onReleaseOutside = mc.onReleaseOutsideAux = Delegate.create(this, handleReleaseOutside);
	}

	private function getClickedPanel():MovieClip {
		if ( m_Offensive.hitTest(_root._xmouse, _root._ymouse, true, true) ) return m_Offensive;
		else return m_Defensive;
	}
	
	private function handleMousePress(controllerIdx:Number, keyboardOrMouse:Number, button:Number):Void {

		// only allow one mouse button to be pressed at once
		if ( _mouseDown != -1 ) return;
		_mouseDown = button;
		
		// TODO: check if no modifiers held down, and only fire click if that is the case, otherwise fire appropriate start drag etc
		if ( Key.isDown( dualDragModifier ) && button == dualDragButton ) {
			_dragging = true;
			DragStartHandler( [ m_Offensive, m_Defensive ] );
		}
		
		else if ( Key.isDown( singleDragModifier ) && button == singleDragButton ) {
			_dragging = true;
			DragStartHandler( [ getClickedPanel() ] );
		}
		
		else {
			getClickedPanel().onClick();
		}
		
	}
	
	private function handleMouseRelease(controllerIdx:Number, keyboardOrMouse:Number, button:Number):Void {
		// only propogate if the release is associated with the originally held down button
		if ( _mouseDown != button ) return;
		_mouseDown = -1;

		DragEndHandler();
	}
	
	private function handleReleaseOutside(controllerIdx:Number, button:Number):Void {
		handleMouseRelease(controllerIdx, 0, button);
	}
}