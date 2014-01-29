package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IVideoTimeline;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimeline extends Sprite implements IVideoTimeline {
		/**
		 * @private
		 */
		private var isCreated : Boolean;

		public function VideoTimeline(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
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
	}
}
