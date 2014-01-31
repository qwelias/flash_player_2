package ayyo.player.view.impl.controllbar {
	import flash.display.BitmapData;
	import flash.display.Shape;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AlphaDashedPattern extends BitmapData {
		public function AlphaDashedPattern() {
			super(4, 10, true, 0xffffff);

			var sprite : Shape = new Shape();
			sprite.graphics.beginFill(0xffffff, .3);
			sprite.graphics.drawRect(0, 0, 2, 10);
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(2, 0, 2, 10);

			this.draw(sprite);
			sprite = null;
		}
	}
}
