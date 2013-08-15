package ayyo.player.config.impl {
	import ayyo.player.config.api.IPlayerAsset;
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.config.api.IPlayerSettings;
	import ayyo.player.config.api.IReplaceWordList;
	import ayyo.player.config.impl.support.PlayerSettings;
	import ayyo.player.config.impl.support.PlayerTooltip;
	import ayyo.player.config.impl.support.ReplaceWordList;
	import ayyo.player.tooltip.api.IPlayerTooltip;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class FlashVarsConfig implements IPlayerConfig {
		/**
		 * @private
		 */
		private var _settings : IPlayerSettings;
		/**
		 * @private
		 */
		private var _assets : Vector.<IPlayerAsset>;
		/**
		 * @private
		 */
		private var _tooltip : IPlayerTooltip;
		/**
		 * @private
		 */
		private var _replaceWord : ReplaceWordList;

		public function initialize(source : Object) : void {
			var settingsSource : Object;
			var tooltipSource : Object;
			var replaceWordSource : Object;
			settingsSource["screenshot"] = source["screenshot"];
			settingsSource["type"] = source["player_type"];
			settingsSource["free"] = source["free"];
			settingsSource["timeLeft"] = source["hours_until_stop"];
			
			tooltipSource["playButton"] = source["tooltip_play_button"];
			tooltipSource["pauseButton"] = source["tooltip_pause_button"];
			tooltipSource["timeLeft"] = source["tooltip_license_icon"];
			tooltipSource["timer"] = source["tooltip_timer"];
			tooltipSource["timerReverse"] = source["tooltip_timer_reverse"];
			tooltipSource["highQuality"] = source["tooltip_HQ_icon_on"];
			tooltipSource["standartQuality"] = source["tooltip_HQ_icon_off"];
			tooltipSource["sound"] = source["tooltip_sound_icon_on"];
			tooltipSource["mute"] = source["tooltip_sound_icon_off"];
			tooltipSource["fullscreen"] = source["tooltip_fullscreen"];
			tooltipSource["window"] = source["tooltip_unfullscreen"];
			
			replaceWordSource["forTimeLeft"] = source["N"];
			
			this.settings.initialize(settingsSource);
			this.tooltip.initialize(tooltipSource);
			this.replaceWord.initialize(replaceWordSource);
		}

		public function get settings() : IPlayerSettings {
			return this._settings ||= new PlayerSettings();
		}

		public function get assets() : Vector.<IPlayerAsset> {
			return this._assets ||= new Vector.<IPlayerAsset>();
		}

		public function get tooltip() : IPlayerTooltip {
			return this._tooltip ||= new PlayerTooltip();
		}

		public function get replaceWord() : IReplaceWordList {
			return this._replaceWord ||= new ReplaceWordList;
		}
	}
}
