//Imports
import flash.geom.Point;
import gfx.core.UIComponent;
import com.Components.WindowComponentContent;
import gfx.controls.Button;
import flash.geom.Rectangle;
import mx.utils.Delegate;
import com.Utils.Signal;
import com.GameInterface.Game.Character;

import com.GameInterface.UtilsBase;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;

//Class
class com.ElTorqiro.UITweaks.AddonUtils.Window extends UIComponent
{
    //Constants
    private static var DRAG_PADDING:Number = 100;
    
    //Properties
    public var SignalClose:Signal;
    public var SignalSizeChanged:Signal;
    public var SignalSelected:Signal;
	public var SignalContentLoaded:Signal;
    public var m_CloseButton:Button;
    
    private var m_Title:TextField;
    private var m_Content:WindowComponentContent;
    private var m_ResizeButton:MovieClip;	// Button
    private var m_TopFade:MovieClip;
    private var m_Background:MovieClip;
    private var m_DropShadow:MovieClip;
    
    private var m_MinHeight:Number;
    private var m_MinWidth:Number;
    
    private var m_MaxHeight:Number;
    private var m_MaxWidth:Number;

    private var m_ResizeListener:Object;
    private var m_ResizeX:Number;
    private var m_ResizeY:Number

    private var m_Padding:Number;
    private var m_NonContentHeight:Number;
    
    private var m_ResizeSensitivity:Number;
    
    private var m_IsDraggable:Boolean;
	
	private var m_ShowCloseButton:Boolean;
	private var m_ShowFooter:Boolean;
	private var m_ShowResize:Boolean;
    
	private var _resizeGrabOffset:Point;
	
	private var _resizing:Boolean;
	private var _resizeLoop:Boolean;
	
	private var _layoutRunning:Boolean;
	private var _dirty:Boolean;
	
    //Constructor
    public function Window()
    {
        SetPadding(10);
        
        SignalClose = new Signal();
        SignalSizeChanged = new Signal();
        SignalSelected = new Signal();
		SignalContentLoaded = new Signal();
        
        m_ResizeSensitivity = 2;
        m_MaxHeight = -1;
        m_MaxWidth = -1;
        m_MinHeight = -1;
        m_MinWidth = -1;
        
        m_IsDraggable = true;  
		
		m_ShowCloseButton = true;
		m_ShowFooter = true;
		m_ShowResize = true;
		
		_resizing = false;
		
		_layoutRunning = false;
		_dirty = false;
    }
    
    //On Load
    private function configUI():Void
    {
		super.configUI();
		
		m_CloseButton._visible = m_ShowCloseButton;
		m_Background.m_Footer._visible = m_ShowFooter
		m_ResizeButton._visible = m_ShowResize;
        
        m_ResizeButton.onPress = Delegate.create(this, ResizeDragHandler);
		m_ResizeButton.onRollOver = Delegate.create( this, ResizeRollOverHandler );
		m_ResizeButton.onRollOut = Delegate.create( this, ResizeRollOutHandler );
		m_ResizeButton.disableFocus = true;

        m_Background.onPress =  Delegate.create(this, MoveDragHandler);
        m_Background.onRelease = m_Background.onReleaseOutside = 
		m_Background.onReleaseAux = m_Background.onReleaseOutsideAux = Delegate.create(this, MoveDragReleaseHandler);
        
        m_CloseButton.addEventListener("click", this, "CloseButtonHandler");
        m_CloseButton.disableFocus = true;
		
		AddonUtils.Colorize( m_TopFade, 0x003366 );
		
		m_ResizeSensitivity = 1;
    }
    
