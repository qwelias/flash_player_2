package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleEvent extends Event {
		public static const READY : String = "moduleReady";

		public function ModuleEvent(type : String) {
			super(type, false, false);
		}
	}
}
