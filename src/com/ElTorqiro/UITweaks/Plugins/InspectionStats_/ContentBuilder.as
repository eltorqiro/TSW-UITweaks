import com.Utils.ID32;
import com.GameInterface.UtilsBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.GameInterface.LoreBase;
import flash.filters.GlowFilter;
import flash.geom.Point;

import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;


class com.ElTorqiro.UITweaks.Plugins.InspectionStats_.ContentBuilder {
	
	// inspection window content movieclips
	private var _content:MovieClip;
	private var _characterInfo:MovieClip;
	private var _statBox:MovieClip;
	
	// item graph
	private var _items:Object = { };
	private var _stats:Object = { };
	private var _statsMap:Object = { };
	
	// utilty objects
	private var _statBoxCursor:Point;
	
	// layout constants
	public var iconSize = 25;
	public var iconPadding:Number = 3;
	public var gearOffset:Number = 10;

	
	public function ContentBuilder(inspectionWindowContent:MovieClip) {
		
		_content = inspectionWindowContent;
		_characterInfo = _content.m_CharacterInfo;

		//AddonUtils.FindGlobalEnum( 'weapon' );
		
		Build();
	}
	

	private function Build():Void {
		
		var originalContentHeight:Number = _content._height;


		// hide existing stat panel
		_content.m_StatInfoList._visible = false;
		_content.m_StatsBgBox._visible = false;

		// remove default titlebar
		_content._parent.SetTitle( '' );

		
		// define skills/stats to track
		_stats = {
			weaponPower: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_WeaponPower )},
			attack: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_AttackRating )},
			heal: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HealingRating )},

			hit: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HitRating )},
			crit: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CriticalRating)},
			critPower: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CritPowerRating )},
			pen: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PenetrationRating )},

			evade: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_EvadeRating )},
			defence: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_DefenseRating )},
			block: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_BlockRating )},
			physProt: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PhysicalMitigation )},
			magProt: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_MagicalMitigation )},
			
			priAegisPercent: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_ColorCodedDamagePercent )},
			secAegisPercent: { name: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_SecondaryColorCodedDamagePercent ) }
		};
		
		// reverse mapping for easy adding of values to skills objects
		_statsMap = { };
		for ( var s:String in _stats ) {
			if ( _stats[s].name != undefined ) {
				_statsMap[ _stats[s].name ] = _stats[s];
				_stats[s].values = {
						talismans: 0,
						primaryWeapon: 0,
						secondaryWeapon: 0
				};
			}
		}
	
		
		// fetch stat values
		_items = { };
		for ( var s:String in _content.m_InspectionInventory.m_Items ) {

			var inventoryItem:InventoryItem = _content.m_InspectionInventory.m_Items[s];
			var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip( _content.m_InspectionInventory.GetInventoryID(), inventoryItem.m_InventoryPos );

			var item:Object = { name: inventoryItem.m_Name, type: inventoryItem.m_ItemType, position: inventoryItem.m_InventoryPos, rank: Number(tooltipData.m_ItemRank) };

			// accumulate stat values for this item on the right node
			var statNode:String;
			switch( item.type ) {
				case _global.Enums.ItemType.e_ItemType_Chakra: statNode = 'talismans'; break;

				case _global.Enums.ItemType.e_ItemType_Weapon:
					switch( item.position ) {
						case _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot: statNode = 'primaryWeapon';  break;
						case _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot: statNode = 'secondaryWeapon';  break;
						default: continue;
					}
				break;
				
				default: continue;
			}

			// item attribute
			item.attributes = AddAttributes( tooltipData.m_Attributes, statNode );
			
			// item glyph
			if( !tooltipData.m_EmptyPrefix ) {
				item.glyph = { name: AddonUtils.StripHTML(tooltipData.m_PrefixData.m_Title), rank: Number(tooltipData.m_PrefixData.m_ItemRank) };
				item.glyph.attributes = AddAttributes( tooltipData.m_PrefixData.m_Attributes, statNode );
			}
			
			// TODO: item signet
			
			// store item
			_items[ item.name ] = item;
		}
		

		// add stat lines
		var statSectionSpacing:Number = iconPadding * 3;

		// add stat box movieclip
		_statBox = _content.createEmptyMovieClip( 'm_UITweaks_Stats', _content.getNextHighestDepth() );
		_statBox.hitTestDisable = true;
		_statBox._x = (3 * iconSize) + (2 * iconPadding) + gearOffset + iconPadding * 6;
		//_statBox._y = _characterInfo._y + _characterInfo._height + iconPadding * 6;
		_statBox._y = _characterInfo._y + _characterInfo._height + iconPadding * 6 + 10;
		
		_statBoxCursor = new Point( 0, 0 );

		AddStatLine( 'weaponPower' );
		AddStatLine( 'attack' );
		AddStatLine( 'heal' );

		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'hit' );
		
		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'crit' );
		AddStatLine( 'critPower' );
		AddStatLine( 'pen' );

		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'evade' );
		AddStatLine( 'defence' );
		AddStatLine( 'block' );
		
		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'physProt' );
		AddStatLine( 'magProt' );

		//tx = AddStatLine( statBox, stats, primaryWeaponStat, secondaryWeaponStat, 'priAegisPercent', tx._y + tx.textHeight + sectionPadding );
		//tx = AddStatLine( statBox, stats, primaryWeaponStat, secondaryWeaponStat, 'secAegisPercent', tx._y + tx.textHeight );
		
		// addition of faction name and rank tag
		var faction:Number = _content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )
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

		_characterInfo.hitTestDisable = true;
		var source:TextField = _content.m_CharacterInfo.m_BasicInfo;
		var factionTextField:TextField = _content.m_CharacterInfo.createTextField('m_UITweaks_FactionInfo', _content.m_CharacterInfo.getNextHighestDepth(), source._x, source._y + source.textHeight, source._width, source.textHeight );
		var factionTextFormat:TextFormat = source.getNewTextFormat();
		factionTextFormat.color = factionTextColour;
		factionTextField.setNewTextFormat( factionTextFormat );
		// Faction.GetName(content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )) + ' ' + 
		factionTextField.text = LoreBase.GetTagName(_content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_RankTag ));

		_content.m_CharacterInfo.m_FactionIconLoader.filters = [ new GlowFilter(factionTextColour, 1, 8, 8, 3, 3, false, false) ];
		

		// layout gear icons
		var icons:Array = [
			_content.m_IconChakra_1, _content.m_IconChakra_2, _content.m_IconChakra_3, _content.m_IconChakra_4, _content.m_IconChakra_5, _content.m_IconChakra_6, _content.m_IconChakra_7,
			
			_content.m_IconWeapon_1, _content.m_IconWeapon_2, _content.m_IconAuxiliaryWeapon,

			_content.m_aegis_0,
			_content.m_aegis_special_0, _content.m_aegis_special_1,
			_content.m_aegis_generic_0, _content.m_aegis_generic_1, _content.m_aegis_generic_2, _content.m_aegis_generic_3,
			
			_content.m_ClothingIconHats,
			_content.m_ClothingIconHeadgear1, _content.m_ClothingIconHeadgear2,
			_content.m_ClothingIconNeck,
			_content.m_ClothingIconChest, _content.m_ClothingIconBack,
			_content.m_ClothingIconHands,
			_content.m_ClothingIconLeg,
			_content.m_ClothingIconFeet,
			_content.m_ClothingIconMultislot
		];
		
		for (var s:String in icons) {
			icons[s]._width = icons[s]._height = iconSize;
		}
		

		var gearLabelTextFormat:TextFormat = _content.m_ChakrasTitle.getTextFormat();
		gearLabelTextFormat.align = 'center';
		
		// talisman layout
		_content.m_ChakrasTitle._y = _content.m_CharacterInfo._y + _content.m_CharacterInfo._height + iconPadding * 6;
		
		_content.m_ChakrasTitle._width = _content.m_WeaponsTitle._width = (3 * iconSize) + (2 * iconPadding);
		_content.m_ChakrasTitle._x = _content.m_WeaponsTitle._x = gearOffset; // content.m_CharacterInfo._x; // content._width - content.m_ChakrasTitle._width;
		_content.m_ChakrasTitle.setTextFormat( gearLabelTextFormat );
		_content.m_WeaponsTitle.setTextFormat( gearLabelTextFormat );
		
		_content.m_IconChakra_7._y = _content.m_ChakrasTitle._y + _content.m_ChakrasTitle.textHeight + iconPadding;
		_content.m_IconChakra_4._y = _content.m_IconChakra_5._y = _content.m_IconChakra_6._y = _content.m_IconChakra_7._y + iconSize + iconPadding;
		_content.m_IconChakra_1._y = _content.m_IconChakra_2._y = _content.m_IconChakra_3._y = _content.m_IconChakra_4._y + iconSize + iconPadding;
		
		_content.m_IconChakra_4._x = _content.m_IconChakra_1._x = _content.m_IconWeapon_1._x = _content.m_ChakrasTitle._x;
		_content.m_IconChakra_5._x = _content.m_IconChakra_2._x = _content.m_IconChakra_7._x = _content.m_IconWeapon_2._x = _content.m_IconChakra_4._x + iconSize + iconPadding;
		_content.m_IconChakra_6._x = _content.m_IconChakra_3._x = _content.m_IconAuxiliaryWeapon._x = _content.m_IconChakra_5._x + iconSize + iconPadding;

		_content.m_WeaponsTitle._y = _content.m_IconChakra_1._y + iconSize + iconPadding;
		_content.m_AuxiliarlyWeaponTitle._visible = false;
		
		_content.m_IconWeapon_1._y = _content.m_IconWeapon_2._y = _content.m_IconAuxiliaryWeapon._y = _content.m_WeaponsTitle._y + _content.m_WeaponsTitle.textHeight + iconPadding;
		
		_content.m_IconAuxiliaryWeapon._visible = true;


		// aegis layout
		_content.m_AegisTitle._y = _content.m_IconWeapon_1._y + iconSize + (iconPadding * 6);
		_content.m_AegisTitle._width = (3 * iconSize) + (2 * iconPadding);
		_content.m_AegisTitle._x = gearOffset; // content.m_CharacterInfo._x; // content._width - content.m_AegisTitle._width;
		_content.m_AegisTitle.setTextFormat( gearLabelTextFormat );
		
		_content.m_aegis_0._visible = true;
		
		_content.m_aegis_0._y = _content.m_AegisTitle._y + _content.m_AegisTitle.textHeight + iconPadding;
		_content.m_aegis_generic_0._y = _content.m_aegis_generic_1._y = _content.m_aegis_0._y + (iconSize / 2) + iconPadding;
		_content.m_aegis_special_0._y = _content.m_aegis_0._y + iconSize + iconPadding;
		_content.m_aegis_special_1._y = _content.m_aegis_special_0._y + iconSize + iconPadding;
		_content.m_aegis_generic_2._y = _content.m_aegis_generic_3._y = _content.m_aegis_special_1._y + (iconSize / 2);

		_content.m_aegis_generic_0._x = _content.m_aegis_generic_2._x = _content.m_AegisTitle._x;
		_content.m_aegis_special_0._x = _content.m_aegis_special_1._x = _content.m_aegis_0._x = _content.m_aegis_generic_0._x + iconSize + iconPadding;
		_content.m_aegis_generic_1._x = _content.m_aegis_generic_3._x = _content.m_aegis_0._x + iconSize + iconPadding;
		

		// clothes layout
		_content.m_ClothesTitle._y = _content.m_aegis_generic_3._y + iconSize + iconPadding * 6;

		var clothingIndex:Number = null;
		for ( var i:Number = 0; i < icons.length; i++ ) {
			if ( icons[i]._name.substr( 0, 10 ) != 'm_Clothing' ) continue;
			if ( clothingIndex == null ) clothingIndex = i;
			
			icons[i]._x = (i - clothingIndex) * (iconSize + 1 );
			icons[i]._y = _content.m_ClothesTitle._y + _content.m_ClothesTitle.textHeight + iconPadding;
		}
		
		
		// layout preview button
		_content.m_PreviewAllButton._y = _content.m_ClothingIconHats._y + iconSize + 20;

		// faction bg backgrounds
		var factionBG:MovieClip = DrawBackgroundBox( _content, 'm_UITweaks_FactionBGTopLeft', -16384, 0, 0, _content._width, _content.m_CharacterInfo._height + 100, 6, 0, 0, 0, factionColour, 45);
		factionBG.hitTestDisable = true;
		
		// let window know the size of the content has changed
		_content.SignalSizeChanged.Emit();

	}
	

	private function DrawBackgroundBox(hostMC, name, depth, x, y, w, h, topLeftCorner, topRightCorner, bottomRightCorner, bottomLeftCorner, colour, angle):MovieClip {

		var mc:MovieClip = hostMC.createEmptyMovieClip('m_UITweaks_FactionBackground', depth ); // -16384 );
		var matrix = {matrixType:"box", x:x, y:y, w:100, h:h, r:angle/180*Math.PI};

		mc.beginGradientFill(
			'linear', 
			[ colour, 0x000000 ],
			[ 50, 0 ],
			[ 0, 240 ],
			matrix
		);

        mc.moveTo(topLeftCorner+x, y);
        mc.lineTo(w - topRightCorner, y);
        mc.curveTo(w, y, w, topRightCorner+y);
		mc.lineTo(w, topRightCorner+y);
		mc.lineTo(w, h - bottomRightCorner);
        mc.curveTo(w, h, w - bottomRightCorner, h);
        mc.lineTo(w - bottomRightCorner, h);
        mc.lineTo( bottomLeftCorner+x, h);
        mc.curveTo(x, h, x, h - bottomLeftCorner);
        mc.lineTo(x, h - bottomLeftCorner);
        mc.lineTo(x, topLeftCorner+y);
		mc.curveTo(x, y, topLeftCorner+x, y);
        mc.lineTo(topLeftCorner+x, y);
        mc.endFill();
		
		return mc;
	}


	private function AddStatLine( statName ):Void {

		// get values
		var baseStat:Number = _stats[ statName ].values.talismans;
		var primaryStat:Number = baseStat + _stats[ statName ].values.primaryWeapon;
		var secondaryStat:Number = baseStat + _stats[ statName ].values.secondaryWeapon;

		var valueText:String = '';
		
		// show weapon split values if stat exists on either weapon
		if ( (primaryStat > baseStat || secondaryStat > baseStat) ) {
			
			if ( primaryStat == secondaryStat ) valueText = String(primaryStat);
			else valueText = primaryStat + ' / ' + secondaryStat;
		}
		
		// else just show the single value, as it is solely from non-weapons
		else {
			valueText = String(baseStat);
		}
		
		var textFormat:TextFormat = new TextFormat();// content.m_WeaponsTitle.getNewTextFormat();
		textFormat.font = 'Futura Std Book Fix';
		textFormat.size = 12;
		textFormat.kerning = false;
		textFormat.leading = 2;
		textFormat.align = 'center';

		textFormat.color = valueText != '0' ? 0xEEBA05 : 0x666666;
		
		// add value numbers
		var valueField:TextField = _statBox.createTextField( 'm_' + statName + 'Value', _statBox.getNextHighestDepth(), 0, _statBoxCursor.y, 60, 0 );
		valueField.autoSize = 'right';
		//valueField.verticalAutoSize = 'top';
		valueField.antiAliasType = 'advanced';
		valueField.html = false;
		valueField.embedFonts  = true;

		valueField.setNewTextFormat( textFormat );
		
		valueField.text = valueText != '0' ? valueText : '-';

		
		// add stat name text
		var nameText:TextField = _statBox.createTextField( 'm_' + statName + 'Name', _statBox.getNextHighestDepth(), 70, _statBoxCursor.y, 0, 0 );
		nameText.autoSize = 'left';
		nameText.antiAliasType = 'advanced';
		nameText.html = false;
		nameText.embedFonts  = true;
		textFormat.align = 'left';

		textFormat.color = valueText != '0' ? 0xffffff : 0x666666;
		
		nameText.setNewTextFormat( textFormat );
		nameText.text = _stats[ statName ].name;

		
		// update line cursor
		_statBoxCursor.y += nameText.textHeight;
	}

	
	private function AddAttributes( attributeArray:Array, statNode:String ):Object {

		var attributes:Object = { };
		
			for ( var a:String in attributeArray ) {
				var attribute = AddonUtils.StripHTML( attributeArray[a].m_Right );
				if( attribute != undefined ) {
					var statIndex:Number = attribute.indexOf( '+' ) + 1;
					var value = attribute.substring( statIndex, attribute.indexOf(' ', statIndex));
					var stat = attribute.substr( statIndex + value.length + 1 );
					
					attributes[ stat ] = { name: stat, value: Number(value) };
					
					_statsMap[ stat ].values[statNode] += Number(value);
				}
			}
		
		return attributes;
	}	
	
}