package ayyo.player.config.impl {
	import ayyo.player.asstes.info.impl.AssetInfo;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.config.api.IAyyoPlayerSettings;
	import ayyo.player.config.api.IAyyoPlayerTooltip;
	import ayyo.player.config.api.IAyyoVideoSettings;
	import ayyo.player.config.api.IReplaceWordList;
	import ayyo.player.config.impl.support.PlayerSettings;
	import ayyo.player.config.impl.support.PlayerTooltip;
	import ayyo.player.config.impl.support.ReplaceWordList;
	import ayyo.player.config.impl.support.VideoSettings;
	import ayyo.player.core.model.api.IInfoObject;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import by.blooddy.crypto.serialization.JSON;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class FlashVarsConfig implements IAyyoPlayerConfig {
		/**
		 * @private
		 */
		private var _settings : IAyyoPlayerSettings;
		/**
		 * @private
		 */
		private var _assets : Vector.<IInfoObject>;
		/**
		 * @private
		 */
		private var _modules : Vector.<IInfoObject>;
		/**
		 * @private
		 */
		private var _tooltip : IAyyoPlayerTooltip;
		/**
		 * @private
		 */
		private var _replaceWord : ReplaceWordList;
		/**
		 * @private
		 */
		private var _ready : ISignal;
		/**
		 * @private video settings section
		 */
		private var _video : IAyyoVideoSettings;

		public function initialize(source : Object) : void {
			var settingsSource : Object = {};
			var videoSource : Object = {};
			var tooltipSource : Object = {};
			var replaceWordSource : Object = {};
			settingsSource["screenshot"] = source["screenshot"];
			settingsSource["type"] = source["player_type"];
			settingsSource["free"] = source["free"];
			settingsSource["timeLeft"] = source["hours_until_stop"];
			
			videoSource["url"] = source["url"];
			videoSource["token"] = source["token"];

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

			replaceWordSource["timeLeft"] = source["N"];

			source["modules"] && this.parseVector(this.modules, String(source["modules"]).split(";"), ModuleInfo);
			source["assets"] && this.parseVector(this.assets, String(source["assets"]).split(";"), AssetInfo);

			this.settings.initialize(settingsSource);
			this.tooltip.initialize(tooltipSource);
			this.replaceWord.initialize(replaceWordSource);
			this.video.initialize(videoSource);

			this.ready.dispatch();
		}

		public function get settings() : IAyyoPlayerSettings {
			return this._settings ||= new PlayerSettings();
		}

		public function get assets() : Vector.<IInfoObject> {
			return this._assets ||= new Vector.<IInfoObject>();
		}

		public function get modules() : Vector.<IInfoObject> {
			return this._modules ||= new Vector.<IInfoObject>();
		}

		public function get tooltip() : IAyyoPlayerTooltip {
			return this._tooltip ||= new PlayerTooltip();
		}

		public function get replaceWord() : IReplaceWordList {
			return this._replaceWord ||= new ReplaceWordList;
		}

		public function get ready() : ISignal {
			return this._ready ||= new Signal();
		}
		
		public function get video() : IAyyoVideoSettings {
			return this._video ||= new VideoSettings();
		}

		private function parseVector(vector : Vector.<IInfoObject>, source : Array, type : Class) : void {
			var length : uint = source.length;
			var i : int = 0;
			for (i = 0; i < length; i++) {
				vector.push(new type(by.blooddy.crypto.serialization.JSON.decode(source[i])));
			}
		}
	}
}
