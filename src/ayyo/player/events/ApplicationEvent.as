package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ApplicationEvent extends Event {
		public static const LAUNCH : String = "lauchApplication";
		public static const CONFIG_READY : String = "configReady";

		public function ApplicationEvent(type : String) {
			super(type, false, false);
		}
	}
}
