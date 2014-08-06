import com.GameInterface.Inventory;
import com.Utils.ID32;
import com.GameInterface.UtilsBase;
import com.GameInterface.InventoryItem;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.Utils.LDBFormat;
import com.Utils.Colors;
import com.GameInterface.LoreBase;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import com.Components.ItemSlot;
import com.Utils.Faction;
import com.GameInterface.Game.Character;


import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.Plugins.InspectionStats_.LDB;

class com.ElTorqiro.UITweaks.Plugins.InspectionStats_.ContentBuilder {
	
	// inspection window content movieclips
	private var _content:MovieClip;
	private var _characterInfo:MovieClip;
	private var _factionIcon:MovieClip
	private var _statBox:MovieClip;
	private var _statBoxValues:MovieClip;
	private var _statBoxNames:MovieClip;
	private var _window:MovieClip;
	
	// item graph
	private var _items:Object = { };
	private var _stats:Object = { };
	private var _statsMap:Object = { };
	
	// utilty objects
	private var _statBoxCursor:Point;
	private var _maxStatWidth:Number = 0;
	
	// layout constants
	public var iconSize = 25;
	public var iconPadding:Number = 3;
	public var gearOffset:Number = 10;
	public var statSectionSpacing:Number = iconPadding * 3;
	
	public function ContentBuilder(inspectionWindowContent:MovieClip) {

		_content = inspectionWindowContent;
		_characterInfo = _content.m_CharacterInfo;
		_factionIcon = _characterInfo.m_FactionIconLoader;
		_window = _content._parent;

		//AddonUtils.FindGlobalEnum( '.ItemType.' );
		
		Build();
	}
	

	private function Build():Void {
		
		// hide existing content
		_content.m_StatInfoList._visible = false;
		_content.m_StatsBgBox._visible = false;
		_characterInfo.m_Name._visible = false;
		_characterInfo.m_BasicInfo._visible = false;

		// remove window chrome features
		_window.SetTitle( '' );
		//_window.ShowFooter( false );

		// allow clicks through sections
		_characterInfo.hitTestDisable = true;


		// get faction specific values and reposition icon slightly
		var faction:Number = _content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )
		var factionColour:Number = 0xffffff;
		var factionTextColour:Number = 0xffffff;
		switch( faction ) {
			// dragon
			case _global.Enums.Factions.e_FactionDragon:
				factionColour = Colors.e_ColorPvPDragon; factionTextColour = Colors.e_ColorPvPDragonText;
				with ( _factionIcon ) {
					_x += 4;
					_y += 1;
				}
			break;
			
			// templar
			case _global.Enums.Factions.e_FactionTemplar:
				factionColour = Colors.e_ColorPvPTemplar; factionTextColour = Colors.e_ColorPvPTemplarText;
				with ( _factionIcon ) {
					_x += 2;
					_width -= 2;
					_height -= 2;
				}
			break;
			
			// illuminati
			case _global.Enums.Factions.e_FactionIlluminati:
				factionColour = Colors.e_ColorPvPIlluminati; factionTextColour = Colors.e_ColorPvPIlluminatiText;
				with ( _factionIcon ) {
					_y -= 2;
					_x += 2;
				}
			break;
		}
		
		
		// redesign the title section
		var titleFormat:TextFormat = _characterInfo.m_Name.getTextFormat();
		titleFormat.size = 12;
		
		var titleDropShadow:DropShadowFilter = new DropShadowFilter(60, 90, 0x000000, 0.7, 8, 8, 2, 3, false, false, false);
		
		var title:TextField = _characterInfo.createTextField( 'm_UITweaks_TitleFullName', _content.getNextHighestDepth(), 0, 0, 0, _characterInfo._height );
		title.autoSize = 'left';
		title.embedFonts = true;
		title.multiline = true;
		//title.wordWrap = true;
		//titleFormat.size = 12;
		//titleFormat.leading = -1;
		//title.setTextFormat( titleFormat );
		title.setNewTextFormat( titleFormat );		
		title.filters = [ titleDropShadow ];

		
		title.appendHtml( '<font size="16">"' + _content.m_InspectionCharacter.GetName() + '"</font>' );
		title.appendHtml( '<font size="12">\n' + _content.m_InspectionCharacter.GetFirstName() + ' ' + _content.m_InspectionCharacter.GetLastName() + '</font>' );
		
		var characterTitle = _content.m_InspectionCharacter.GetTitle();
		if( characterTitle.length > 0 ) {
			title.appendHtml( '<font size="12">, ' + characterTitle + '</font>' );
		}
		
