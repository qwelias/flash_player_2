package ayyo.player.view.impl.controllbar {
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.display.Bitmap;
	import flash.text.TextField;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class TrackItem extends AbstractButton {
		[Embed(source="./../../../../../../assets/controlbar/icon.audio.png")]
		private var AudioGraphics : Class;
		[Embed(source="./../../../../../../assets/controlbar/icon.sub.png")]
		private var SubGraphics : Class;
		/**
		 * @private
		 */
		private var _icon : Bitmap;
		/**
		 * @private
		 */
		private var _textfield : TextField;

		public function TrackItem(autoCreate : Boolean = true) {
			super(autoCreate);
		}

		public function set language(value : String) : void {
			this.textfield.text = value.toUpperCase();
			this.textfield.x = this._icon.width + 2;
			this.textfield.y = this._icon.height - this.textfield.height >> 1;
		}

		public function get textfield() : TextField {
			if(!this._textfield) {
				var format : TextFormat = new TextFormat("Arial", 11, 0xffffff);
				this._textfield = new TextField();
				this._textfield.selectable = false;
				this._textfield.embedFonts = true;
				this._textfield.autoSize = TextFieldAutoSize.LEFT;
				this._textfield.multiline = false;
				this._textfield.defaultTextFormat = format;
				
			}
			return this._textfield;
		}

		override protected function createButton() : void {
			super.createButton();
			this._icon = new AudioGraphics() as Bitmap;
			this.addChild(this._icon);
			this.addChild(this.textfield);
		}
	}
}
