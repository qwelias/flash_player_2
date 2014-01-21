package ayyo.player.config.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoVideoSettings extends ICanInitialize {
		function get url() : String;

		function get token() : String;
	}
}