    //Layout
    public function Layout():Void
    {
        var contentSize:Point = m_Content.GetSize();
		
		UtilsBase.PrintChatText('w:' + contentSize.x + ', h:' + contentSize.y);
		
		UtilsBase.PrintChatText('layoutRunning:' + _layoutRunning + ', dirty:' + _dirty);
		
		if ( _layoutRunning ) {
			_dirty = true;
			return;
		}

		_layoutRunning = true;
		
        var contentSize:Point = m_Content.GetSize();
        m_Content._x = m_Background._x + m_Padding;
        m_Background._width = m_Content._x + contentSize.x + m_Padding;
        
        if (m_Title.text == "" || m_Title == undefined)
        {
            m_Background._height = contentSize.y + m_Padding * 2;
            m_Content._y = m_Background._y + m_Padding;
            m_NonContentHeight = m_Background._y + m_Padding * 2;
        }
        else
        {
			m_Title._x = m_Padding;
			m_Title._y = 3;
            m_Title._width = m_Background._width - m_Padding * 2;
            m_Content._y = Math.round(m_Title._y + m_Title._height) + m_Padding;
            m_Background._height = m_Content._y + contentSize.y + m_Padding ;
			m_TopFade._width = m_Background._width;
			m_NonContentHeight = Math.round(m_Title._y + m_Title._height) + m_Padding * 2;
        }
        
        m_DropShadow._width = m_Background._width + 31;
        m_DropShadow._height = m_Background._height + 31;

        m_ResizeButton._x = m_Background._x + m_Background._width - m_ResizeButton._width;
        m_ResizeButton._y = m_Background._y + m_Background._height - m_ResizeButton._height;
        
        //m_CloseButton._x = m_Background._width - m_CloseButton._width - m_Padding;
        //m_CloseButton._y = m_Background._y + m_Padding;
		m_CloseButton._x = m_Background._width - m_CloseButton._width - m_Padding;
		m_CloseButton._y = 0;
		
		if ( _dirty ) _global.setTimeout( Delegate.create(this, LayoutRetrigger), 10 );
		else _layoutRunning = false;
    }
    
	private function LayoutRetrigger():Void {
		UtilsBase.PrintChatText(' layout retrigger ');
		_layoutRunning = false;
		_dirty = false;
		Layout();
	}
	
    //Show Close Button
    public function ShowCloseButton(value:Boolean):Void
    {
		m_ShowCloseButton = value;
        m_CloseButton._visible = value;
    }
    
    //Show Resize Button
    public function ShowResizeButton(value:Boolean):Void
    {
		m_ShowResize = value;
        m_ResizeButton._visible = value;
    }
    
    //Show Footer
    public function ShowFooter(value:Boolean):Void
    {
		m_ShowFooter = value;
        m_Background.m_Footer._visible = value;
    }