		var cabalName:String = _content.m_InspectionCharacter.GetGuildName();
		if ( cabalName.length > 0 ) {
			title.appendHtml( '<font size="12" color="#cccccc">\n&lt;' + cabalName + '&gt;</font>' );
		}
		
		var factionName:String = Faction.GetName(_content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ));
		title.appendHtml('\n<font size="12" color="#' + AddonUtils.colorToHex(factionColour) + '">' + AddonUtils.firstToUpper( factionName ) );

		var factionTitle = LoreBase.GetTagName(_content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_RankTag ));
		if ( factionTitle.length > 0 ) {
			title.appendHtml( ' ' + factionTitle );
		}

		title.appendHtml( ', ' + LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_BattleRank") + ' ' + _content.m_InspectionCharacter.GetStat(_global.Enums.Stat.e_PvPLevel) );
		title.appendHtml( '</font>' );
		
		
		// define skills/stats to track
		_stats = {
			weaponPower: { name: LDB.GetText('StatNames', 'WeaponPower') },
			attack: { name: LDB.GetText('StatNames', 'AttackRating') },
			heal: { name: LDB.GetText('StatNames', 'HealRating') },

			hit: { name: LDB.GetText('StatNames', 'HitRating') },
			crit: { name: LDB.GetText('StatNames', 'CriticalRating') },
			critPower: { name: LDB.GetText('StatNames', 'CritPower') },
			pen: { name: LDB.GetText('StatNames', 'PenetrationRating') },

			evade: { name: LDB.GetText('StatNames', 'EvadeRating') },
			defence: { name: LDB.GetText('StatNames', 'DefenceRating') },
			block: { name: LDB.GetText('StatNames', 'BlockRating') },
			physProt: { name: LDB.GetText('StatNames', 'PhysicalProtection') },
			magProt: { name: LDB.GetText('StatNames', 'MagicalProtection') },
			
			priAegisPercent: { },
			secAegisPercent: { },
			
			aegisPercent: { name: LDB.GetText('StatNames', 'AvgAegisConversionPercent'), counts: { primaryWeapon: 0, secondaryWeapon: 0 } },
			
			health: { name: 'Health' },
			
			maxQL: { name: LDB.GetText('StatNames', 'MaxQL') },
			avgQL: { name: LDB.GetText('StatNames', 'AvgQL'), count: 0 }
		};
		
		// reverse mapping for easy adding of values to skills objects
		_statsMap = { };
		for ( var s:String in _stats ) {
			if ( _stats[s].name != undefined ) {
				_statsMap[ _stats[s].name ] = _stats[s];
				_stats[s].values = {
						base: 0,
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
				case _global.Enums.ItemType.e_ItemType_AegisGeneric:
					statNode = 'base';
				case _global.Enums.ItemType.e_ItemType_AegisWeapon:
					switch( item.position ) {
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1:
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_2:							
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_3:							
							statNode = 'primaryWeapon';
							_stats.aegisPercent.counts.primaryWeapon++;
						break;
							
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2:
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_2:							
						case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_3:							
							statNode = 'secondaryWeapon';
							_stats.aegisPercent.counts.secondaryWeapon++;
						break;
					}
					
					// item attributes
					if( statNode != undefined ) item.attributes = AddAegisAttributes( tooltipData.m_Descriptions, statNode );
				break;

				
				case _global.Enums.ItemType.e_ItemType_Chakra:
					statNode = 'base';
				case _global.Enums.ItemType.e_ItemType_Weapon:
					switch( item.position ) {
						case _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot: statNode = 'primaryWeapon';  break;
						case _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot: statNode = 'secondaryWeapon';  break;
						case _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot: continue;
					}
					
					// item attribute
					item.attributes = AddAttributes( tooltipData.m_Attributes, statNode );
					if ( _stats.maxQL.values.base < item.rank ) _stats.maxQL.values.base = item.rank;
					_stats.avgQL.values.base += item.rank;
					_stats.avgQL.count++;
					
					// item glyph
					if ( tooltipData.m_PrefixData != undefined ) {
						item.glyph = { name: AddonUtils.StripHTML(tooltipData.m_PrefixData.m_Title), rank: Number(tooltipData.m_PrefixData.m_ItemRank) };
						item.glyph.attributes = AddAttributes( tooltipData.m_PrefixData.m_Attributes, statNode );

						if ( _stats.maxQL.values.base < item.glyph.rank ) _stats.maxQL.values.base = item.glyph.rank;
						_stats.avgQL.values.base += item.glyph.rank;
						_stats.avgQL.count++;
					}
					
					// TODO: item signet
				break;
				
				default: continue;
			}

			// store item
			_items[ item.name ] = item;
		}
		
		// implied aegis percentages
		if ( _stats.aegisPercent.values.primaryWeapon > 0 )
			_stats.aegisPercent.values.primaryWeapon = Math.round( _stats.aegisPercent.values.primaryWeapon / _stats.aegisPercent.counts.primaryWeapon * 100 ) / 100;
			
		if ( _stats.aegisPercent.values.secondaryWeapon > 0 )
			_stats.aegisPercent.values.secondaryWeapon = Math.round( _stats.aegisPercent.values.secondaryWeapon / _stats.aegisPercent.counts.secondaryWeapon * 100 ) / 100;
		
		// implied ql average
		if ( _stats.avgQL.values.base > 0 )
			_stats.avgQL.values.base = Math.floor( _stats.avgQL.values.base / _stats.avgQL.count * 100 ) / 100;
		
		// info not from gear
		//_stats.health.values.base = _content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_Health );
		

		// add stat box movieclip
		_statBox = _content.createEmptyMovieClip( 'm_UITweaks_Stats', _content.getNextHighestDepth() );
		_statBox.filters = [ titleDropShadow ];
		_statBoxValues = _statBox.createEmptyMovieClip( 'm_Values', _statBox.getNextHighestDepth() );
		_statBoxNames = _statBox.createEmptyMovieClip( 'm_Names', _statBox.getNextHighestDepth() );
		_statBox.hitTestDisable = true;
		_statBox._x = (3 * iconSize) + (2 * iconPadding) + gearOffset + iconPadding * 6;
		_statBox._y = title._y + title._height + iconPadding * 6;

		_statBoxCursor = new Point( 0, 0 );

		AddStatLine( 'maxQL' );
		AddStatLine( 'avgQL' );
		
		_statBoxCursor.y += statSectionSpacing;
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

		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'health' );
		
		_statBoxCursor.y += statSectionSpacing;
		AddStatLine( 'aegisPercent' );


		// align values and names -- this is done here as the max required width of values is now available
		_statBoxNames._x = _statBoxValues._width + iconPadding * 3;
		for ( var s:String in _statBoxValues ) {
			if ( _statBoxValues[s] instanceof TextField ) {
				var textField:TextField = _statBoxValues[s];
				var textFormat:TextFormat = new TextFormat();
				textFormat.align = 'center';
				textField.autoSize = 'none';
				textField._width = _statBoxValues._width;
				textField.setTextFormat(textFormat);
			}
		}

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
			icons[s]._visible = true;
		}


		var gearLabelTextFormat:TextFormat = titleFormat;
		gearLabelTextFormat.align = 'center';
		
		// talisman layout
		//_content.m_ChakrasTitle._y = _content.m_CharacterInfo._y + _content.m_CharacterInfo._height + iconPadding * 6;
		_content.m_ChakrasTitle._y = title._y + title._height + iconPadding * 6;

		_content.m_ChakrasTitle._width = _content.m_WeaponsTitle._width = (3 * iconSize) + (2 * iconPadding);
		_content.m_ChakrasTitle._x = _content.m_WeaponsTitle._x = gearOffset; // content.m_CharacterInfo._x; // content._width - content.m_ChakrasTitle._width;

		_content.m_ChakrasTitle.text = AddonUtils.firstToUpper( _content.m_ChakrasTitle.text );
		_content.m_ChakrasTitle.setTextFormat( gearLabelTextFormat );
		_content.m_ChakrasTitle.filters = [ titleDropShadow ];
		_content.m_ChakrasTitle.hitTestDisable = true;

		_content.m_WeaponsTitle.text = AddonUtils.firstToUpper( _content.m_WeaponsTitle.text );
		_content.m_WeaponsTitle.setTextFormat( gearLabelTextFormat );
		_content.m_WeaponsTitle.filters = [ titleDropShadow ];
		_content.m_WeaponsTitle.hitTestDisable = true;
		
		_content.m_IconChakra_7._y = _content.m_ChakrasTitle._y + _content.m_ChakrasTitle.textHeight + iconPadding;
		_content.m_IconChakra_4._y = _content.m_IconChakra_5._y = _content.m_IconChakra_6._y = _content.m_IconChakra_7._y + iconSize + iconPadding;
		_content.m_IconChakra_1._y = _content.m_IconChakra_2._y = _content.m_IconChakra_3._y = _content.m_IconChakra_4._y + iconSize + iconPadding;
		
		_content.m_IconChakra_4._x = _content.m_IconChakra_1._x = _content.m_IconWeapon_1._x = _content.m_ChakrasTitle._x;
		_content.m_IconChakra_5._x = _content.m_IconChakra_2._x = _content.m_IconChakra_7._x = _content.m_IconWeapon_2._x = _content.m_IconChakra_4._x + iconSize + iconPadding;
		_content.m_IconChakra_6._x = _content.m_IconChakra_3._x = _content.m_IconAuxiliaryWeapon._x = _content.m_IconChakra_5._x + iconSize + iconPadding;

		_content.m_WeaponsTitle._y = _content.m_IconChakra_1._y + iconSize + iconPadding;
		_content.m_AuxiliarlyWeaponTitle._visible = false;
		
		_content.m_IconWeapon_1._y = _content.m_IconWeapon_2._y = _content.m_IconAuxiliaryWeapon._y = _content.m_WeaponsTitle._y + _content.m_WeaponsTitle.textHeight + iconPadding;


		// aegis layout
		_content.m_AegisTitle._y = _content.m_IconWeapon_1._y + iconSize + (iconPadding * 6);
		_content.m_AegisTitle._width = (3 * iconSize) + (2 * iconPadding);
		_content.m_AegisTitle._x = gearOffset;

		_content.m_AegisTitle.setTextFormat( gearLabelTextFormat );
		_content.m_AegisTitle.filters = [ titleDropShadow ];
		_content.m_AegisTitle.hitTestDisable = true;
		
		_content.m_aegis_0._y = _content.m_AegisTitle._y + _content.m_AegisTitle.textHeight + iconPadding;
		_content.m_aegis_generic_0._y = _content.m_aegis_generic_1._y = _content.m_aegis_0._y + (iconSize / 3 * 2) + iconPadding;
		_content.m_aegis_special_0._y = _content.m_aegis_0._y + iconSize + iconPadding;
		_content.m_aegis_special_1._y = _content.m_aegis_special_0._y + iconSize + iconPadding;
		_content.m_aegis_generic_2._y = _content.m_aegis_generic_3._y = _content.m_aegis_special_1._y + (iconSize / 3);

		_content.m_aegis_generic_0._x = _content.m_aegis_generic_2._x = _content.m_AegisTitle._x;
		_content.m_aegis_special_0._x = _content.m_aegis_special_1._x = _content.m_aegis_0._x = _content.m_aegis_generic_0._x + iconSize + iconPadding;
		_content.m_aegis_generic_1._x = _content.m_aegis_generic_3._x = _content.m_aegis_0._x + iconSize + iconPadding;

		
		// add aegis controllers (fwiw)
		// can't layout the currently selected AEGIS in front because you can't get the active aegis stat of another character (always returns 0)
		var aegisLocations:Array = [
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_1,
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_2,
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_3,
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_2,
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_2,
			_global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_3
		];

		var aegis:Object = { };
		for ( var i:Number = 0; i < 6; i++ ) {
			var aegisSlot:MovieClip = _content.m_IconWeapon_1.duplicateMovieClip( 'm_UITWeaks_Aegis_' + i, _content.getNextHighestDepth() ); //_content.attachMovie( 'icon_aegis_weapon_1', 'm_UITWeaks_Aegis_' + i, _content.getNextHighestDepth() );
			
			aegis[i] = aegisSlot;
			try {
				aegisSlot.slot = new ItemSlot( _content.m_InspectionInventory.GetInventoryID(), aegisLocations[i], aegisSlot );
				aegisSlot.slot.SetData(_content.m_InspectionInventory.GetItemAt(aegisLocations[i]));
			} catch (e) {
				
			}
			
			// resize after the ItemSlot has been populated, to make sure the entire movieclip remains within the desired size
			aegisSlot._width = iconSize;
			aegisSlot._height = iconSize;
		}
		
		aegis[0]._y = aegis[3]._y = _content.m_aegis_generic_2._y + iconSize + iconPadding * 3;
		aegis[1]._y = aegis[4]._y = aegis[0]._y + iconSize + iconPadding;
		aegis[2]._y = aegis[5]._y = aegis[0]._y + (iconSize / 2);
		
		aegis[0]._x = aegis[1]._x = _content.m_aegis_generic_2._x;
		aegis[3]._x = aegis[4]._x = aegis[0]._x + ((iconSize + iconPadding) * 2);
		aegis[2]._x = _content.m_aegis_special_0._x - (iconSize + iconPadding) / 2;
		aegis[5]._x = _content.m_aegis_special_0._x + (iconSize + iconPadding) / 2;
		
		
		// clothes layout
		_content.m_ClothesTitle._y = aegis[1]._y + iconSize + iconPadding * 6;
		_content.m_ClothesTitle.autoSize = 'left';
		_content.m_ClothesTitle._x = gearOffset;
		_content.m_ClothesTitle.text = AddonUtils.firstToUpper( _content.m_ClothesTitle.text );
		gearLabelTextFormat.align = 'left';
		_content.m_ClothesTitle.filters = [ titleDropShadow ];
		_content.m_ClothesTitle.setTextFormat( gearLabelTextFormat );
		_content.m_ClothesTitle.hitTestDisable = true;
		
		
		var clothingIndex:Number = null;
		for ( var i:Number = 0; i < icons.length; i++ ) {
			if ( icons[i]._name.substr( 0, 10 ) != 'm_Clothing' ) continue;
			if ( clothingIndex == null ) clothingIndex = i;
			
			icons[i]._x = _content.m_ClothesTitle._x + (i - clothingIndex) * (iconSize + 1 );
			icons[i]._y = _content.m_ClothesTitle._y + _content.m_ClothesTitle.textHeight + iconPadding;
		}
		
		
		// layout preview button
		//_content.m_PreviewAllButton._x = _content.m_ClothesTitle._x;
		_content.m_PreviewAllButton._y = _content.m_ClothingIconHats._y + iconSize + 20;

		// faction bg backgrounds

		var factionBG:MovieClip = _content.createEmptyMovieClip( 'm_UITweaks_FactionBGTopLeft', -16384 );
		var matrix = {matrixType:"box", x:0, y:0, w:100, h:title._height + 90, r:45/180*Math.PI};
		factionBG.beginGradientFill(
			'linear', 
			[ factionColour, 0x000000 ],
			[ 50, 0 ],
			[ 0, 240 ],
			matrix
		);
		AddonUtils.DrawRectangle( factionBG, 0, 0, _content._width, title._height + 100, 6, 0, 0, 0 );
		factionBG.endFill();
		
		//var factionBG:MovieClip = DrawBackgroundBox( _content, 'm_UITweaks_FactionBGTopLeft', -16384, 0, 0, _content._width, title._height + 100, 6, 0, 0, 0, factionColour, 45, 100);
		factionBG.hitTestDisable = true;
		
		// let window host know the size of the content has changed
		_content.SignalSizeChanged.Emit();
		
		// reposition faction icon -- after the resize so it doesn't mess up the size used by the host window for reflow
		_factionIcon.filters = [ titleDropShadow ];
		
		_factionIcon._x -= 30;
		_factionIcon._y -= 30;
		
		_factionIcon._x = (_content._width + _factionIcon._width) / 2;
