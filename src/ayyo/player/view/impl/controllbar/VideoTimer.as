package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IVideoTimer;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimer extends AbstractButton implements IVideoTimer {
		/**
		 * @private
		 */
		private var _textfield : TextField;

		public function VideoTimer(autoCreate : Boolean = true) {
			super(autoCreate);
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
		
		override protected function createButton() : void {
			super.createButton();
			this.addChild(this.textfield);
			this.time = 0;
		}
		
		private function convertSecondsToString(value : uint) : String {
			var result : String = "00:00:00";
			var hours : uint = value / 3600;
			var minutes : uint = (value - hours * 3600) / 60;
			var seconds : uint = value - hours * 3600 - minutes * 60;
			
			trace(hours, minutes, seconds);
			return result;
		}
	}
}
