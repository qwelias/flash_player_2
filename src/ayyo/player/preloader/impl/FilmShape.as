package ayyo.player.preloader.impl {
	import me.scriptor.additional.api.IDisposable;

	import flash.display.Shape;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class FilmShape extends Shape implements IDisposable {
		/**
		 * @private
		 */
		private var isCreated : Boolean;

		public function FilmShape(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.graphics.beginFill(AyyoPreloader.COLOR);
				this.graphics.drawCircle(0, 0, AyyoPreloader.BOUNDS);
				this.graphics.drawCircle(AyyoPreloader.BOUNDS >> 1, 0, AyyoPreloader.BOUNDS / 3.5);
				this.graphics.drawCircle(-AyyoPreloader.BOUNDS >> 1, 0, AyyoPreloader.BOUNDS / 3.5);
				this.graphics.drawCircle(0, AyyoPreloader.BOUNDS >> 1, AyyoPreloader.BOUNDS / 3.5);
				this.graphics.drawCircle(0, -AyyoPreloader.BOUNDS >> 1, AyyoPreloader.BOUNDS / 3.5);
				this.graphics.drawCircle(0, 0, AyyoPreloader.BOUNDS >> 3);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.graphics.clear();
				this.isCreated = false;
			}
		}
	}
}
