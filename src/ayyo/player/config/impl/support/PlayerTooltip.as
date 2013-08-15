package ayyo.player.config.impl.support {
	import ayyo.player.tooltip.api.IPlayerTooltip;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerTooltip implements IPlayerTooltip {
		/**
		 * @private
		 */
		private var _playButton : String;
		/**
		 * @private
		 */
		private var _pauseButton : String;
		/**
		 * @private
		 */
		private var _timeLeft : String;
		/**
		 * @private
		 */
		private var _timer : String;
		/**
		 * @private
		 */
		private var _timerReverse : String;
		/**
		 * @private
		 */
		private var _highQuality : String;
		/**
		 * @private
		 */
		private var _standartQuality : String;
		/**
		 * @private
		 */
		private var _sound : String;
		/**
		 * @private
		 */
		private var _mute : String;
		/**
		 * @private
		 */
		private var _fullscreen : String;
		/**
		 * @private
		 */
		private var _window : String;

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}

		public function get playButton() : String {
			return this._playButton ||= "Play";
		}

		public function get pauseButton() : String {
			return this._pauseButton ||= "Pause";
		}

		public function get timeLeft() : String {
			return this._timeLeft ||= "You have %HOURS% to watch this film";
		}

		public function get timer() : String {
			return this._timer ||= "Time left";
		}

		public function get timerReverse() : String {
			return this._timerReverse ||= "Elapsed time";
		}

		public function get highQuality() : String {
			return this._highQuality ||= "High Quality";
		}

		public function get standartQuality() : String {
			return this._standartQuality ||= "Standart quality";
		}

		public function get sound() : String {
			return this._sound ||= "Sound";
		}

		public function get mute() : String {
			return this._mute ||= "Mute";
		}

		public function get fullscreen() : String {
			return this._fullscreen ||= "Fullscreen";
		}

		public function get window() : String {
			return this._window ||= "Window mode";
		}
	}
}
