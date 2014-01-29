package ayyo.player.view.api {
	import flash.display.Shape;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IVideoTimeline extends IVideoTimer {
		function get buffered() : Shape;

		function get played() : Shape;

		function get thumb() : IButton;
	}
}
