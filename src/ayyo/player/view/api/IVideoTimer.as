package ayyo.player.view.api {
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IVideoTimer extends IHaveView, IDisposable {
		function set time(value : uint) : void;

		function set duration(value : uint) : void;

		function get controlable() : Boolean;
	}
}
