package ayyo.player.config.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoPlayerSettings  extends ICanInitialize {
		function get screenshot() : String;

		function get type() : String;

		function get baseURL() : String;

		function get free() : Boolean;

		function get timeLeft() : Number;
		
		function get buffer() : Number;

		function get autoplay() : Boolean;
	}
}
