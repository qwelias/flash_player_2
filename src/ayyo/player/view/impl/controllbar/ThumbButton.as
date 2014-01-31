package ayyo.player.view.impl.controllbar {
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ThumbButton extends AbstractButton {
		public function ThumbButton(autoCreate : Boolean = true) {
			super(autoCreate);
		}

		override protected function createButton() : void {
			super.createButton();
			this.filters = [new DropShadowFilter(2, 90, 0, .3, 1, 1, 1, BitmapFilterQuality.MEDIUM)];
			this.graphics.clear();
			this.graphics.beginFill(0xffffff);
			this.graphics.drawCircle(0, 0, 8);
		}
	}
}
