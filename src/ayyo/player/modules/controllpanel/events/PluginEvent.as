package ayyo.player.modules.controllpanel.events {
	import ayyo.player.modules.controllpanel.plugins.api.IControllPanelPlugin;

	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PluginEvent extends Event {
		public static const REGISTER : String = "registerPlugin";
		/**
		 * @private
		 */
		private var _plugin : IControllPanelPlugin;

		public function PluginEvent(type : String, plugin : IControllPanelPlugin) {
			super(type, bubbles, cancelable);
			this._plugin = plugin;
		}

		public function get plugin() : IControllPanelPlugin {
			return this._plugin;
		}
	}
}
