package ayyo.player.config.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IPlayerSettings  extends ICanInitialize {
		function get screenshot() : String;

		function get type() : String;

		function get free() : Boolean;

		function get timeLeft() : Number;
	}
}
