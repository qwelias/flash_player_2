package ayyo.player.view.impl.controllbar {
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
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
		/**
		 * @private
		 */
		private var _currentTrack : TrackItem;
		/**
		 * @private
		 */
		private var _changeTrack : Signal;

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
			const length : uint = items.length;
			var item : TrackItem;
			for (var i : int = 0; i < length; i++) {
				item = new TrackItem(i);
				item.language = items[i].info["language"];
				item.action.add(this.onAction);
				item.view.x = i == 0 ? 0 : this.width + 10;
				if (i != 0 ) item.enable();
				else {
					item.disable();
					this._currentTrack = item;
				}
				this.addChild(item.view);
			}
		}

		private function onAction(trackID : String) : void {
			var id : uint = int(trackID);
			this._currentTrack.enable();
			this._currentTrack = this.getChildAt(id) as TrackItem;
			this._currentTrack.disable();
			this.changeTrack.dispatch(id);
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get changeTrack() : ISignal {
			return this._changeTrack ||= new Signal(uint);
		}
	}
}
