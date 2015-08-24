import com.GameInterface.InventoryItem;
import com.GameInterface.Inventory;
import com.GameInterface.Tooltip.TooltipData;
import com.Utils.LDBFormat;
import com.GameInterface.Tooltip.TooltipDataProvider;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.AddonUtils.AddonUtils;
import com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.LDB;

/**
 * 
 * 
 */
class com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.ItemStats {

	// static class only
	private function ItemStats() {}
	
	/**
	 * Extracts stat values from an item and returns an object populated with organised values
	 * 
	 * @param	inventory		inventory the item is in
	 * @param	itemPosition	position in the inventory the item is in
	 * @return	organised object of stat data related to the item
	 */
	public static function GetItemStats(inventory:Inventory, itemPosition:Number):Object {
		
		var inventoryItem:InventoryItem = inventory.GetItemAt( itemPosition );
		if ( inventoryItem == undefined) return {};

		var signetStats:Object = { };
		signetStats[ "heal rating" ] = true;
		signetStats[ LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HealingRating ).toLowerCase() ] = true;
		signetStats[ LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_AttackRating ).toLowerCase() ] = true;
		signetStats[ "Health".toLowerCase() ] = true;
		signetStats[ "Santé".toLowerCase() ] = true;
		signetStats[ "Gesundheit".toLowerCase() ] = true;
		
		var tooltipData:TooltipData = TooltipDataProvider.GetInventoryItemTooltip( inventory.GetInventoryID(), itemPosition);
		
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
		var typePosition:String;
		
		switch( item.type ) {

			// weapons & talismans
			case _global.Enums.ItemType.e_ItemType_Weapon:
				switch( item.position ) {
					case _global.Enums.ItemEquipLocation.e_Wear_First_WeaponSlot: item.typePosition = 'primary';  break;
					case _global.Enums.ItemEquipLocation.e_Wear_Second_WeaponSlot: item.typePosition = 'secondary';  break;
					case _global.Enums.ItemEquipLocation.e_Wear_Aux_WeaponSlot: item.typePosition = 'auxiliary';  break;
				}
				
			case _global.Enums.ItemType.e_ItemType_Chakra:
				if( item.typePosition == undefined ) item.typePosition = 'talisman';
				
				// base item
				for ( var s:String in tooltipData.m_Attributes ) {
					if ( tooltipData.m_Attributes[s].m_Right != undefined ) {
						
						attribute = AddonUtils.StripHTML( tooltipData.m_Attributes[s].m_Right );
						statIndex = attribute.indexOf( '+' ) + 1;
						value = attribute.substring( statIndex, attribute.indexOf(' ', statIndex));
						stat = attribute.substr( statIndex + value.length + 1 ).toLowerCase();
						
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
							stat = attribute.substr( statIndex + value.length + 1 ).toLowerCase();
							
							item.attributes[ stat ] = { name: stat, value: Number(value) };
						}
					}
				}
				
				// signet
				if ( tooltipData.m_SuffixData != undefined ) {
					
					item.signet = { name: AddonUtils.StripHTML(tooltipData.m_SuffixData.m_Title), rank: Number(tooltipData.m_SuffixData.m_ItemRank) };
					item.signet.attributes = { };
					
					if ( tooltipData.m_SuffixData.m_Descriptions != undefined ) {
						attribute = AddonUtils.StripHTML( tooltipData.m_SuffixData.m_Descriptions[0] );
						var numbers:Array = AddonUtils.NumbersFromString( attribute );
						if( numbers.length == 1 ) {
							
							for( var a:String in signetStats ) {
								if ( attribute.toLowerCase().indexOf(a) >= 0 ) {
									item.signet.attributes[ a ] = { name: a, value: numbers[0] };
									break;
								}
							}
						}
					}
				}
				
			break;
			
			// aegis controllers & capacitors
			case _global.Enums.ItemType.e_ItemType_AegisWeapon:
				switch( item.position ) {
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1:
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_2:
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_1_3:
						item.typePosition = 'primary';
					break;
						
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2:
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_2:
					case _global.Enums.ItemEquipLocation.e_Aegis_Weapon_2_3:
						item.typePosition = 'secondary';
					break;
				}
			
				item.attributes[ 'aegis xp percent' ] = { name: 'aegis xp percent', value: AddonUtils.NumbersFromString( AddonUtils.StripHTML(tooltipData.m_Descriptions[2]) )[0] };
				
			case _global.Enums.ItemType.e_ItemType_AegisGeneric:
				
				if( item.typePosition == undefined ) item.typePosition = 'talisman';
				
				var attribute = AddonUtils.StripHTML( tooltipData.m_Descriptions[0] );
				if ( attribute != undefined ) {
					
					if ( item.name == LDB.GetText('ItemNames', 'AECapacitor') ) {
						item.attributes[ 'aegis damage' ] = { name: 'aegis damage', value: AddonUtils.NumbersFromString( attribute )[0] };
					}
					
					else if ( item.name == LDB.GetText('ItemNames', 'AERampartCapacitor') ) {
						item.attributes[ 'aegis shield' ] = { name: 'aegis shield', value: AddonUtils.NumbersFromString( attribute )[0] };
					}
					
					else if ( item.name == LDB.GetText('ItemNames', 'AEConvalescenceCapacitor') ) {
						item.attributes[ 'aegis healing' ] = { name: 'aegis healing', value: AddonUtils.NumbersFromString( attribute )[0] };						
					}
					
					// aegis disruptor
					else {
						item.attributes[ 'aegis damage' ] = { name: 'aegis damage', value: AddonUtils.NumbersFromString( attribute )[0] };
						item.attributes[ 'aegis healing' ] = { name: 'aegis healing', value: AddonUtils.NumbersFromString( attribute )[1] };
					}
				}

			break;
			
			// aegis shield
			case _global.Enums.ItemType.e_ItemType_AegisShield:
				item.typePosition = 'talisman';
				item.attributes[ 'aegis shield' ] = { name: 'aegis shield', value: AddonUtils.NumbersFromString( AddonUtils.StripHTML(tooltipData.m_Descriptions[0]) )[0] };
			break;
			
		}
		
		return item;
	}

}