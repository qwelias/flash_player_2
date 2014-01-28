package ayyo.player.plugins.event {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PluginEvent extends Event {
		public static const LOAD : String = "loadPlugin";
		public static const LOADED : String = "allPluginsLoaded";
		
		public function PluginEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
