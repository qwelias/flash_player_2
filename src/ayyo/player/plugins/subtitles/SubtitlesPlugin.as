package ayyo.player.plugins.subtitles {
	import ayyo.player.plugins.subtitles.impl.SubtitlesInfo;

	import org.osmf.media.PluginInfo;

	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesPlugin extends Sprite {
		/**
		 * @private
		 */
		private var _pluginInfo : PluginInfo;

		public function get pluginInfo() : PluginInfo {
			return this._pluginInfo ||= new SubtitlesInfo();
		}
	}
}
