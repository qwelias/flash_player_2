package ayyo.player.view.impl.controllbar {
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
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
		private var _glowFilter : BitmapFilter;
		/**
		 * @private
		 */
		private var _id : uint;
		private var _subicon : Bitmap;

		public function TrackItem(id : uint, autoCreate : Boolean = true) {
			this._id = id;
			super(autoCreate);
		}

		public function set language(value : String) : void {
			this.textfield.text = value.toUpperCase();
			this.textfield.x = this._icon.width + 2;
			this.textfield.y = this._icon.height - this.textfield.height >> 1;
			
			/**
			 * TODO Заплатка. Все id отличные от 0 имют субтитры
			 * 0 - дорожка по умолчанию
			 */
			 if(this._id > 0) {
				this._subicon = new SubGraphics() as Bitmap;
				this.addChild(this._subicon);
				this._subicon.x = this.textfield.x + this.textfield.width + 9;
				this._subicon.y = this._icon.height - this._subicon.height >> 1;
				this.textfield.appendText(" +    RU");
			 }
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
		
		override protected function enableButton() : void {
			super.enableButton();
			this.signals.rollOver.add(this.onRolloverRollout);
			this.signals.rollOut.add(this.onRolloverRollout);
			this.alpha = .5;
			this.filters = [];
		}
		
		override protected function disableButton() : void {
			super.disableButton();
			this.signals.rollOver.remove(this.onRolloverRollout);
			this.signals.rollOut.remove(this.onRolloverRollout);
			this.alpha = 1;
			this.filters = [this._glowFilter];
		}

		override protected function createButton() : void {
			super.createButton();
			this._icon = new AudioGraphics() as Bitmap;
			this.addChild(this._icon);
			this.addChild(this.textfield);
			this._glowFilter = new GlowFilter(0xffffff, .5, 8, 8, 2, BitmapFilterQuality.HIGH, false, false);
			this.filters = [this._glowFilter];
		}

		override protected function onButtonClick(event : MouseEvent) : void {
			super.onButtonClick(event);
			this.action.dispatch(this._id.toString());
		}
		
		//	Handlers
		private function onRolloverRollout(event : MouseEvent) : void {
			this.alpha = event.type == MouseEvent.ROLL_OVER ? .8 : .5;
		}
	}
}
