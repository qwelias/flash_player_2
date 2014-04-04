package ayyo.player.view.api {
	import me.scriptor.additional.api.IHaveActionSignal;
	import flash.display.Shape;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IVideoTimeline extends IVideoTimer, IHaveActionSignal {
		function get buffered() : Shape;

		function get played() : Shape;

		function get thumb() : IButton;

		function set loaded(value : Number) : void;
	}
}
