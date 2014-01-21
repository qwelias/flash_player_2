package ayyo.player.config.impl {
	import ayyo.player.asstes.info.impl.AssetInfo;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.config.api.IAyyoPlayerSettings;
	import ayyo.player.config.api.IAyyoPlayerTooltip;
	import ayyo.player.config.api.IAyyoVideoSettings;
	import ayyo.player.config.api.ICanInitialize;
	import ayyo.player.config.api.IReplaceWordList;
	import ayyo.player.config.impl.support.PlayerSettings;
	import ayyo.player.config.impl.support.PlayerTooltip;
	import ayyo.player.config.impl.support.ReplaceWordList;
	import ayyo.player.config.impl.support.VideoSettings;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class JSONPlayerConfig implements IAyyoPlayerConfig {
		/**
		 * @private
		 */
		private var _settings : IAyyoPlayerSettings;
		/**
		 * @private
		 */
		private var _assets : Vector.<AssetInfo>;
		/**
		 * @private
		 */
		private var _modules : Vector.<ModuleInfo>;
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
		 * @private
		 */
		private var _video : VideoSettings;

		public function initialize(source : Object) : void {
			var item : ICanInitialize;
			for (var property : String in source) {
				if (property in this) item = this[property] as ICanInitialize;
				item && item.initialize(source[property]);
			}
			this.ready.dispatch();
		}

		public function get settings() : IAyyoPlayerSettings {
			return this._settings ||= new PlayerSettings();
		}

		public function get assets() : Vector.<AssetInfo> {
			return this._assets ||= new Vector.<AssetInfo>();
		}

		public function get modules() : Vector.<ModuleInfo> {
			return this._modules ||= new Vector.<ModuleInfo>();
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
	}
}
