//Imports
import flash.filters.DropShadowFilter;
import flash.geom.Point;
import gfx.core.UIComponent;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import flash.geom.Rectangle;
import mx.data.encoders.Bool;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Game.Character;

import com.GameInterface.UtilsBase;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;


class com.ElTorqiro.UITweaks.AddonUtils.Window extends UIComponent
{
	// constants
	public static var MINHEIGHT:Number = 150;
	public static var MINWIDTH:Number = 150;
	
    // internal movieclips
    private var m_Title:TextField;
    private var m_Content:WindowComponentContent;
    private var m_ResizeButton:MovieClip;	// Button
    private var m_TopFade:MovieClip;
	private var m_Footer:MovieClip;
    private var m_Background:MovieClip;
    private var m_DropShadow:MovieClip;
    private var m_CloseButton:Button;
	private var m_HelpButton:Button;
	
    // properties
    public var SignalClose:Signal;
    public var SignalSizeChanged:Signal;
    public var SignalSelected:Signal;
	public var SignalContentLoaded:Signal;

    private var _padding:Number;
	
    private var _minHeight:Number;
    private var _minWidth:Number;
    
    private var _maxHeight:Number;
    private var _maxWidth:Number;

    public  var resizeSnap:Number;

	public  var isDraggable:Boolean;

	private var _showCloseButton:Boolean;
	private var _showHelpButton:Boolean;
	private var _showFooter:Boolean;
	private var _showResizeHandle:Boolean;
	private var _showTopFade:Boolean;
	private var _showTitle:Boolean;
	
	private var _showTitleShadow:Boolean;
	private var _showButtonShadow:Boolean;
	private var _showWindowShadow:Boolean;
	
	private var _titleColour:Number;
	private var _topFadeColour:Number;

	// internal properties
	private var _windowButtonSpacing:Number;
    private var _dragSafetyPadding:Number;

	// utility objects
    private var _resizeListener:Object;
    private var _resizeWidth:Number;
	private var _resizeHeight:Number;
	private var _resizeGrabOffset:Point;
	private var _resizing:Boolean;

    private var _nonContentHeight:Number;

    // constructor
    public function Window() {
        
        SignalClose = new Signal();
        SignalSizeChanged = new Signal();
        SignalSelected = new Signal();
		SignalContentLoaded = new Signal();
        
        resizeSnap = 1;
        _maxHeight = -1;
        _maxWidth = -1;
        minHeight = -1;
        minWidth = -1;
        
        isDraggable = true;  
		
		_padding = 10;
		
		showCloseButton = true;
		showHelpButton = true;
		showResizeHandle = true;
		showFooter = true;
		showTopFade = true;
		
		showTitle = true;
		
		showTitleShadow = true;
		showButtonShadow = true;
		showWindowShadow = true;
		
		titleColour = 0xccff;
		topFadeColour = 0x003366;
		
		_windowButtonSpacing = 5;
		_dragSafetyPadding = 100;
    }
    
    //On Load
    private function configUI():Void {
		super.configUI();
		
        m_ResizeButton.onPress = Delegate.create(this, ResizeDragHandler);
		m_ResizeButton.onRollOver = Delegate.create( this, ResizeRollOverHandler );
		m_ResizeButton.onRollOut = Delegate.create( this, ResizeRollOutHandler );
		m_ResizeButton.disableFocus = true;

        m_Background.onPress =  Delegate.create(this, MoveDragHandler);
        m_Background.onRelease = m_Background.onReleaseOutside = 
		m_Background.onReleaseAux = m_Background.onReleaseOutsideAux = Delegate.create(this, MoveDragReleaseHandler);
        
        m_CloseButton.addEventListener("click", this, "CloseButtonHandler");
        m_CloseButton.disableFocus = true;
		
		m_HelpButton.disableFocus = true;
    }
    
	// draw elements after a validateNow()
	private function draw():Void {
		
	}
	
    //Layout
    public function Layout():Void {
		
        var contentSize:Point = m_Content.GetSize();
		
        m_Content._x = m_Background._x + _padding;
        m_Background._width = m_Content._x + contentSize.x + _padding;
        
        if (m_Title.text == "" || m_Title == undefined) {
            m_Background._height = contentSize.y + _padding * 2;
            m_Content._y = m_Background._y + _padding;
            _nonContentHeight = m_Background._y + _padding * 2;
        }
		
        else {
			m_Title._x = _padding;
			m_Title._y = 3;
            m_Title._width = m_Background._width - _padding * 2;
            m_Content._y = Math.round(m_Title._y + m_Title._height) + _padding;
            m_Background._height = m_Content._y + contentSize.y + _padding ;
			_nonContentHeight = m_Content._y + _padding;
        }
        
		m_TopFade._width = m_Background._width;

		m_Footer._width = m_Background._width;
		m_Footer._y = m_Background._height - m_Footer._height;
		
        m_DropShadow._width = m_Background._width + 31;
        m_DropShadow._height = m_Background._height + 31;

        m_ResizeButton._x = m_Background._x + m_Background._width - m_ResizeButton._width;
        m_ResizeButton._y = m_Background._y + m_Background._height - m_ResizeButton._height;
        
		layoutButtons();
    }
	
