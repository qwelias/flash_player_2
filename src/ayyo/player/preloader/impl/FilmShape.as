package ayyo.player.preloader.impl {
	import flash.geom.Point;
	import me.scriptor.additional.api.IDisposable;

	import flash.display.Shape;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class FilmShape extends Shape implements IDisposable {
		private static const CIRCLE_COUNT : Number = 5;
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
				var point : Point = new Point();
				var step : Number = Math.PI * 2 / FilmShape.CIRCLE_COUNT;
				for (var i : int = 0; i < FilmShape.CIRCLE_COUNT; i++) {
					point.x = Math.cos(i * step) * (AyyoPreloader.BOUNDS >> 1);
					point.y = Math.sin(i * step) * (AyyoPreloader.BOUNDS >> 1);
					this.graphics.drawCircle(point.x, point.y, AyyoPreloader.BOUNDS >> 2);
				}
				this.graphics.drawCircle(0, 0, AyyoPreloader.BOUNDS >> 3);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.graphics.clear();
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}
	}
}
