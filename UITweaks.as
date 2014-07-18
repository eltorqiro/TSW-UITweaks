import com.GameInterface.DistributedValue;
import com.GameInterface.UtilsBase;
import com.ElTorqiro.UITweaks.*;

var plugins:Array = [];

function onLoad():Void {

}

function OnModuleActivated():Void {

	plugins.push( new SuppressCharacterSheetScaling(true) );

	for (var i:Number = 0; i < plugins.length; i++)
	{
		plugins[i].active = true;
	}
}

function OnModuleDeactivated():Void {
	
	for (var i:Number = 0; i < plugins.length; i++)
	{
		plugins[i].active = false;
	}
}