/*		
		_factionIcon._width *= 1.5;
		_factionIcon._height *= 1.5;
		_factionIcon.filters = [];
*/
	}
	

	private function AddStatLine( statName ):Void {

		// get values
		var baseStat:Number = _stats[ statName ].values.base;
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
		with ( textFormat ) {
			font = 'Futura Std Book Fix';
			size = 12;
			kerning = false;
			leading = 2;
			align = 'left';
			//bold = true;
		}

		// var textFormat:TextFormat = _characterInfo.m_Name.getTextFormat();

		var fields:Object = { };

		// add value numbers
		fields.value = _statBoxValues.createTextField( 'm_' + statName, _statBoxValues.getNextHighestDepth(), 0, _statBoxCursor.y, 0, 0 );
		textFormat.color = valueText != '0' ? 0xEEBA05 : 0x666666;
		fields.value.setNewTextFormat( textFormat );
		fields.value.text = valueText != '0' ? valueText : '-';

		// add stat name text
		fields.name = _statBoxNames.createTextField( 'm_' + statName, _statBoxNames.getNextHighestDepth(), 0, _statBoxCursor.y, 0, 0 );
		textFormat.color = valueText != '0' ? 0xffffff : 0x666666;
		fields.name.setNewTextFormat( textFormat );
		fields.name.text = _stats[ statName ].name;

		// common field properties
		for ( var s:String in fields ) {
			fields[s].autoSize = 'left';
			fields[s].antiAliasType = 'advanced';
			fields[s].embedFonts = true;
		}

		// update line cursor
		if ( _maxStatWidth < fields.value._width ) _maxStatWidth = fields.value._width;
		_statBoxCursor.y += fields.name.textHeight;
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

	
	private function AddAegisAttributes( attributeArray:Array, statNode:String ):Object {
		
		var attributes:Object = { };

		var attribute = AddonUtils.StripHTML( attributeArray[0] );
		if( attribute != undefined ) {
			var statIndex:Number = attribute.indexOf( '+' ) + 1;
			var value = attribute.substring( statIndex, LDBFormat.GetCurrentLanguageCode() == 'de' ? attribute.indexOf(' ', statIndex) : attribute.indexOf('%', statIndex));
			var stat = attribute.substring( statIndex + value.length + 2, attribute.indexOf("\n"));
			
			attributes[ 'aegisPercent' ] = { name: 'aegisPercent', value: Number(value) };

			_stats.aegisPercent.values[statNode] += Number(value);
		}
		
		return attributes;
	}

	
	private function GetItemStats(inventoryID:ID32, itemPosition:Number):Object {
		
		var inventoryItem:InventoryItem = new Inventory(inventoryID).GetItemAt( itemPosition );
		if ( inventoryItem == undefined) return {};

		var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip( inventoryID, itemPosition);
		
		var item:Object = {
				name: inventoryItem.m_Name,
				type: inventoryItem.m_ItemType,
				position: inventoryItem.m_InventoryPos,
				rank: Number(tooltipData.m_ItemRank),
				attributes: {}
		};
		
		var statIndex:Number;
		var value:String;
		var stat:String;
		var attribute:String;
		
		switch( item.type ) {

			// weapons & talismans
			case _global.Enums.ItemType.e_ItemType_Weapon:
			case _global.Enums.ItemType.e_ItemType_Chakra:
				
				// base item
				for ( var s:String in tooltipData.m_Attributes ) {
					if ( tooltipData.m_Attributes[s].m_Right != undefined ) {
						attribute = AddonUtils.StripHTML( tooltipData.m_Attributes[s].m_Right );
						statIndex = attribute.indexOf( '+' ) + 1;
						value = attribute.substring( statIndex, attribute.indexOf(' ', statIndex));
						stat = attribute.substr( statIndex + value.length + 1 );
						
						item.attributes[ stat ] = { name: stat, value: Number(value) };
					}
				}

				// glyph
				if ( tooltipData.m_PrefixData != undefined ) {
					item.glyph = { name: AddonUtils.StripHTML(tooltipData.m_PrefixData.m_Title), rank: Number(tooltipData.m_PrefixData.m_ItemRank) };
					item.glyph.attributes = { };

					for ( var s:String in tooltipData.m_PrefixData.m_Attributes ) {
						if ( tooltipData.m_PrefixData.m_Attributes[s].m_Right != undefined ) {
							attribute = AddonUtils.StripHTML( tooltipData.m_PrefixData.m_Attributes[s].m_Right );
							statIndex = attribute.indexOf( '+' ) + 1;
							value = attribute.substring( statIndex, attribute.indexOf(' ', statIndex));
							stat = attribute.substr( statIndex + value.length + 1 );
							
							item.attributes[ stat ] = { name: stat, value: Number(value) };
						}
					}
				}
				
				// signet
				if ( tooltipData.m_SuffixData != undefined ) {
					item.signet = { name: AddonUtils.StripHTML(tooltipData.m_SuffixData.m_Title), rank: Number(tooltipData.m_SuffixData.m_ItemRank) };
					item.signet.attributes = { };
					
					for ( var s:String in tooltipData.m_PrefixData.m_Attributes ) {
						if ( tooltipData.m_PrefixData.m_Attributes[s].m_Right != undefined ) {
							attribute = AddonUtils.StripHTML( tooltipData.m_PrefixData.m_Attributes[s].m_Right );
							item.signet.attributes[ attribute ] = { name: attribute, value: AddonUtils.NumberFromString( attribute ) };
						}
					}
				}
				
				
			break;
			
			// aegis controllers & capacitors
			case _global.Enums.ItemType.e_ItemType_AegisWeapon:
			case _global.Enums.ItemType.e_ItemType_AegisGeneric:
				
				var attribute = AddonUtils.StripHTML( tooltipData.m_Descriptions[0] );
				if( attribute != undefined ) {
					item.attributes[ 'Aegis Damage' ] = { name: 'Aegis Damage', value: AddonUtils.NumberFromString( attribute ) };
				}

			break;
		}
		
		return item;
	}
	
}