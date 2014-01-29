package ayyo.player.view.impl.controllbar {
	import flash.display.Sprite;
	import flash.display.BitmapData;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class DashedPattern extends BitmapData {
		public function DashedPattern() {
			super(4, 10, false, 0xffffff);
			
			var sprite : Sprite = new Sprite();
			sprite.graphics.beginFill(0xffffff);
			sprite.graphics.drawRect(0, 0, 2, 10);
			sprite.graphics.beginFill(0);
			sprite.graphics.drawRect(2, 0, 2, 10);
			
			this.draw(sprite);
			sprite = null;
		}
	}
}