    private function CloseButtonHandler():Void {
		var character:Character = Character.GetClientCharacter();
		if (character != undefined) { character.AddEffectPackage( "sound_fxpackage_GUI_click_tiny.xml" ); }
        SignalClose.Emit(this);
        m_Content.Close();
    }

    private function ResizeRollOverHandler():Void {
		if( !_resizing ) m_ResizeButton.gotoAndPlay( 'over' );
	}
	
	private function ResizeRollOutHandler():Void {
		if( !_resizing ) m_ResizeButton.gotoAndPlay( 'up' );
	}
	
    //Resize Drag Handler
    private function ResizeDragHandler():Void {
		if ( _resizing ) return;
		
		_resizing = true;
		m_ResizeButton.gotoAndPlay( 'down' );
		
		_resizeGrabOffset = new Point( m_Background._width - this._xmouse, m_Background._height - this._ymouse );
		
        _resizeListener = {};
        _resizeListener.onMouseMove = Delegate.create( this, MouseResizeMovingHandler );
		_resizeListener.onMouseUp = Delegate.create( this, ResizeDragReleaseHandler );
        
        Mouse.addListener(_resizeListener); 
    }
    
    //Mouse Resize Moving Handler
    private function MouseResizeMovingHandler():Void {	

		_resizeWidth = this._xmouse + _resizeGrabOffset.x;
		_resizeHeight = this._ymouse + _resizeGrabOffset.y;
		
		/*
		_resizeWidth = Math.max(this._xmouse + _resizeGrabOffset.x, _minWidth);
		_resizeHeight = Math.max(this._ymouse + _resizeGrabOffset.y, _minHeight);
        
        if (_maxWidth > 0) _resizeWidth = Math.min(_maxWidth, _resizeWidth);
        if (_maxHeight > 0) _resizeHeight = Math.min(_maxHeight, _resizeHeight);
        */
		
        var xdiff:Number = Math.abs(m_Background._width - _resizeWidth);
        var ydiff:Number = Math.abs(m_Background._height - _resizeHeight);
        
		if (xdiff > resizeSnap || ydiff > resizeSnap) {
			SetSize(_resizeWidth, _resizeHeight);
        }
    }
    
    //Resize Drag Release
    private function ResizeDragReleaseHandler():Void {
        Mouse.removeListener(_resizeListener);
		SetSize(_resizeWidth, _resizeHeight);
		
		if (Mouse["IsMouseOver"](m_ResizeButton)) {
			m_ResizeButton.gotoAndPlay( 'over' );
		}
		
		else {
			m_ResizeButton.gotoAndPlay( 'up' );
		}
        
        _resizeListener = undefined;
		_resizing = false;
    }
    
    // Move Drag Handler
    private function MoveDragHandler():Void {
        if (isDraggable)
        {
            if (!Mouse["IsMouseOver"](m_Content))
            {
                SignalSelected.Emit(this);
                
                var visibleRect = Stage["visibleRect"];

                this.startDrag  (
					false,
					0 - this._width + _dragSafetyPadding - m_DropShadow._x,
					0 - this._height + _dragSafetyPadding - m_DropShadow._y,
					visibleRect.width - _dragSafetyPadding,
					visibleRect.height - _dragSafetyPadding
                );        
            }
        }
    }
    
    //Move Drag Release
    private function MoveDragReleaseHandler():Void {
        this.stopDrag();
    }
    
    //Set Size
    public function SetSize(width:Number, height:Number):Void {
		var resizeWidth:Number = Math.max( width, _minWidth );
		var resizeHeight:Number = Math.max( height, _minHeight );

        if (_maxWidth > 0) resizeWidth = Math.min( width, _maxWidth );
        if (_maxHeight > 0) resizeHeight = Math.min( height, _maxHeight );
		
		m_Content.SetSize( resizeWidth - _padding * 2, resizeHeight - _nonContentHeight);
		
        SignalSizeChanged.Emit();
    }
    
    //Set Content
    public function SetContent(value:String):Void {
        if (m_Content) {
            m_Content.removeMovieClip();
            m_Content = null;
        }
        
        attachMovie(value, "m_Content", getNextHighestDepth());
        m_Content.SignalSizeChanged.Connect(Layout, this);
		m_Content.SignalLoaded.Connect(SlotContentLoaded, this)
        
        Layout();
    }

	
    private function layoutButtons():Void {
		var offset:Number = m_Background._width - _padding;
		var buttons:Array = [ m_CloseButton, m_HelpButton ];
		
		for ( var i:Number = 0; i < buttons.length; i++ ) {
			if( buttons[i]._visible ) {
				offset -= buttons[i]._width + (i * _windowButtonSpacing);
				buttons[i]._x = offset;
				buttons[i]._y = 6;// _padding;
			}
		}
	}
	
	// properties
	
	public function get showCloseButton():Boolean { return _showCloseButton; }
	public function set showCloseButton(value:Boolean):Void {
		_showCloseButton = value;
		m_CloseButton._visible = value;
		layoutButtons();
	}
	
