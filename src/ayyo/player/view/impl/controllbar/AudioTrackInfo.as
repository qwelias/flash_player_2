package ayyo.player.view.impl.controllbar {
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;

	import org.osmf.net.StreamingItem;

	import flash.display.DisplayObject;
	import flash.display.Sprite;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AudioTrackInfo extends Sprite implements IHaveView, IDisposable {
		/**
		 * @private
		 */
		private var isCreated : Boolean;

		public function AudioTrackInfo(autoCreate : Boolean = true) {
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

		public function initialize(items : Vector.<StreamingItem>) : void {
			trace("AudioTrackInfo.initialize(items)");
			const length : uint = items.length;
			var item : TrackItem;
			for (var i : int = 0; i < length; i++) {
				item = new TrackItem();
				item.language = items[i].info["language"];
				item.view.x = i == 0 ? 0 : this.width + 10;
				item.enable();
				this.addChild(item.view);
			}
		}


		public function get view() : DisplayObject {
			return this;
		}
	}
}
