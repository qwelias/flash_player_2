package ayyo.player.plugins.test {
	import ayyo.player.plugins.test.info.TestPluginInfo;

	import org.osmf.media.PluginInfo;

	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TestPlugin extends Sprite {
		/**
		 * @private
		 */
		private var _pluginInfo : PluginInfo;

		public function TestPlugin() {
		}

		public function get pluginInfo() : PluginInfo {
			trace("TestPlugin.pluginInfo()");
			return this._pluginInfo ||= new TestPluginInfo();
		}
	}
}
