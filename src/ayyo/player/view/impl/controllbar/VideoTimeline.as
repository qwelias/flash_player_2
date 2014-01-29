package ayyo.player.view.impl.controllbar {
	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IVideoTimeline;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
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
		private var _duration : uint = 1;
		/**
		 * @private
		 */
		private var _widthOfTimeline : Number = 100;

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
		}

		public function set time(value : uint) : void {
			var percent : Number = value / this._duration;
			if (!isNaN(this._widthOfTimeline)) {
				if (int(percent * this._widthOfTimeline) > int(this.played.width)) {
					trace("VideoTimeline.time(value)");
					this.played.graphics.clear();
					this.played.graphics.beginFill(0x006fff);
					this.played.graphics.drawRoundRectComplex(0, 0, percent * this._widthOfTimeline, 13, 6, 0, 6, 0);

					this.thumb.view.x = percent * this._widthOfTimeline;
				}
			}
		}

		public function set duration(value : uint) : void {
			trace("VideoTimeline.duration(value)");
			this._duration = value;
		}
	}
}
