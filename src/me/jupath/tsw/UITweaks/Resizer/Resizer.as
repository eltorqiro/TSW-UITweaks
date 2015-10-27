import com.ElTorqiro.UITweaks.Plugins.Plugin;

import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import me.jupath.tsw.UITweaks.Resizer.Scaler;

class me.jupath.tsw.UITweaks.Resizer.Resizer extends Plugin {
	
	// plugin properties
	public var id:String = "resizer";
	public var name:String = "Resize Windows";
	public var description:String = "Resizes windows not available in the default settings.";
	public var author:String = "Julian Paolo Thiry (Aedani)";
	public var prefsVersion:Number = 1;
	
	private var adjustPosition = false;

	public function Resizer() {
		prefs.add( "scale.challengeJournal", 100 );
		prefs.add( "scale.deliveredItems", 100 );
		prefs.add( "scale.friends", 100 );
		prefs.add( "scale.lockoutTimers", 100 );
		prefs.add( "scale.missionJournal", 100 );
		prefs.add( "scale.missionReward", 100 );
		prefs.add( "scale.pets", 100 );
		prefs.add( "scale.social", 100 );
		prefs.add( "scale.shop", 100 );
	}
	
	public function onLoad() : Void {
		super.onLoad();
		_missionReward = new Scaler(null, GUI.Mission.MissionSignals.SignalMissionReportSent, "missionrewardcontroller", true, prefs.getVal("scale.missionReward"));
		_missionJournal = new Scaler(DistributedValue.Create("mission_journal_window"), null, "missionjournalwindow", false, prefs.getVal("scale.missionJournal"));
		_friends = new Scaler(DistributedValue.Create("friends_window"), null, "friends", false, prefs.getVal("scale.friends"));
		_pets = new Scaler(DistributedValue.Create("petInventory_window"), null, "petinventory", false, prefs.getVal("scale.pets"));
		_social = new Scaler(DistributedValue.Create("group_search_window"), null, "groupsearch", false, prefs.getVal("scale.social"));
		_deliveredItems = new Scaler(DistributedValue.Create("claim_window"), null, "claimwindow", false, prefs.getVal("scale.deliveredItems"));
		_lockoutTimers = new Scaler(DistributedValue.Create("lockoutTimers_window"), null, "lockouttimers", false, prefs.getVal("scale.lockoutTimers"));
		_challengeJournal = new Scaler(DistributedValue.Create("challengeJournal_window"), null, "challengejournal", false, prefs.getVal("scale.challengeJournal"));
		_shop = new Scaler(null, com.GameInterface.ShopInterface.SignalOpenShop, "shopcontroller", false, prefs.getVal("scale.shop"));
	}
	
	public function apply() : Void {
		_missionReward.Activate(adjustPosition);
		_missionJournal.Activate(adjustPosition);
		_friends.Activate(adjustPosition);
		_pets.Activate(adjustPosition);
		_social.Activate(adjustPosition);
		_deliveredItems.Activate(adjustPosition);
		_lockoutTimers.Activate(adjustPosition);
		_challengeJournal.Activate(adjustPosition);
		_shop.Activate(adjustPosition);
	}

	public function revert() : Void {
		_missionReward.Deactivate();
		_missionJournal.Deactivate();
		_friends.Deactivate();
		_pets.Deactivate();
		_social.Deactivate();
		_deliveredItems.Deactivate();
		_lockoutTimers.Deactivate();
		_challengeJournal.Deactivate();
		_shop.Deactivate();
	}
	
	private function pluginEnabledHandler( name:String, newValue, oldValue ) : Void {
		adjustPosition = true;
		if ( name == "plugin.enabled" ) {
			newValue ? apply() : revert();
		}
		adjustPosition = false;
	}

	/**
	 * handle pref value changes for the plugin
	 * 
	 * @param	name
	 * @param	newValue
	 * @param	oldValue
	 */
	private function prefChangeHandler( name:String, newValue, oldValue ) : Void {
		
		switch ( name ) {
			
			case "scale.challengeJournal":
				_challengeJournal.scale = newValue;
				break;
			case "scale.deliveredItems":
				_deliveredItems.scale = newValue;
				break;
			case "scale.friends":
				_friends.scale = newValue;
				break;
			case "scale.lockoutTimers":
				_lockoutTimers.scale = newValue;
				break;
			case "scale.missionJournal":
				_missionJournal.scale = newValue;
				break;
			case "scale.missionReward":
				_missionReward.scale = newValue;
				break;
			case "scale.pets":
				_pets.scale = newValue;
				break;
			case "scale.social":
				_social.scale = newValue;
				break;
			case "scale.shop":
				_shop.scale = newValue;
				break;
		}
		
	}

	public function getConfigPanelLayout() : Array {
		return [
			{	id: "scale.challengeJournal", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Challenge Journal Scale", tooltip: "Challenge Journal Scale", data: { pref: "scale.challengeJournal" } },
			{	id: "scale.deliveredItems", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Delivered Items Scale", tooltip: "Delivered Items Scale", data: { pref: "scale.deliveredItems" } },
			{	id: "scale.friends", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Friends/Cabal Window Scale", tooltip: "Friends/Cabal Window Scale", data: { pref: "scale.friends" } },
			{	id: "scale.lockoutTimers", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Lockout Timers Scale", tooltip: "Lockout Timers Scale", data: { pref: "scale.lockoutTimers" } },
			{	id: "scale.missionJournal", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Mission Journal Scale", tooltip: "Mission Journal Scale", data: { pref: "scale.missionJournal" } },
			{	id: "scale.missionReward", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Mission Reward Scale", tooltip: "Mission Reward Scale", data: { pref: "scale.missionReward" } },
			{	id: "scale.pets", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Pets/Sprints Scale", tooltip: "Pets/Sprints Scale", data: { pref: "scale.pets" } },
			{	id: "scale.social", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Social Window Scale", tooltip: "Social Window Scale", data: { pref: "scale.social" } },
			{	id: "scale.shop", type: "slider", min: 50, max: 200, step: 1, valueFormat: "%i%%", label: "Vendor Scale", tooltip: "Vendor Scale", data: { pref: "scale.shop" } }
		];
	}

	private var _missionReward:Scaler;
	private var _missionJournal:Scaler;
	private var _friends:Scaler;
	private var _pets:Scaler;
	private var _lockoutTimers:Scaler;
	private var _social:Scaler;
	private var _deliveredItems:Scaler;
	private var _challengeJournal:Scaler;
	private var _shop:Scaler;
	
}