    //Close Button Handler
    private function CloseButtonHandler():Void
    {
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
    private function ResizeDragHandler():Void
    {
		if ( _resizing ) return;
		
		_resizing = true;
		m_ResizeButton.gotoAndPlay( 'down' );
		
		_resizeGrabOffset = new Point( m_Background._width - this._xmouse, m_Background._height - this._ymouse );
		
        m_ResizeListener = {};
        m_ResizeListener.onMouseMove = Delegate.create(this, MouseResizeMovingHandler);
		m_ResizeListener.onMouseUp = Delegate.create( this, ResizeDragReleaseHandler );
        
        Mouse.addListener(m_ResizeListener); 
    }
    
    //Mouse Resize Moving Handler
    private function MouseResizeMovingHandler():Void
    {	
		m_ResizeX = Math.max(this._xmouse + _resizeGrabOffset.x, m_MinWidth);
        m_ResizeY = Math.max(this._ymouse + _resizeGrabOffset.y, m_MinHeight);
        
        if (m_MaxWidth > 0) {
            m_ResizeX = Math.min(m_MaxWidth, m_ResizeX);
        }
        
        if (m_MaxHeight > 0) {
            m_ResizeY = Math.min(m_MaxHeight, m_ResizeY);
        }
        
        var xdiff:Number = Math.abs(m_Background._width - m_ResizeX);
        var ydiff:Number = Math.abs(m_Background._height - m_ResizeY);
        
		//if (xdiff > m_ResizeSensitivity || ydiff > m_ResizeSensitivity) {
			SetSize(m_ResizeX, m_ResizeY);
        //}
    }
    
    //Resize Drag Release
    private function ResizeDragReleaseHandler():Void
    {
        Mouse.removeListener(m_ResizeListener);
		SetSize(m_ResizeX, m_ResizeY);
		
		if (Mouse["IsMouseOver"](m_ResizeButton)) {
			m_ResizeButton.gotoAndPlay( 'over' );
		}
		
		else {
			m_ResizeButton.gotoAndPlay( 'up' );
		}
        
        m_ResizeListener = undefined;
		
		_resizing = false;
    }
    
    // Move Drag Handler
    private function MoveDragHandler():Void
    {
        if (m_IsDraggable)
        {
            if (!Mouse["IsMouseOver"](m_Content))
            {
                SignalSelected.Emit(this);
                
                var visibleRect = Stage["visibleRect"];

                this.startDrag  (
                                false,
                                0 - this._width + DRAG_PADDING - m_DropShadow._x,
                                0 - this._height + DRAG_PADDING - m_DropShadow._y,
                                visibleRect.width - DRAG_PADDING,
                                visibleRect.height - DRAG_PADDING
                                );        
            }
        }
    }
    
    //Move Drag Release
    private function MoveDragReleaseHandler():Void
    {
        this.stopDrag();
    }
    
    //Set Size
    public function SetSize(width:Number, height:Number):Void
    {
        m_Content.SetSize(width - m_Padding * 2, height - m_NonContentHeight);
        
        SignalSizeChanged.Emit();
    }
    
    //Set Title
    public function SetTitle(title:String, alignment:String):Void
    {
        m_Title.text = title;
        
        if (alignment == undefined)
        {
            alignment = "left";
        }
        
        m_Title.autoSize = alignment;
    }
    
    //Get Title
    public function GetTitle():String
    {
        return m_Title.text;
    }

    //Set Padding
    public function SetPadding(value:Number):Void
    {
        m_Padding = value;
        
        if (m_Content)
        {
            Layout();
        }
    }
    
    //Get Padding
    public function GetPadding():Number
    {
        return m_Padding;
    }
    
    //Set Content
    public function SetContent(value:String):Void
    {
        if (m_Content)
        {
            m_Content.removeMovieClip();
            m_Content = null;
        }
        
        attachMovie(value, "m_Content", getNextHighestDepth());
        m_Content.SignalSizeChanged.Connect(Layout, this);
		m_Content.SignalLoaded.Connect(SlotContentLoaded, this)
        
        Layout();
    }
    
    //Get Content
    public function GetContent():WindowComponentContent
    {
        return m_Content;
    }
	
	public function SlotContentLoaded()
	{
		SignalContentLoaded.Emit();
	}
    
    //Set Max WIdth
    public function SetMaxWidth(width:Number)
    {
        m_MaxWidth = width
    }
    
    //Set Max Height
    public function SetMaxHeight(height:Number)
    {
        m_MaxHeight = height
    }
    
    //Set Minimum Width
    public function SetMinWidth(width:Number):Void
    {
        m_MinWidth = width;
    }
    
    //Set Minimum Height
    public function SetMinHeight(height:Number):Void
    {
        m_MinHeight = height;
    }
    
    //Set Draggable
    public function SetDraggable(value:Boolean):Void
    {
        m_IsDraggable = value;
    }
    
    //Get Draggable
    public function GetDraggable():Boolean
    {
        return m_IsDraggable;
    }
	
	public function GetSize():Point
	{
		return m_Content.GetSize();
	}
    
	public function GetNonContentSize():Point
	{
		return new Point(m_Padding * 2, m_NonContentHeight);
	}
}