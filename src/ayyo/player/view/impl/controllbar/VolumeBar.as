package ayyo.player.view.impl.controllbar {
	import flash.geom.Matrix;
	import ayyo.player.view.api.IVolumeBar;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VolumeBar extends Sprite implements IVolumeBar {
		[Embed(source="./../../../../../../assets/controlbar/icon.audio.png")]
		private var AudioGraphics : Class;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _icon : Bitmap;
		/**
		 * @private
		 */
		private var _pattern : DashedPattern;
		/**
		 * @private
		 */
		private var _action : Signal;
		/**
		 * @private
		 */
		private var _matrix : Matrix;

		public function VolumeBar(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this._matrix = new Matrix();
				this.mouseChildren = false;
				this._icon = new AudioGraphics() as Bitmap;
				this._pattern = new DashedPattern();
				this.graphics.beginBitmapFill(this._pattern);
				this.graphics.drawRect(4 + this._icon.width + this._icon.x, 0, 40, 10);
				this.addChild(this._icon);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.isCreated = false;
			}
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String, Number);
		}
	}
}
