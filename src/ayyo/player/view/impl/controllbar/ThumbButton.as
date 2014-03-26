package ayyo.player.view.impl.controllbar {
	import flash.events.MouseEvent;

	import ayyo.player.view.api.ButtonState;

	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ThumbButton extends AbstractButton {
		/**
		 * @private
		 */
		private const COLORS : Vector.<uint> = new <uint>[0xffffff, 0xc4eff4, 0x82bcda];
		/**
		 * @private
		 */
		private var isThumbPressed : Boolean;

		public function ThumbButton(autoCreate : Boolean = true) {
			super(autoCreate);
		}

		override protected function createButton() : void {
			super.createButton();
			this.filters = [new DropShadowFilter(2, 86, 0, .3, 1, 1, 1, BitmapFilterQuality.HIGH)];
			this.state = ButtonState.NORMAL;

			this.signals.rollOver.add(this.onRolloverOut);
			this.signals.rollOut.add(this.onRolloverOut);
			this.signals.mouseDown.addOnce(this.onPressed);
		}

		override public function set state(value : String) : void {
			super.state = value;
			const color : uint = value == ButtonState.NORMAL ? COLORS[0] : (value == ButtonState.HOVER ? COLORS[1] : COLORS[2]);

			this.graphics.clear();
			this.graphics.lineStyle(1, 0, .35);
			this.graphics.beginFill(color);
			this.graphics.drawCircle(0, 0, 6);
		}

		// Handlers
		private function onRolloverOut(event : MouseEvent) : void {
			if (!this.isThumbPressed)
				this.state = event.type == MouseEvent.ROLL_OVER ? ButtonState.HOVER : ButtonState.NORMAL;
		}

		private function onPressed(event : MouseEvent) : void {
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onReleased);
			this.state = ButtonState.CLICKED;
			this.isThumbPressed = true;
		}

		private function onReleased(event : MouseEvent) : void {
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onReleased);
			this.signals.mouseDown.addOnce(this.onPressed);
			this.state = ButtonState.NORMAL;
			this.isThumbPressed = false;
		}
	}
}
