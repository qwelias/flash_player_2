package ayyo.player.plugins.subtitles.impl.view {
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesGuidlines extends Sprite implements ISubtextField {
		/**
		 * @private
		 */
		private var bounds : Rectangle;

		public function SubtitlesGuidlines(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function resize(screen : Rectangle = null) : void {
			if (screen) {
				this.graphics.clear();
				this.graphics.lineStyle(1, 0x5aaad7);
				this.graphics.moveTo(screen.width * .078, 0);
				this.graphics.lineTo(screen.width * .078, screen.height);

				this.bounds.y = screen.height * .805;
				this.bounds.height = screen.height * .115;

				this.graphics.moveTo(0, this.bounds.y);
				this.graphics.lineTo(screen.width, this.bounds.y);
				this.graphics.moveTo(0, this.bounds.y + this.bounds.height);
				this.graphics.lineTo(screen.width, this.bounds.y + this.bounds.height);

				this.graphics.moveTo(screen.width * .922, 0);
				this.graphics.lineTo(screen.width * .922, screen.height);

				this.x = screen.x;
				this.y = screen.y;

				this.cacheAsBitmap = true;
			}
		}

		public function create() : void {
			if (!this.bounds) {
				this.visible = false;
				this.stage ? this.initialize() : this.addEventListener(Event.ADDED_TO_STAGE, this.initialize);
				this.bounds = new Rectangle();
			}
		}

		private function initialize(event : Event = null) : void {
			this.hasEventListener(Event.ADDED_TO_STAGE) && this.removeEventListener(Event.ADDED_TO_STAGE, this.initialize);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDownHandler);
		}

		private function onKeyDownHandler(event : KeyboardEvent) : void {
			if (event.keyCode == Keyboard.G && event.shiftKey && event.ctrlKey)
				this.visible = !this.visible;
		}

		public function dispose() : void {
		}

		public function get view() : DisplayObject {
			return this;
		}
	}
}
