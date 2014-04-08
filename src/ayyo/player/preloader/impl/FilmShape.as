package ayyo.player.preloader.impl {
	import flash.display.Bitmap;
	import me.scriptor.additional.api.IDisposable;

	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class FilmShape extends Sprite implements IDisposable {
		[Embed(source="./../../../../../assets/preloader/preloader.png")]
		private var PreloaderBitmap : Class;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _bitmap : Bitmap;

		public function FilmShape(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this._bitmap = new PreloaderBitmap();
				this._bitmap.x = -this._bitmap.width >> 1;
				this._bitmap.y = -this._bitmap.height >> 1;
				this._bitmap.smoothing = true;
				this.addChild(this._bitmap);
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}
	}
}
