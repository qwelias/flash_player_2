package ayyo.player.modules.splash.view.impl {
	import ayyo.player.modules.splash.view.api.ISplashImageHolder;

	import me.scriptor.additional.disposeBitmap;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ImageHolder extends Sprite  implements ISplashImageHolder {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _image : Bitmap;

		public function ImageHolder(image : Bitmap, autoCreate : Boolean = true) {
			this._image = image;
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.image.smoothing = true;
				this.addChild(this.image);
				this.mouseChildren = this.mouseEnabled = false;
				this.cacheAsBitmap = true;
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				disposeBitmap(this.image);
				this._image = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this.image);
			}
		}

		public function resize(screen : Rectangle = null) : void {
			if(screen) {
				this.x = screen.width - this.image.width >> 1;
				this.y = screen.height - this.image.height >> 1;
			}
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get image() : Bitmap {
			return this._image ||= new Bitmap();
		}
	}
}
