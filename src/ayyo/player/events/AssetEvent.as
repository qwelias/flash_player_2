package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AssetEvent extends Event {
		public static const REGISTRED : String = "assetRegistred";

		public function AssetEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