	public function get showHelpButton():Boolean { return _showHelpButton; }
	public function set showHelpButton(value:Boolean):Void {
		_showHelpButton = value;
		m_HelpButton._visible = value;
		layoutButtons();
	}
	
	public function get showResizeHandle():Boolean { return _showResizeHandle; }
	public function set showResizeHandle(value:Boolean):Void {
		_showResizeHandle = value;
		m_ResizeButton._visible = value;
	}
	
	public function get showFooter():Boolean { return _showFooter; }
	public function set showFooter(value:Boolean):Void {
		_showFooter = value;
		m_Footer._visible = value;
	}

	public function get showTopFade():Boolean { return _showTopFade; }
	public function set showTopFade(value:Boolean):Void {
		_showTopFade = value;
		m_TopFade._visible = value;
	}
	
	public function get showTitleShadow():Boolean { return _showTitleShadow; }
	public function set showTitleShadow(value:Boolean):Void {
		if ( _showTitleShadow == value ) return;
		
		_showTitleShadow = value;

		// TODO: implement AddonUtils addFilter which will copy the filters array, add the new filter, and set the array back -- neither push or splice work directly on the filters array
		if ( value ) {
			m_Title.filters = [ new DropShadowFilter(0 /*60*/, 90, 0x000000, 0.8, 8, 8, 3, 3, false, false, false) ];
		}
		
		else {
			m_Title.filters = [ ];
		}
	}

	public function get showButtonShadow():Boolean { return _showButtonShadow; }
	public function set showButtonShadow(value:Boolean):Void {
		if ( _showButtonShadow == value ) return;
		
		_showButtonShadow = value;

		// TODO: implement AddonUtils addFilter which will copy the filters array, add the new filter, and set the array back -- neither push or splice work directly on the filters array
		if ( value ) {
			var windowButtonShadow:DropShadowFilter = new DropShadowFilter(0 /*60*/, 90, 0x000000, 1, 4, 4, 1, 3, false, false, false);
			
			m_CloseButton.filters = [ windowButtonShadow ];
			m_HelpButton.filters = [ windowButtonShadow ];
			m_ResizeButton.filters = [ new DropShadowFilter(0 /*90*/, -90, 0x000000, 1, 8, 8, 1, 3, false, false, false) ];
		}
		
		else {
			m_CloseButton.filters = [ ];
			m_HelpButton.filters = [ ];
			m_ResizeButton.filters = [ ];			
		}
	}

	public function get showWindowShadow():Boolean { return _showWindowShadow; }
	public function set showWindowShadow(value:Boolean):Void {
		_showWindowShadow = value;
		m_DropShadow._visible = value;
	}

	public function get padding():Number { return _padding; }
	public function set padding(value:Number):Void {
		_padding = value;
		Layout();
	}

	public function get showTitle():Boolean { return _showTitle; }
	public function set showTitle(value:Boolean):Void {
		_showTitle = value;
		m_Title._visible = value;
		Layout();
	}	
	
	public function get titleColour():Number { return _titleColour; }
	public function set titleColour(value:Number):Void {
		if ( _titleColour == value || !AddonUtils.isRGB(value) ) return;

		_titleColour = value;
		var textFormat:TextFormat = m_Title.getNewTextFormat();
		textFormat.color = value;
		m_Title.setTextFormat( textFormat );
		m_Title.setNewTextFormat( textFormat );
	}

	public function get title():String { return m_Title.text; }
	public function set title(value:String):Void {
		m_Title.text = value;
	}	
	
	// no setter for m_Title, but properties of the TextField can be changed through this
	public function get titleField():TextField { return m_Title };
	
	public function get topFadeColour():Number { return _topFadeColour; }
	public function set topFadeColour(value:Number):Void {
		if ( _topFadeColour == value || !AddonUtils.isRGB(value) ) return;

		_topFadeColour = value;
		AddonUtils.Colorize( m_TopFade, value );
	}

	public function get minWidth():Number { return _minWidth; }
	public function set minWidth(value:Number):Void {
		if ( _minWidth == value ) return;

		_minWidth = Math.max( MINWIDTH, value );

		Layout();
	}

	public function get minHeight():Number { return _minHeight; }
	public function set minHeight(value:Number):Void {
		if ( _minHeight == value ) return;

		_minHeight = Math.max( MINHEIGHT, value );
		Layout();
	}
	
	public function get maxWidth():Number { return _maxWidth; }
	public function set maxWidth(value:Number):Void {
		if ( _maxWidth == value ) return;

		_maxWidth = value;
		Layout();
	}
	
	public function get maxHeight():Number { return _maxHeight; }
	public function set maxHeight(value:Number):Void {
		if ( _maxHeight == value ) return;

		_maxHeight = value;
		Layout();
	}

    //Get Content
    public function GetContent():WindowComponentContent {
        return m_Content;
    }
	
	public function SlotContentLoaded()	{
		SignalContentLoaded.Emit();
	}

	public function GetSize():Point	{
		return new Point( m_Background._width, m_Background._height );
	}
	
	public function GetNonContentSize():Point {
		return new Point(_padding * 2, _nonContentHeight);
	}
}