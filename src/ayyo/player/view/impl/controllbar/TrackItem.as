package ayyo.player.view.impl.controllbar {
	import flash.geom.Matrix;
	import flash.display.BitmapData;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.display.Bitmap;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.GlowFilter;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.TextElement;

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
		private var _glowFilter : BitmapFilter;
		/**
		 * @private
		 */
		private var _id : uint;
		/**
		 * @private
		 */
		private var _subicon : Bitmap;
		/**
		 * @private
		 */
		private var _textBlock : TextBlock;

		public function TrackItem(id : uint, autoCreate : Boolean = true) {
			this._id = id;
			super(autoCreate);
		}

		public function set language(value : String) : void {
			if (this._id > 0) {
				this._subicon = new SubGraphics() as Bitmap;
				this.addChild(this._subicon);
				this._subicon.y = this._icon.height - this._subicon.height >> 1;
				value += " +    RU";
			}
			var fontDescription : FontDescription = new FontDescription("Trebuchet MS", FontWeight.BOLD);
			var format : ElementFormat = new ElementFormat(fontDescription, 11, 0xffffff);
			var text : TextElement = new TextElement(value.toUpperCase(), format);
			this._textBlock = new TextBlock();
			this._textBlock.content = text;
			var line : TextLine = this.textLine;
			this._icon.y = line.height - this._icon.height >> 1;
			line.y = (line.height - this._icon.height >> 1) + Math.floor(line.height) - 1;
			line.x = this._icon.x + this._icon.width + 2;
			if(this._subicon) this._subicon.x = line.x + 26;
			
			var data : BitmapData = new BitmapData(line.width, line.height, true, 0xcccccc);
			var matrix : Matrix = new Matrix();
			var bitmap : Bitmap = new Bitmap(data);
			
			matrix.translate(0, line.ascent + (line.descent >> 1));
			bitmap.bitmapData.draw(line, matrix, null, null, null, true);
			bitmap.x = line.x;
			bitmap.y = line.height - this._icon.height >> 1;
			this.addChild(bitmap);
		}

		public function get textLine() : TextLine {
			return this._textBlock.createTextLine();
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
			this._glowFilter = new GlowFilter(0xffffff, .5, 8, 8, 2, BitmapFilterQuality.HIGH, false, false);
			this.filters = [this._glowFilter];
		}

		override protected function onButtonClick(event : MouseEvent) : void {
			super.onButtonClick(event);
			this.action.dispatch(this._id.toString());
		}

		// Handlers
		private function onRolloverRollout(event : MouseEvent) : void {
			this.alpha = event.type == MouseEvent.ROLL_OVER ? .8 : .5;
		}
	}
}
