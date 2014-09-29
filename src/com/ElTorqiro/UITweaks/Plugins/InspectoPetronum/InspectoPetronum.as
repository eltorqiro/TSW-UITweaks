import com.GameInterface.DistributedValue;
import com.GameInterface.Inventory;
import com.GameInterface.InventoryItem;
import mx.utils.Delegate;
import com.GameInterface.UtilsBase;
import flash.geom.Point;
import com.GameInterface.Game.Shortcut;
import com.GameInterface.ProjectUtils;
import com.Utils.GlobalSignal;
import com.Utils.ID32;
import com.Utils.LDBFormat;
import com.Utils.Faction;
import com.GameInterface.LoreBase;
import com.Utils.Colors;
import flash.filters.GlowFilter;
import com.GameInterface.Tooltip.TooltipData;
import com.GameInterface.Tooltip.TooltipDataProvider;
import flash.filters.DropShadowFilter;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.LDB;
import com.Components.ItemSlot;


class com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.InspectoPetronum {

	// default window finding objects
	private var _windowSearches:Object = {};
	private var _windowSearchInterval:Number = 5;
	private var _windowSearchTimeout:Number = 1000;
	
	// layout constants
	public var iconSize = 25;
	public var iconPadding:Number = 3;
	public var gearOffset:Number = 10;
	public var gearSectionSpacing:Number = iconPadding * 6;
	public var statSectionSpacing:Number = iconPadding * 3;
	
	// time to wait before inspection window re-draw.
	public var inspectReDraw:Number;
	
	public function InspectoPetronum() {
		
	}
	
	public function Activate() {
		
		if ( !inspectReDraw ) inspectReDraw = 100;
	
		// create listener
		GlobalSignal.SignalShowInspectWindow.Connect( AttachToWindow, this );
	}
	
	public function Deactivate() {
		// detach from listener
		GlobalSignal.SignalShowInspectWindow.Disconnect( AttachToWindow, this );
		
		// no way to sensibly restore the default window to its stock layout, user can re-open window if they disable this plugin
	}
	
	private function AttachToWindow( characterID:ID32 ):Void {
		
		// wait for default window to become available (and finish rendering)
		var window = _root.inspectioncontroller['i_InspectionWindow_' + characterID.GetInstance() ];
		
		if( window == undefined ) {
			if ( _windowSearches[characterID] == undefined ) _windowSearches[characterID] = { time: new Date() };

			// give up if the timeout has passed
			if ( new Date() - _windowSearches[characterID].time > _windowSearchTimeout ) return;
			
			_global.setTimeout( Delegate.create( this, AttachToWindow ), _windowSearchInterval, characterID );
			return;
		}
		
		// if we made it this far, the window has been found, so build content on it
		delete _windowSearches[characterID];
		
		_global.setTimeout( Delegate.create( this, Build ), inspectReDraw, window );
	}
	
	
	private function Build( inspectionWindow:MovieClip ):Void {

		var window:MovieClip = inspectionWindow;
		var content = inspectionWindow.GetContent();
		var characterInfo = content.m_CharacterInfo;
		var factionIcon = characterInfo.m_FactionIconLoader;

		var stats:Object = { };
		var statsMap:Object = { };
		
		// do nothing if this window has already been built upon
		if ( window.UITweaksInspectionStatsBuilt ) return;
		window.UITweaksInspectionStatsBuilt = true;
		
		// hide existing content
		content.m_StatInfoList._visible = 
		content.m_StatsBgBox._visible = 
		characterInfo.m_Name._visible = 
		characterInfo.m_BasicInfo._visible = false;

		// remove window chrome features
		window.SetTitle( '' );
		window.ShowBackground( false );
		//window.ShowFooter( false );

		// allow clicks through sections
		characterInfo.hitTestDisable = true;


		// get faction specific values and reposition icon slightly
		var faction:Number = content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction )
		var factionColour:Number = 0xffffff;
		var factionTextColour:Number = 0xffffff;
		switch( faction ) {
			// dragon
			case _global.Enums.Factions.e_FactionDragon:
				factionColour = Colors.e_ColorPvPDragon; factionTextColour = Colors.e_ColorPvPDragonText;
				with ( factionIcon ) {
					_x += 4;
					_y += 1;
				}
			break;
			
			// templar
			case _global.Enums.Factions.e_FactionTemplar:
				factionColour = Colors.e_ColorPvPTemplar; factionTextColour = Colors.e_ColorPvPTemplarText;
				with ( factionIcon ) {
					_x += 2;
					_width -= 2;
					_height -= 2;
				}
			break;
			
			// illuminati
			case _global.Enums.Factions.e_FactionIlluminati:
				factionColour = Colors.e_ColorPvPIlluminati; factionTextColour = Colors.e_ColorPvPIlluminatiText;
				with ( factionIcon ) {
					_y -= 2;
					_x += 2;
				}
			break;
		}
		
		
		// redesign the title section
		var titleFormat:TextFormat = characterInfo.m_Name.getTextFormat();
		titleFormat.size = 12;
		
