package ayyo.player.config.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IPlayerTooltip {
		function initialize(source : Object) : void;

		function get playButton() : String;

		function get pauseButton() : String;

		function get timeLeft() : String;

		function get timer() : String;

		function get timerReverse() : String;

		function get highQuality() : String;

		function get standartQuality() : String;

		function get sound() : String;

		function get mute() : String;

		function get fullscreen() : String;

		function get window() : String;
	}
}
