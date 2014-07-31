import com.ElTorqiro.UITweaks.Plugins.PluginBase;
import com.GameInterface.DistributedValue;
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

class com.ElTorqiro.UITweaks.Plugins.InspectionStats extends com.ElTorqiro.UITweaks.Plugins.PluginBase {

	private var _findMCThrashCount:Number = 0;
	
	// TODO: make these configurable

	public function InspectionStats() {
		super();
		
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
		
		var skills:Array = [
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_WeaponPower )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_AttackRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HealingRating )},

			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HitRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CriticalRating)},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CritPowerRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PenetrationRating )},

			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_EvadeRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_DefenseRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_BlockRating )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PhysicalMitigation )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_MagicalMitigation ) },
			
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_ColorCodedDamagePercent )},
			{ name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_SecondaryColorCodedDamagePercent )}
			
		];
		
		// reverse mapping for easy adding of values to skills objects
		var skillsMap:Object = { };
		for ( var s:String in skills ) {
			if ( skills[s].name != undefined ) {
				skillsMap[ skills[s].name ] = skills[s];
			}
		}


		var content:MovieClip = _root.inspectioncontroller.m_InspectionWindows[characterID].m_Content;
		var originalContentHeight:Number = content._height;
		
		// hide existing stat panel
		content.m_StatInfoList._visible = false;
		content.m_StatsBgBox._visible = false;

		// remove default titlebar
		content._parent.SetTitle( '' );
		
			/* use this if wanting to put something in the titlebar */
			//content._parent.m_Title.autoSize = true;
			//content._parent.m_Title.setNewTextFormat( content.m_CharacterInfo.m_Name.getNewTextFormat() );
			//content._parent.SetTitle( content.m_CharacterInfo.m_Name.text ); // 'Inspecto Petronum' );


		// define layout constants
		var iconSize = 25;
		var iconPadding:Number = 3;
		var gearOffset:Number = 10;


		// add stat lines
		var statBox:MovieClip = content.createEmptyMovieClip( 'm_UITweaks_Stats', content.getNextHighestDepth() );
		statBox._x = (3 * iconSize) + (2 * iconPadding) + gearOffset + iconPadding * 12;
		statBox._y = content.m_CharacterInfo._y + content.m_CharacterInfo._height + iconPadding * 6;
		
		
		var maxWidth:Number = 0;
		for ( var i:Number = 0; i < skills.length; i++ ) {
			
			
			var hitRating:TextField = statBox.createTextField( 'm_HitRating', statBox.getNextHighestDepth(), 0, statBox._height, 0, 0 );
			
			var textFormat:TextFormat = content.m_WeaponsTitle.getNewTextFormat();
			textFormat.font = 'Futura Std Book Fix';
			textFormat.size = 12;
			textFormat.kerning = false;
			textFormat.leading = 2;
			textFormat.align = 'left';
			
			textFormat.color = 0xffffff;
			hitRating.autoSize = true;
			hitRating.antiAliasType = 'advanced';
			hitRating.html = false;
			hitRating.embedFonts  = true;

			hitRating.setNewTextFormat( textFormat );
			hitRating.text = skills[i].name;
			
			if (hitRating._width > maxWidth) maxWidth = hitRating._width;
		}
		maxWidth += 20;

		
		// addition of faction name and rank tag
		var faction:Number = content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )
		var factionColour:Number = 0xffffff;
		var factionTextColour:Number = 0xffffff;
		switch( faction ) {
			// dragon
			case _global.Enums.Factions.e_FactionDragon:		factionColour = Colors.e_ColorPvPDragon; factionTextColour = Colors.e_ColorPvPDragonText; break;
			
			// templar
			case _global.Enums.Factions.e_FactionTemplar:		factionColour = Colors.e_ColorPvPTemplar; factionTextColour = Colors.e_ColorPvPTemplarText; break;
			
			// illuminati
			case _global.Enums.Factions.e_FactionIlluminati:	factionColour = Colors.e_ColorPvPIlluminati; factionTextColour = Colors.e_ColorPvPIlluminatiText; break;
		}

		//content.m_CharacterInfo.m_Name.autoSize = 'left';
		var source:TextField = content.m_CharacterInfo.m_BasicInfo;
		var factionTextField:TextField = content.m_CharacterInfo.createTextField('m_UITweaks_FactionInfo', content.m_CharacterInfo.getNextHighestDepth(), source._x, source._y + source.textHeight, source._width, source.textHeight );
		var factionTextFormat:TextFormat = source.getNewTextFormat();
		factionTextFormat.color = factionTextColour;
		factionTextField.setNewTextFormat( factionTextFormat );
		// Faction.GetName(content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )) + ' ' + 
		factionTextField.text = LoreBase.GetTagName(content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_RankTag ));
		
		var factionBG:MovieClip = content.createEmptyMovieClip('m_UITweaks_CharacterInfoBackground', -16384 );
		
		var x:Number = 0;
		var y:Number = 0;
		var w:Number = content._width;
		var h:Number = content.m_CharacterInfo._height + 100;
		
		var topLeftCorner:Number = 5;
		var topRightCorner:Number = 5;
		var bottomRightCorner:Number = 0;
		var bottomLeftCorner:Number = 0;
		
		var mc = factionBG;
		var matrix = {matrixType:"box", x:x, y:y, w:100, h:h, r:45/180*Math.PI};

		factionBG.beginGradientFill(
			'linear', 
			[ factionColour, 0x000000 ],
			[ 50, 0 ],
			[ 0, 240 ],
			matrix
		);

        factionBG.moveTo(topLeftCorner+x, y);
        factionBG.lineTo(w - topRightCorner, y);
        factionBG.curveTo(w, y, w, topRightCorner+y);
		factionBG.lineTo(w, topRightCorner+y);
		factionBG.lineTo(w, h - bottomRightCorner);
        factionBG.curveTo(w, h, w - bottomRightCorner, h);
        factionBG.lineTo(w - bottomRightCorner, h);
        factionBG.lineTo( bottomLeftCorner+x, h);
        factionBG.curveTo(x, h, x, h - bottomLeftCorner);
        factionBG.lineTo(x, h - bottomLeftCorner);
        factionBG.lineTo(x, topLeftCorner+y);
		factionBG.curveTo(x, y, topLeftCorner+x, y);
        factionBG.lineTo(topLeftCorner+x, y);
        factionBG.endFill();

		content.m_CharacterInfo.m_FactionIconLoader.filters = [ new GlowFilter(
			factionTextColour,
			1,
			8,
			8,
			3,
			3,
			false,
			false
		) ];
		
		//content.m_CharacterInfo.m_FactionIconLoader._x = content.m_CharacterInfo.m_FactionIconLoader._y = 5;
		
		// layout gear icons
		var icons:Array = [
			content.m_IconChakra_1, content.m_IconChakra_2,	content.m_IconChakra_3,	content.m_IconChakra_4,	content.m_IconChakra_5,	content.m_IconChakra_6,	content.m_IconChakra_7,
			
			content.m_IconWeapon_1,	content.m_IconWeapon_2,	content.m_IconAuxiliaryWeapon,

			content.m_aegis_0,
			content.m_aegis_special_0, content.m_aegis_special_1,
			content.m_aegis_generic_0, content.m_aegis_generic_1, content.m_aegis_generic_2, content.m_aegis_generic_3,
			
			content.m_ClothingIconHats,
			content.m_ClothingIconHeadgear1, content.m_ClothingIconHeadgear2,
			content.m_ClothingIconNeck,
			content.m_ClothingIconChest, content.m_ClothingIconBack,
			content.m_ClothingIconHands,
			content.m_ClothingIconLeg,
			content.m_ClothingIconFeet,
			content.m_ClothingIconMultislot
		];
		
		for (var s:String in icons) {
			icons[s]._width = icons[s]._height = iconSize;
		}
		

		var gearLabelTextFormat:TextFormat = content.m_ChakrasTitle.getTextFormat();
		gearLabelTextFormat.align = 'center';
		
		// talisman layout
		content.m_ChakrasTitle._y = content.m_CharacterInfo._y + content.m_CharacterInfo._height + iconPadding * 6;
		
		content.m_ChakrasTitle._width = content.m_WeaponsTitle._width = (3 * iconSize) + (2 * iconPadding);
		content.m_ChakrasTitle._x = content.m_WeaponsTitle._x = gearOffset; // content.m_CharacterInfo._x; // content._width - content.m_ChakrasTitle._width;
		content.m_ChakrasTitle.setTextFormat( gearLabelTextFormat );
		content.m_WeaponsTitle.setTextFormat( gearLabelTextFormat );
		
		content.m_IconChakra_7._y = content.m_ChakrasTitle._y + content.m_ChakrasTitle.textHeight + iconPadding;
		content.m_IconChakra_4._y = content.m_IconChakra_5._y = content.m_IconChakra_6._y = content.m_IconChakra_7._y + iconSize + iconPadding;
		content.m_IconChakra_1._y = content.m_IconChakra_2._y = content.m_IconChakra_3._y = content.m_IconChakra_4._y + iconSize + iconPadding;
		
		content.m_IconChakra_4._x = content.m_IconChakra_1._x = content.m_IconWeapon_1._x = content.m_ChakrasTitle._x;
		content.m_IconChakra_5._x = content.m_IconChakra_2._x = content.m_IconChakra_7._x = content.m_IconWeapon_2._x = content.m_IconChakra_4._x + iconSize + iconPadding;
		content.m_IconChakra_6._x = content.m_IconChakra_3._x = content.m_IconAuxiliaryWeapon._x = content.m_IconChakra_5._x + iconSize + iconPadding;

		content.m_WeaponsTitle._y = content.m_IconChakra_1._y + iconSize + iconPadding;
		content.m_AuxiliarlyWeaponTitle._visible = false;
		
		content.m_IconWeapon_1._y = content.m_IconWeapon_2._y = content.m_IconAuxiliaryWeapon._y = content.m_WeaponsTitle._y + content.m_WeaponsTitle.textHeight + iconPadding;
		
		content.m_IconAuxiliaryWeapon._visible = true;


		// aegis layout
		content.m_AegisTitle._y = content.m_IconWeapon_1._y + iconSize + (iconPadding * 6);
		content.m_AegisTitle._width = (3 * iconSize) + (2 * iconPadding);
		content.m_AegisTitle._x = gearOffset; // content.m_CharacterInfo._x; // content._width - content.m_AegisTitle._width;
		content.m_AegisTitle.setTextFormat( gearLabelTextFormat );
		
		content.m_aegis_0._visible = true;
		
		content.m_aegis_0._y = content.m_AegisTitle._y + content.m_AegisTitle.textHeight + iconPadding;
		content.m_aegis_generic_0._y = content.m_aegis_generic_1._y = content.m_aegis_0._y + (iconSize / 2) + iconPadding;
		content.m_aegis_special_0._y = content.m_aegis_0._y + iconSize + iconPadding;
		content.m_aegis_special_1._y = content.m_aegis_special_0._y + iconSize + iconPadding;
		content.m_aegis_generic_2._y = content.m_aegis_generic_3._y = content.m_aegis_special_1._y + (iconSize / 2);

		content.m_aegis_generic_0._x = content.m_aegis_generic_2._x = content.m_AegisTitle._x;
		content.m_aegis_special_0._x = content.m_aegis_special_1._x = content.m_aegis_0._x = content.m_aegis_generic_0._x + iconSize + iconPadding;
		content.m_aegis_generic_1._x = content.m_aegis_generic_3._x = content.m_aegis_0._x + iconSize + iconPadding;
		

		// clothes layout
		content.m_ClothesTitle._y = content.m_aegis_generic_3._y + iconSize + iconPadding * 6;

		var clothingIndex:Number = null;
		for ( var i:Number = 0; i < icons.length; i++ ) {
			if ( icons[i]._name.substr( 0, 10 ) != 'm_Clothing' ) continue;
			if ( clothingIndex == null ) clothingIndex = i;
			
			icons[i]._x = (i - clothingIndex) * (iconSize + 1 );
			icons[i]._y = content.m_ClothesTitle._y + content.m_ClothesTitle.textHeight + iconPadding;
		}
		
		
		// layout preview button
		content.m_PreviewAllButton._y = content.m_ClothingIconHats._y + iconSize + 20;
		
		// let window know the size of the content has changed
		content.SignalSizeChanged.Emit();
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

	private function AddSkill(name:String):Void {
		
		
	}
}