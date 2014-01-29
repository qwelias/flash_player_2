package ayyo.player.plugins.subtitles.impl.view {
	import flash.display.DisplayObject;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.text.AntiAliasType;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtextField extends TextField implements ISubtextField {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _format : TextFormat;

		public function SubtextField(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.format.color = 0xffffff;
				this.format.align = TextFormatAlign.CENTER;
				this.format.font = "Arial Bold";
				this.format.bold = true;

				this.embedFonts = true;
				this.antiAliasType = AntiAliasType.NORMAL;
				this.multiline = true;
				this.wordWrap = true;
				this.selectable = false;
				this.defaultTextFormat = format;

				this.filters = [new GlowFilter(0, 1.0, 0, 0, 2, BitmapFilterQuality.MEDIUM), new DropShadowFilter(2, 45, 0, 0.75, 1, 1, 1, BitmapFilterQuality.MEDIUM)];

				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (!this.isCreated) {
				this.parent && this.parent.removeChild(this);
				this.isCreated = false;
			}
		}

		public function resize(screen : Rectangle = null) : void {
			if (screen) {
				this.width = screen.width * .844;
				this.height = screen.height * .115;
				this.format.size = this.height / 2.2;
				this.defaultTextFormat = this.format;
				this.text = this.text;
				this.height += 50;
				this.x = screen.width - this.width >> 1;
				this.y = screen.height * .805;
				
			}
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get format() : TextFormat {
			return this._format ||= new TextFormat();
		}
	}
}