		var titleDropShadow:DropShadowFilter = new DropShadowFilter(60, 90, 0x000000, 0.7, 8, 8, 2, 3, false, false, false);
		//var nameDropShadow:DropShadowFilter = new DropShadowFilter(0, 0, 0x000000, 1, 4, 4, 4, 3, false, false, false);
		
		var title:TextField = characterInfo.createTextField( 'm_UITweaks_TitleFullName', content.getNextHighestDepth(), 0, 0, 0, characterInfo._height );
		title.autoSize = 'left';
		title.embedFonts = true;
		title.multiline = true;
		//title.wordWrap = true;
		//titleFormat.size = 12;
		//titleFormat.leading = -1;
		//title.setTextFormat( titleFormat );
		title.setNewTextFormat( titleFormat );		
		title.filters = [ titleDropShadow ];

		
		title.appendHtml( '<font size="16">"' + content.m_InspectionCharacter.GetName() + '"</font>' );
		title.appendHtml( '<font size="12">\n' + content.m_InspectionCharacter.GetFirstName() + ' ' + content.m_InspectionCharacter.GetLastName() + '</font>' );
		
		var characterTitle = content.m_InspectionCharacter.GetTitle();
		if( characterTitle.length > 0 ) {
			title.appendHtml( '<font size="12">, ' + characterTitle + '</font>' );
		}
		
		var cabalName:String = content.m_InspectionCharacter.GetGuildName();
		if ( cabalName.length > 0 ) {
			title.appendHtml( '<font size="12" color="#cccccc">\n&lt;' + cabalName + '&gt;</font>' );
		}
		
