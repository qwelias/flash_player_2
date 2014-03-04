package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IVideoTimer;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimer extends Sprite implements IVideoTimer {
		/**
		 * @private
		 */
		private var _textfield : TextField;
		/**
		 * @private
		 */
		private var _duration : uint;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var isEstimated : Boolean;

		public function VideoTimer(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.addChild(this.textfield);
				this.addEventListener(MouseEvent.CLICK, this.onSwitchCurrentToEstimated);
				this.time = 0;
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.isCreated = false;
			}
		}

		public function get textfield() : TextField {
			if (!this._textfield) {
				var format : TextFormat = new TextFormat("Arial", 12, 0xffffff);
				this._textfield = new TextField();
				this._textfield.selectable = false;
				this._textfield.embedFonts = true;
				this._textfield.autoSize = TextFieldAutoSize.LEFT;
				this._textfield.multiline = false;
				this._textfield.defaultTextFormat = format;
			}
			return this._textfield;
		}

		public function set time(value : uint) : void {
			this.textfield.text = this.convertSecondsToString(value);
		}

		public function set duration(value : uint) : void {
			this._duration = value;
		}

		public function get view() : DisplayObject {
			return this;
		}

		private function convertSecondsToString(value : uint) : String {
			var result : String = "00:00:00";
			value = this.isEstimated ? this._duration - value : value;
			var hours : uint = value / 3600;
			var minutes : uint = (value - hours * 3600) / 60;
			var seconds : uint = value - hours * 3600 - minutes * 60;
			result = (hours < 10 ? "0" : "") + hours.toString() + ":" + (minutes < 10 ? "0" : "") + minutes.toString() + ":" + (seconds < 10 ? "0" : "") + seconds.toString();
			return result;
		}

		// Handlers
		private function onSwitchCurrentToEstimated(event : MouseEvent) : void {
			this.isEstimated = !this.isEstimated;
		}
	}
}
