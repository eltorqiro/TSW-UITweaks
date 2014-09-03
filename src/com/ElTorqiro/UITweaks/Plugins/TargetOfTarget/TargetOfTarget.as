import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.PluginWrapper;
import com.GameInterface.Game.Character;
import com.Utils.Archive;
import com.Utils.ID32;
import com.Components.HealthBar;
import mx.utils.Delegate;
import gfx.core.UIComponent;
import com.GameInterface.Game.TargetingInterface;
import flash.geom.Point;

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
	
	//Setting Varables
	private var _showDefTargetWindow:Boolean;
	private var _showOffTargetWindow:Boolean;
	
	public function TargetOfTarget(wrapper:PluginWrapper) {
		super(wrapper);
	}

	private function Activate() {
		super.Activate();
		
		//Get Settings
		_showDefTargetWindow = true; //settings.FindEntry( 'showDefTarget', true );
		_showOffTargetWindow = true; //settings.FindEntry( 'showOffTarget', true );
		
		
		_character = Character.GetClientCharacter();
		_character.SignalOffensiveTargetChanged.Connect(UserTargetChanged, this);

		m_Offensive = _wrapper.mc.attachMovie( 'totPanel', 'm_Offensive', _wrapper.mc.getNextHighestDepth() );
		m_Defensive = _wrapper.mc.attachMovie( 'totPanel', 'm_Defensive', _wrapper.mc.getNextHighestDepth() );

		m_Offensive.m_HealthBar.UserTargetChanged = m_Defensive.m_HealthBar.UserTargetChanged = Delegate.create( this, UserTargetChanged );
		
		m_Offensive.m_HealthBar.onLoad = m_Defensive.m_HealthBar.onLoad = function() {
			
			this.SetBarScale( 100, 100, undefined, 80 );
	
			this._parent.m_Background._width = this._x + this._width + 5;
			this._parent.m_NameBox.i_NameField.autoSize = 'left';
			
			this.UserTargetChanged();
		};
		
		m_Offensive.m_Icon.gotoAndStop( 'offensive' );
		m_Defensive.m_Icon.gotoAndStop( 'defensive' );
		
		m_Offensive.onClick = Delegate.create( this, function() {
			if ( _offensiveTargetOfTarget != undefined ) {
				TargetingInterface.SetTarget( _offensiveTargetOfTarget.GetID() );
			}
		});
		
		m_Defensive.onClick = Delegate.create( this, function() {
			if ( _defensiveTargetOfTarget != undefined ) {
				TargetingInterface.SetTarget( _defensiveTargetOfTarget.GetID() );
			}
		});

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
	
		var settings:Archive = new Archive();
		
		settings.AddEntry( "offSaveLocation", new Point( m_Offensive._x, m_Offensive._y));
		settings.AddEntry( "defSaveLocation", new Point( m_Defensive._x, m_Defensive._y));
		settings.AddEntry( "showDefTarget", _showDefTargetWindow);
		settings.AddEntry( "showOffTarget", _showOffTargetWindow);
		
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
			
			panel._visible = (panel == m_Offensive && _showOffTargetWindow) || (panel == m_Defensive && _showDefTargetWindow);
		}
		else {
			panel._visible = false;
		}
		
	}
	
	
	private function Layout():Void {
		/**
		 * Store For Later If We Decide To Make
		 * It Shrink Horizontally
		 *
		
		 //this.m_Bar._width *= 0.5;
		this.m_ShieldBar._width *= 0.5;
		
		//this.PositionUpcomingShields(this.m_ShieldsOnTop);
		this.PositionUpcomingShields = undefined;

		this.m_SecondShield._x = this.m_ShieldBar._x + this.m_ShieldBar._width + 5;
		this.m_ThirdShield._x = this.m_SecondShield._x + this.m_SecondShield._width + 2;
		*/
		m_Offensive._x = m_Defensive._x = 5; 
		m_Defensive._y = m_Offensive._y + m_Offensive._height;
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