		var factionName:String = Faction.GetName(content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_PlayerFaction ));
		title.appendHtml('\n<font size="12" color="#' + AddonUtils.colorToHex(factionColour) + '">' + AddonUtils.firstToUpper( factionName ) );

		var factionTitle = LoreBase.GetTagName(content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_RankTag ));
		if ( factionTitle.length > 0 ) {
			title.appendHtml( ' ' + factionTitle );
		}

		title.appendHtml( ', ' + LDBFormat.LDBGetText("GenericGUI", "InspectionWindow_BattleRank") + ' ' + content.m_InspectionCharacter.GetStat(_global.Enums.Stat.e_PvPLevel) );
		title.appendHtml( '</font>' );
		
		
		// define skills/stats to track
		stats = {
			weaponPower: { label: LDB.GetText('StatNames', 'WeaponPower') },
			attack: { label: LDB.GetText('StatNames', 'AttackRating') },
			heal: { label: LDB.GetText('StatNames', 'HealRating') },

			hit: { label: LDB.GetText('StatNames', 'HitRating') },
			crit: { label: LDB.GetText('StatNames', 'CriticalRating') },
			critPower: { label: LDB.GetText('StatNames', 'CritPower') },
			pen: { label: LDB.GetText('StatNames', 'PenetrationRating') },

			evade: { label: LDB.GetText('StatNames', 'EvadeRating') },
			defence: { label: LDB.GetText('StatNames', 'DefenceRating') },
			block: { label: LDB.GetText('StatNames', 'BlockRating') },
			physProt: { label: LDB.GetText('StatNames', 'PhysicalProtection') },
			magProt: { label: LDB.GetText('StatNames', 'MagicalProtection') },
			
			priAegisPercent: { },
			secAegisPercent: { },
			
			aegisPercent: { label: LDB.GetText('StatNames', 'AvgAegisConversionPercent'), stat: 'aegis damage' },
			
			health: { label: LDB.GetText('StatNames', 'Health') },
			
			maxQL: { label: LDB.GetText('StatNames', 'MaxQL') },
			avgQL: { label: LDB.GetText('StatNames', 'AvgQL') }
		};
		
		// reverse mapping for easy adding of values to skills objects
		statsMap = { };
		for ( var s:String in stats ) {
			if ( stats[s].stat == undefined ) {
				stats[s].stat = stats[s].label.toLowerCase();
			}
			
			statsMap[ stats[s].stat ] = stats[s];
			stats[s].values = {
				base: { value: 0, count: 0 },
				talisman: { value: 0, count: 0 },
				primary: { value: 0, count: 0 },
				secondary: { value: 0, count: 0 }
			};
		}
	
		// fetch stat values
		var items:Array = [];
		
		for ( var s:String in content.m_InspectionInventory.m_Items ) {
			items.push( AddonUtils.GetItemStats(content.m_InspectionInventory, content.m_InspectionInventory.m_Items[s].m_InventoryPos) );
		}
		
		for( var s:String in items ) {
			
			var item = items[s];
			
			// ignore auxiliary weapon
			if ( item.typePosition == 'auxiliary') continue;
			
			// weapons and talismans
			if ( item.type == _global.Enums.ItemType.e_ItemType_Chakra || item.type == _global.Enums.ItemType.e_ItemType_Weapon ) {
				
				// base item stats
				for ( var a:String in item.attributes ) {

					// capture max and avereage QL for talismans and weapons only
					if ( item.type == _global.Enums.ItemType.e_ItemType_Chakra || item.type == _global.Enums.ItemType.e_ItemType_Weapon ) {
						if ( stats.maxQL.values.base.value < item.rank ) stats.maxQL.values.base.value = item.rank;
						stats.avgQL.values.base.value += item.rank;
						stats.avgQL.values.base.count++;
					}
					
					statsMap[a].values[ item.typePosition ].value += item.attributes[a].value;
					statsMap[a].values[ item.typePosition ].count++;
				}
				
				// glyph
				for ( var a:String in item.glyph.attributes ) {

					// capture max and avereage QL for talismans and weapons only
					if ( item.type == _global.Enums.ItemType.e_ItemType_Chakra || item.type == _global.Enums.ItemType.e_ItemType_Weapon ) {
						if ( stats.maxQL.values.base.value < item.glyph.rank ) stats.maxQL.values.base.value = item.glyph.rank;
						stats.avgQL.values.base.value += item.glyph.rank;
						stats.avgQL.values.base.count++;
					}
					
					statsMap[a].values[ item.typePosition ].value += item.glyph.attributes[a].value;
					statsMap[a].values[ item.typePosition ].count++;
				}

				// signet
				for ( var a:String in item.signet.attributes ) {
					statsMap[ item.signet.attributes[a].name ].values[ item.typePosition ].value += item.signet.attributes[a].value;
					statsMap[ item.signet.attributes[a].name ].values[ item.typePosition ].count++;
				}
			}


			// aegis items
			else if ( item.type == _global.Enums.ItemType.e_ItemType_AegisGeneric || item.type == _global.Enums.ItemType.e_ItemType_AegisWeapon ) {
					statsMap[ 'aegis damage' ].values[ item.typePosition ].value += item.attributes[ 'aegis damage' ].value;
					statsMap[ 'aegis damage' ].values[ item.typePosition ].count++;
			}
			
		}
			
		// implied aegis percentages
		if ( stats.aegisPercent.values.primary.value > 0 )
			stats.aegisPercent.values.primary.value = Math.round( stats.aegisPercent.values.primary.value / stats.aegisPercent.values.primary.count * 100 ) / 100;

		if ( stats.aegisPercent.values.secondary.value > 0 )
			stats.aegisPercent.values.secondary.value = Math.round( stats.aegisPercent.values.secondary.value / stats.aegisPercent.values.secondary.count * 100 ) / 100;

		// implied ql average
		if ( stats.avgQL.values.base.value > 0 )
			stats.avgQL.values.base.value = Math.floor( stats.avgQL.values.base.value / stats.avgQL.values.base.count * 100 ) / 100;
		
		// info not from gear
		//stats.health.values.base = content.m_InspectionCharacter.GetStat( _global.Enums.Stat.e_Health );
		

		// add stat box movieclip
		var statTitle:TextField = content.createTextField( 'm_UITWeaksstatsTitle', content.getNextHighestDepth(), (3 * iconSize) + (2 * iconPadding) + gearOffset + iconPadding * 6, title._y + title.textHeight + iconPadding * 6, 0, 0);
		statTitle.hitTestDisable = true;
		statTitle.filters = [ titleDropShadow ];
		statTitle.autoSize = 'left';
		statTitle.setNewTextFormat( titleFormat );
		statTitle.text = LDB.GetText( 'Labels', 'EquipmentStatistics' );
		
		var statBox:MovieClip = content.createEmptyMovieClip( 'm_UITweaksstats', content.getNextHighestDepth() );
		statBox.filters = [ titleDropShadow ];
		statBox.hitTestDisable = true;
		statBox._x = statTitle._x;
		statBox._y = statTitle._y + statTitle.textHeight + iconPadding * 2;

		var statBoxValues:MovieClip = statBox.createEmptyMovieClip( 'm_Values', statBox.getNextHighestDepth() );
		var statBoxNames:MovieClip = statBox.createEmptyMovieClip( 'm_Names', statBox.getNextHighestDepth() );
		
		statBox.cursor = new Point( 0, 0 );
		statBox.maxStatWidth = 0;

		AddStatLine( statBox, stats, 'maxQL' );
		AddStatLine( statBox, stats, 'avgQL' );
		
		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'weaponPower' );
		AddStatLine( statBox, stats, 'attack' );
		AddStatLine( statBox, stats, 'heal' );

		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'hit' );
		
		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'crit' );
		AddStatLine( statBox, stats, 'critPower' );
		AddStatLine( statBox, stats, 'pen' );

		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'evade' );
		AddStatLine( statBox, stats, 'defence' );
		AddStatLine( statBox, stats, 'block' );
		
		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'physProt' );
		AddStatLine( statBox, stats, 'magProt' );

		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'health' );
		
		statBox.cursor.y += statSectionSpacing;
		AddStatLine( statBox, stats, 'aegisPercent' );


		// align values and names -- this is done here as the max required width of values is now available
		statBoxNames._x = statBoxValues._width + iconPadding * 2;
		for ( var s:String in statBoxValues ) {
			if ( statBoxValues[s] instanceof TextField ) {
				var textField:TextField = statBoxValues[s];
				var textFormat:TextFormat = new TextFormat();
				textFormat.align = 'center';
				textField.autoSize = 'none';
				textField._width = statBoxValues._width;
				textField.setTextFormat(textFormat);
			}
		}

		// layout gear icons
		var icons:Array = [
			content.m_IconChakra_1, content.m_IconChakra_2, content.m_IconChakra_3, content.m_IconChakra_4, content.m_IconChakra_5, content.m_IconChakra_6, content.m_IconChakra_7,
			
			content.m_IconWeapon_1, content.m_IconWeapon_2, content.m_IconAuxiliaryWeapon,

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
			icons[s]._visible = true;
		}


		var gearLabelTextFormat:TextFormat = titleFormat;
		gearLabelTextFormat.align = 'center';
		
		// talisman layout
		content.m_ChakrasTitle._y = title._y + title.textHeight + iconPadding * 6;

		content.m_ChakrasTitle._width = content.m_WeaponsTitle._width = (3 * iconSize) + (2 * iconPadding);
		content.m_ChakrasTitle._x = content.m_WeaponsTitle._x = gearOffset;

		content.m_ChakrasTitle.text = AddonUtils.firstToUpper( content.m_ChakrasTitle.text );
		content.m_ChakrasTitle.setTextFormat( gearLabelTextFormat );
		content.m_ChakrasTitle.filters = [ titleDropShadow ];
		content.m_ChakrasTitle.hitTestDisable = true;

		content.m_WeaponsTitle.text = AddonUtils.firstToUpper( content.m_WeaponsTitle.text );
		content.m_WeaponsTitle.setTextFormat( gearLabelTextFormat );
		content.m_WeaponsTitle.filters = [ titleDropShadow ];
		content.m_WeaponsTitle.hitTestDisable = true;
		
		content.m_IconChakra_7._y = content.m_ChakrasTitle._y + content.m_ChakrasTitle.textHeight + iconPadding;
		content.m_IconChakra_4._y = content.m_IconChakra_5._y = content.m_IconChakra_6._y = content.m_IconChakra_7._y + iconSize + iconPadding;
		content.m_IconChakra_1._y = content.m_IconChakra_2._y = content.m_IconChakra_3._y = content.m_IconChakra_4._y + iconSize + iconPadding;
		
		content.m_IconChakra_4._x = content.m_IconChakra_1._x = content.m_IconWeapon_1._x = content.m_ChakrasTitle._x;
		content.m_IconChakra_5._x = content.m_IconChakra_2._x = content.m_IconChakra_7._x = content.m_IconWeapon_2._x = content.m_IconChakra_4._x + iconSize + iconPadding;
		content.m_IconChakra_6._x = content.m_IconChakra_3._x = content.m_IconAuxiliaryWeapon._x = content.m_IconChakra_5._x + iconSize + iconPadding;

		content.m_WeaponsTitle._y = content.m_IconChakra_1._y + iconSize + iconPadding;
		content.m_AuxiliarlyWeaponTitle._visible = false;
		
		content.m_IconWeapon_1._y = content.m_IconWeapon_2._y = content.m_IconAuxiliaryWeapon._y = content.m_WeaponsTitle._y + content.m_WeaponsTitle.textHeight + iconPadding;


		// aegis layout
		content.m_AegisTitle._y = content.m_IconWeapon_1._y + iconSize + (iconPadding * 6);
		content.m_AegisTitle._width = (3 * iconSize) + (2 * iconPadding);
		content.m_AegisTitle._x = gearOffset;

		content.m_AegisTitle.setTextFormat( gearLabelTextFormat );
		content.m_AegisTitle.filters = [ titleDropShadow ];
		content.m_AegisTitle.hitTestDisable = true;
		
		content.m_aegis_0._y = content.m_AegisTitle._y + content.m_AegisTitle.textHeight + iconPadding;
		content.m_aegis_generic_0._y = content.m_aegis_generic_1._y = content.m_aegis_0._y + (iconSize / 3 * 2) + iconPadding;
		content.m_aegis_special_0._y = content.m_aegis_0._y + iconSize + iconPadding;
		content.m_aegis_special_1._y = content.m_aegis_special_0._y + iconSize + iconPadding;
		content.m_aegis_generic_2._y = content.m_aegis_generic_3._y = content.m_aegis_special_1._y + (iconSize / 3);

		content.m_aegis_generic_0._x = content.m_aegis_generic_2._x = content.m_AegisTitle._x;
		content.m_aegis_special_0._x = content.m_aegis_special_1._x = content.m_aegis_0._x = content.m_aegis_generic_0._x + iconSize + iconPadding;
		content.m_aegis_generic_1._x = content.m_aegis_generic_3._x = content.m_aegis_0._x + iconSize + iconPadding;

		
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
			var aegisSlot:MovieClip = content.m_IconWeapon_1.duplicateMovieClip( 'm_UITWeaks_Aegis_' + i, content.getNextHighestDepth() );
			
			aegis[i] = aegisSlot;
			try {
				aegisSlot.slot = new ItemSlot( content.m_InspectionInventory.GetInventoryID(), aegisLocations[i], aegisSlot );
				aegisSlot.slot.SetData(content.m_InspectionInventory.GetItemAt(aegisLocations[i]));
			} catch (e) {
				
			}
			
			// resize after the ItemSlot has been populated, to make sure the entire movieclip remains within the desired size
			aegisSlot._width = iconSize;
			aegisSlot._height = iconSize;
		}
		
		aegis[0]._y = aegis[3]._y = content.m_aegis_generic_2._y + iconSize + iconPadding * 3;
		aegis[1]._y = aegis[4]._y = aegis[0]._y + iconSize + iconPadding;
		aegis[2]._y = aegis[5]._y = aegis[0]._y + (iconSize / 2);
		
		aegis[0]._x = aegis[1]._x = content.m_aegis_generic_2._x;
		aegis[3]._x = aegis[4]._x = aegis[0]._x + ((iconSize + iconPadding) * 2);
		aegis[2]._x = content.m_aegis_special_0._x - (iconSize + iconPadding) / 2;
		aegis[5]._x = content.m_aegis_special_0._x + (iconSize + iconPadding) / 2;
		
		
		// clothes layout
		content.m_ClothesTitle._y = aegis[1]._y + iconSize + iconPadding * 6;
		content.m_ClothesTitle.autoSize = 'left';
		content.m_ClothesTitle._x = gearOffset;
		content.m_ClothesTitle.text = AddonUtils.firstToUpper( content.m_ClothesTitle.text );
		gearLabelTextFormat.align = 'left';
		content.m_ClothesTitle.filters = [ titleDropShadow ];
		content.m_ClothesTitle.setTextFormat( gearLabelTextFormat );
		content.m_ClothesTitle.hitTestDisable = true;
		
		
		var clothingIndex:Number = null;
		for ( var i:Number = 0; i < icons.length; i++ ) {
			if ( icons[i]._name.substr( 0, 10 ) != 'm_Clothing' ) continue;
			if ( clothingIndex == null ) clothingIndex = i;
			
			icons[i]._x = content.m_ClothesTitle._x + (i - clothingIndex) * (iconSize + iconPadding );
			icons[i]._y = content.m_ClothesTitle._y + content.m_ClothesTitle.textHeight + iconPadding;
		}
		
		// layout preview button
		content.m_PreviewAllButton._y = content.m_ClothingIconHats._y + iconSize + 20;

		// faction bg background
		var factionBG:MovieClip = content.createEmptyMovieClip( 'm_UITweaks_FactionBGTopLeft', -16384 );
		var matrix = {matrixType:"box", x:0, y:0, w:100, h:title._height + 90, r:45/180*Math.PI};
		factionBG.beginGradientFill(
			'linear', 
			[ factionColour, 0x000000 ],
			[ 50, 0 ],
			[ 0, 240 ],
			matrix
		);
		AddonUtils.DrawRectangle( factionBG, 0, 0, content._width, title._height + 100, 6, 0, 0, 0 );
		factionBG.endFill();
		
		factionBG.hitTestDisable = true;
		
		// let window host know the size of the content has changed
		content.SignalSizeChanged.Emit();
		
		// reposition faction icon -- after the resize so it doesn't mess up the size used by the host window for reflow
		factionIcon.filters = [ titleDropShadow ];
		
		//factionIcon._x -= 30;
		factionIcon._y -= 34;
		
		//factionIcon._x = (content._width + factionIcon._width) / 2;
		factionIcon._x = content._width - factionIcon._width * 2;
		
		//factionIcon._x = 10;
		factionIcon._width *= 1.2;
		factionIcon._height *= 1.2;
		//factionIcon.filters = [];
	}
	

	private function AddStatLine( statBoxMC:MovieClip, stats:Object, statName:String ):Void {

		// get values
		var baseStat:Number = stats[ statName ].values.base.value + stats[ statName ].values.talisman.value;
		var primaryStat:Number = baseStat + stats[ statName ].values.primary.value;
		var secondaryStat:Number = baseStat + stats[ statName ].values.secondary.value;

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

		var textFormat:TextFormat = new TextFormat();
		with ( textFormat ) {
			font = 'Futura Std Book Fix';
			size = 12;
			kerning = false;
			leading = 2;
			align = 'left';
		}

		var fields:Object = { };

		// add value numbers
		fields.value = statBoxMC.m_Values.createTextField( 'm_' + statName, statBoxMC.m_Values.getNextHighestDepth(), 0, statBoxMC.cursor.y, 0, 0 );
		textFormat.color = valueText != '0' ? 0xEEBA05 : 0x666666;
		fields.value.setNewTextFormat( textFormat );
		fields.value.text = valueText != '0' ? valueText : '-';

		// add stat name text
		fields.name = statBoxMC.m_Names.createTextField( 'm_' + statName, statBoxMC.m_Names.getNextHighestDepth(), 0, statBoxMC.cursor.y, 0, 0 );
		textFormat.color = valueText != '0' ? 0xffffff : 0x666666;
		fields.name.setNewTextFormat( textFormat );
		fields.name.text = stats[ statName ].label;

		// common field properties
		for ( var s:String in fields ) {
			fields[s].autoSize = 'left';
			fields[s].antiAliasType = 'advanced';
			fields[s].embedFonts = true;
		}

		// update line cursor
		if ( statBoxMC.maxStatWidth < fields.value._width ) statBoxMC.maxStatWidth = fields.value._width;
		statBoxMC.cursor.y += fields.name.textHeight;
	}
	
	public function get waitTime():Number { return inspectReDraw; }
	public function set waitTime(value:Number):Void {
		if ( value == undefined ) return;
		
		inspectReDraw = value;
	}
}