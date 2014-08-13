import com.Utils.LDBFormat;

/*
fr:
ql: NQ
heal rating: Valeur de guérison
health: Santé
name:Valeur de guérison
maxQL : Max. QL
avgQL : Avg. QL
weaponPower : Puissance de l'arme
attack : Valeur d'attaque
heal : Valeur de guérison
hit : Valeur de toucher
crit : Valeur de critique
critPower : Valeur de puissance de critique
pen : Valeur de pénétration
evade : Valeur d'évitement
defence : Valeur de défense
block : Valeur de parade
physProt : Protection physique
magProt : Protection magique
aegisPercent : Avg. AEGIS %

de:
German has a space in between number and % symbol, such as in AEGIS controllers

ql: QS
heal rating: Heilungswert
health: Gesundheit
maxQL : Max. QL
avgQL : Avg. QL
weaponPower : Waffenkraft
attack : Angriffswert
heal : Heilungswert
hit : Trefferwert
crit : Kritischer Treffer-Wert
critPower : Kritischer Treffer-Kraftwert
pen : Durchdringungswert
evade : Ausweichwert
defence : Verteidigungswert
block : Blockwert
physProt : Körperlicher Schutz
magProt : Magischer Schutz
aegisPercent : Avg. AEGIS %
*/

class com.ElTorqiro.UITweaks.Plugins.InspectoPetronum.LDB {

	private function LDB() { }
	
	private static var initialised:Boolean = false;
	private static var languageCode:String;
	
	// LDB categories
	private static var StatNames:Object = { };
	private static var Labels:Object = { };

	
	/**
	 * initialises language database, so non-compile-time constant values can be added from TSW's LDB
	 */
	private static function initialise():Void {
		
		languageCode = LDBFormat.GetCurrentLanguageCode();
		
		StatNames = {
			WeaponPower:		{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_WeaponPower) },
			AttackRating: 		{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_AttackRating) },
			HealRating:			{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HealingRating ),
									en: "Heal Rating"
			},

			HitRating: 			{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_HitRating) },
			CriticalRating: 	{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CriticalRating) },
			CritPower: 			{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_CritPowerRating) },
			PenetrationRating:	{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PenetrationRating) },

			EvadeRating: 		{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_EvadeRating) },
			DefenceRating: 		{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_DefenseRating) },
			BlockRating: 		{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_BlockRating) },
			PhysicalProtection: { standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_PhysicalMitigation) },
			MagicalProtection: 	{ standard: LDBFormat.LDBGetText("SkillTypeNames", _global.Enums.SkillType.e_Skill_MagicalMitigation) },
			
			AvgAegisConversionPercent: { standard: "Avg. AEGIS %",
									en: "Avg. AEGIS %",
									fr: "Moyenne NQ",
									de: "Durchschnitt QS"
			},
			
			Health: { standard: "Health",
									en: "Health",
									fr: "Santé",
									de: "Gesundheit"
			},
			
			MaxQL: { standard: "Max. QL",
									en: "Max. QL",
									fr: "Maximum NQ",
									de: "Maximum QS"
			},
			AvgQL: { standard: "Avg. QL",
									en: "Avg. QL",
									fr: "Moyenne NQ",
									de: "Durchschnitt QS"
			}
		};
		
		
		Labels = {
			EquipmentStatistics: { standard: "Equipment Statistics",
									en: "Equipment Statistics",
									fr: "Statistiques de l'équipement",
									de: "Ausrüstung Statistiken"
			}
		};
	}
	
	/**
	 * Returns the language-specific string for a particular text instance
	 * 
	 * @param	category	The category the text instance is within
	 * @param	instance	The name of the text instance
	 * @return	Language-specific string for the given text instance, or the default if language-specific instance not available
	 */
	public static function GetText( category: String, instance:String ):String {
		
		if ( !initialised ) initialise();
		
		var languageInstance:String = LDB[category][instance][ languageCode ];
		
		if ( languageInstance == undefined ) languageInstance = LDB[category][instance].standard;
		
		return languageInstance;
	}
}