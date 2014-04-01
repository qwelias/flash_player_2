package ayyo.player.view.impl.controllbar {
	import ayyo.player.utils.convertSecondsToString;
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
		/**
		 * @private
		 */
		private var _controlable : Boolean;
		/**
		 * @private
		 */
		private var _value : uint;

		public function VideoTimer(autoCreate : Boolean = true, isUnderControlOfMediator : Boolean = true) {
			this._controlable = isUnderControlOfMediator;
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.addChild(this.textfield);
				this.addEventListener(MouseEvent.CLICK, this.onSwitchCurrentToEstimated);
				this.controlable && this.addEventListener(MouseEvent.ROLL_OVER, this.onRolloveroutHandler);
				this.controlable && this.addEventListener(MouseEvent.ROLL_OUT, this.onRolloveroutHandler);
				this.time = 0;
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.textfield.parent && this.textfield.parent.removeChild(this.textfield);
				this.removeEventListener(MouseEvent.CLICK, this.onSwitchCurrentToEstimated);
				this.controlable && this.removeEventListener(MouseEvent.ROLL_OVER, this.onRolloveroutHandler);
				this.controlable && this.removeEventListener(MouseEvent.ROLL_OUT, this.onRolloveroutHandler);
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
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
			this.textfield.text = (this.isEstimated ? "–" : (this.controlable ? "  " : "")) + convertSecondsToString(value, this._duration, this.isEstimated);
			this._value = value;
		}

		public function set duration(value : uint) : void {
			this._duration = value;
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get controlable() : Boolean {
			return this._controlable;
		}

		// Handlers
		private function onSwitchCurrentToEstimated(event : MouseEvent) : void {
			this.isEstimated = !this.isEstimated;
			this.time = this._value;
		}
		
		private function onRolloveroutHandler(event : MouseEvent) : void {
			var format : TextFormat = new TextFormat("Arial", 12);
			format.color = event.type == MouseEvent.ROLL_OVER ? 0xc4eff4 : 0xffffff;
			this.textfield.defaultTextFormat = format;
			this.textfield.text = this.textfield.text;
		}
	}
}
