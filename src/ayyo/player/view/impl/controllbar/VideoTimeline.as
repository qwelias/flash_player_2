package ayyo.player.view.impl.controllbar {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IVideoTimeline;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoTimeline extends Sprite implements IVideoTimeline {
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _played : Shape;
		/**
		 * @private
		 */
		private var _buffered : Shape;
		/**
		 * @private
		 */
		private var _thumb : IButton;
		/**
		 * @private
		 */
		private var _duration : Number;
		/**
		 * @private
		 */
		private var _widthOfTimeline : Number = 100;
		/**
		 * @private
		 */
		private var _action : Signal;
		/**
		 * @private
		 */
		private var _value : uint;

		/**
		 * @private
		 */
		public function VideoTimeline(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.filters = [new DropShadowFilter(1, -90, 0x232323, 1, 0, 0, 1, BitmapFilterQuality.MEDIUM, true)];
				this.addChild(this.buffered);
				this.addChild(this.played);
				this.addChild(this.thumb.view);

				this.thumb.signals.mouseDown.add(this.onThumbMouseDown);
				this.thumb.enable();
				this.thumb.disable();

				this.thumb.view.y = 7;
				this.played.filters = [new DropShadowFilter(7, 90, 0xffffff, .7, 16, 16, 1, BitmapFilterQuality.MEDIUM, true), new GlowFilter(0x1965ee, .3, 5, 5, 1, BitmapFilterQuality.MEDIUM)];

				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.thumb.dispose();
				this.played.parent && this.played.parent.removeChild(this.played);
				this.buffered.parent && this.buffered.parent.removeChild(this.buffered);

				this._buffered = null;
				this._played = null;
				this._thumb = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get buffered() : Shape {
			return this._buffered ||= new Shape();
		}

		public function get played() : Shape {
			return this._played ||= new Shape();
		}

		public function get thumb() : IButton {
			return this._thumb ||= new ThumbButton();
		}

		override public function set width(value : Number) : void {
			this.graphics.clear();
			this.graphics.beginFill(0, .8);
			this.graphics.drawRoundRect(0, 0, value, 15, 6);
			this._widthOfTimeline = value;
			this.time = this._value;
		}

		public function set time(value : uint) : void {
			if (!isNaN(this._duration)) {
				var percent : Number = value / this._duration;
				if (!isNaN(this._widthOfTimeline)) {
					if (Math.abs(percent * this._widthOfTimeline - this.played.width) >= 1) {
						this.played.graphics.clear();
						this.played.graphics.beginFill(0x006fff);
						this.played.graphics.drawRoundRectComplex(0, 0, percent * this._widthOfTimeline, 13, 6, 0, 6, 0);

						this.thumb.view.x = percent * this._widthOfTimeline;
						
						this._value = value;
					}
				}
			}
		}

		public function set duration(value : uint) : void {
			this._duration = value;
			this.thumb.enable();
			this.addEventListener(MouseEvent.CLICK, this.onMouseClick);
		}
		
		public function get action() : ISignal {
			return this._action ||= new Signal(String, Array);
		}

		private function onThumbMouseDown(event : MouseEvent) : void {
			this.action.dispatch(PlayerCommands.PAUSE, null);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onThumbMouseUp);
			this.thumb.signals.enterFrame.add(this.onThumbEnterFrame);
		}

		private function onThumbEnterFrame(event : Event) : void {
			if (this.mouseX < this._widthOfTimeline && !isNaN(this._widthOfTimeline) && this.mouseX > 0) this.time = this.mouseX / this._widthOfTimeline * this._duration;
		}

		private function onThumbMouseUp(event : MouseEvent) : void {
			this.thumb.signals.enterFrame.remove(this.onThumbEnterFrame);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onThumbMouseUp);
			this.action.dispatch(PlayerCommands.SEEK, [this.thumb.view.x / this._widthOfTimeline * this._duration]);
			this.action.dispatch(PlayerCommands.PLAY, null);
		}
		
		private function onMouseClick(event : MouseEvent) : void {
			this.action.dispatch(PlayerCommands.SEEK, [this.mouseX / this._widthOfTimeline * this._duration]);
		}
	}
}
