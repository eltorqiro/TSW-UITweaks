import com.GameInterface.DistributedValue;
import mx.utils.Delegate;
import com.ElTorqiro.UITweaks.Plugins.Resizer.Scaler;

class com.ElTorqiro.UITweaks.Plugins.Resizer.Resizer {
	
	private var _missionReward:Scaler;
	private var _missionJournal:Scaler;
	private var _friends:Scaler;
	private var _pets:Scaler;
	private var _lockoutTimers:Scaler;
	private var _social:Scaler;
	private var _deliveredItems:Scaler;
	private var _challengeJournal:Scaler;
	private var _shop:Scaler;
	
	public function Resizer() {
		_missionReward = new Scaler(null, GUI.Mission.MissionSignals.SignalMissionReportSent, "missionrewardcontroller", true);
		_missionJournal = new Scaler(DistributedValue.Create("mission_journal_window"), null, "missionjournalwindow", false);
		_friends = new Scaler(DistributedValue.Create("friends_window"), null, "friends", false);
		_pets = new Scaler(DistributedValue.Create("petInventory_window"), null, "petinventory", false);
		_social = new Scaler(DistributedValue.Create("group_search_window"), null, "groupsearch", false);
		_deliveredItems = new Scaler(DistributedValue.Create("claim_window"), null, "claimwindow", false);
		_lockoutTimers = new Scaler(DistributedValue.Create("lockoutTimers_window"), null, "lockouttimers", false);
		_challengeJournal = new Scaler(DistributedValue.Create("challengeJournal_window"), null, "challengejournal", false);
		_shop = new Scaler(null, com.GameInterface.ShopInterface.SignalOpenShop, "shopcontroller", false);
	}
	
	public function Activate():Void {
		_missionReward.Activate();
		_missionJournal.Activate();
		_friends.Activate();
		_pets.Activate();
		_social.Activate();
		_deliveredItems.Activate();
		_lockoutTimers.Activate();
		_challengeJournal.Activate();
		_shop.Activate();
	}

	public function Deactivate():Void {
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
	
	public function get missionReward():Number { return _missionReward.scale };
	public function set missionReward(value:Number):Void { if (value != undefined) _missionReward.scale = value; }
	
	public function get missionJournal():Number { return _missionJournal.scale };
	public function set missionJournal(value:Number):Void { if (value != undefined) _missionJournal.scale = value; }
	
	public function get social():Number { return _social.scale };
	public function set social(value:Number):Void { if (value != undefined) _social.scale = value; }
	
	public function get friends():Number { return _friends.scale };
	public function set friends(value:Number):Void { if (value != undefined) _friends.scale = value; }
	
	public function get pets():Number { return _pets.scale };
	public function set pets(value:Number):Void { if (value != undefined) _pets.scale = value; }
	
	public function get deliveredItems():Number { return _deliveredItems.scale };
	public function set deliveredItems(value:Number):Void { if (value != undefined) _deliveredItems.scale = value; }
	
	public function get lockoutTimers():Number { return _lockoutTimers.scale };
	public function set lockoutTimers(value:Number):Void { if (value != undefined) _lockoutTimers.scale = value; }
	
	public function get challengeJournal():Number { return _challengeJournal.scale };
	public function set challengeJournal(value:Number):Void { if (value != undefined) _challengeJournal.scale = value; }

	public function get shop():Number { return _shop.scale };
	public function set shop(value:Number):Void { if (value != undefined) _shop.scale = value; }

}
