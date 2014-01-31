package ayyo.player.view.api {
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveActionSignal;
	import me.scriptor.additional.api.IHaveView;

	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IButton extends IHaveView, IDisposable, IHaveActionSignal {
		function enable() : void;

		function disable() : void;

		function click() : void;
		
		function get signals() : InteractiveObjectSignalSet;
	}
}
