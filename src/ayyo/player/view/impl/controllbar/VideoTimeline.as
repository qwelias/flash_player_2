package ayyo.player.view.impl.controllbar {
	import com.greensock.easing.Quad;

	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.api.IVideoTimer;

	import com.greensock.TweenLite;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.sets.InteractiveObjectSignalSet;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;

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
		private var _signals : InteractiveObjectSignalSet;
		/**
		 * @private
		 */
		private var _pointer : Shape;
		/**
		 * @private
		 */
		private var _timer : VideoTimer;
		/**
		 * @private
		 */
		private var _container : Sprite;
		/**
		 * @private
		 */
		private var isThumbPressed : Boolean;
		/**
		 * @private
		 */
		private var _bitrate : Number;
		/**
		 * @private
		 */
		private var _seekedValue : uint;
		/**
		 * @private
		 */
		private var _currentOffset : Number = 0;
		public var amount : Number;
		/**
		 * @private
		 */
		private var currentBufferBarWidth : Number;

		/**
		 * @private
		 */
		public function VideoTimeline(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.container.filters = [new DropShadowFilter(1, -90, 0x232323, 1, 0, 0, 1, BitmapFilterQuality.HIGH, true)];

				this.pointer.graphics.lineStyle(1, 0xffffff, .7);
				this.pointer.graphics.moveTo(0, 1);
				this.pointer.graphics.lineTo(0, 13);
				this.pointer.visible = false;

				this.container.addChild(this.buffered);
				this.container.addChild(this.played);
				this.container.addChild(this.pointer);
				this.container.addChild(this.thumb.view);
				this.addChild(this.container);
				this.addChild(this.timer.view);

				this.signals.mouseOver.addOnce(this.onMouseOver);
				this.thumb.signals.mouseDown.add(this.onThumbMouseDown);
				this.thumb.enable();
				this.thumb.disable();

				this.thumb.view.y = 7;
				this.thumb.view.x = this.thumb.view.width >> 1;
				this._timer.textfield.defaultTextFormat = new TextFormat("Arial Bold", 9, 0xffffff, true);
				this._timer.mouseEnabled = false;
				this.timer.time = 0;
				this.timer.view.y = -this.timer.view.height;
				this.played.filters = [new DropShadowFilter(7, 90, 0xffffff, .7, 16, 16, 1, BitmapFilterQuality.HIGH, true), new GlowFilter(0x1965ee, .3, 5, 5, 1, BitmapFilterQuality.HIGH)];

				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.thumb.dispose();
				this.played.parent && this.played.parent.removeChild(this.played);
				this.buffered.parent && this.buffered.parent.removeChild(this.buffered);
				this.pointer.parent && this.pointer.parent.removeChild(this.pointer);
				this.container.parent && this.container.parent.removeChild(this.container);
				this.timer.dispose();
				this.signals.removeAll();

				this._signals = null;
				this._buffered = null;
				this._played = null;
				this._thumb = null;
				this._pointer = null;
				this._timer = null;
				this._container = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}

		public function get container() : Sprite {
			return this._container ||= new Sprite();
		}

		public function get timer() : IVideoTimer {
			return this._timer ||= new VideoTimer(true, false);
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get signals() : InteractiveObjectSignalSet {
			return this._signals ||= new InteractiveObjectSignalSet(this);
		}

		public function get pointer() : Shape {
			return this._pointer ||= new Shape();
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
			this.container.graphics.clear();
			this.container.graphics.beginFill(0, .7);
			this.container.graphics.drawRoundRect(0, 0, value, 15, 6);
			this._widthOfTimeline = value;
			this.time = this._value;
		}

		public function set time(value : uint) : void {
			if (!isNaN(this._duration)) {
				var percent : Number = value / this._duration;
				if (!isNaN(this._widthOfTimeline)) {
					if (Math.abs(percent * this._widthOfTimeline - this.played.width) >= 1) {
						var thumbXPosition : int = percent * this._widthOfTimeline;
						if (thumbXPosition < this.thumb.view.width >> 1) thumbXPosition = this.thumb.view.width >> 1;
						else if (thumbXPosition > this._widthOfTimeline - this.thumb.view.width / 2) thumbXPosition = this._widthOfTimeline - this.thumb.view.width / 2;

						this.thumb.view.x = thumbXPosition;

						this.played.graphics.clear();
						this.played.graphics.beginFill(0x006fff);
						this.played.graphics.drawRoundRect(0, 1, this.thumb.view.x, 12, 6);

						this._value = value;
					}
					!this.pointer.visible && this.setTimerPositionAccordingBy(this.thumb.view.x);
					!this.pointer.visible && (this.timer.time = value);
				}
			}
		}

		public function set duration(value : uint) : void {
			this._duration = value;
			this.thumb.enable();
			this.signals.click.add(this.onMouseClick);
		}

		public function get controlable() : Boolean {
			return true;
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String, Array);
		}

		public function set loaded(value : Number) : void {
			if (!isNaN(this._bitrate) && !isNaN(this._duration)) {
				const bytesTotal : uint = ((this._bitrate * this._duration) / 8) * 1024;
				const currentPercent : Number = value / bytesTotal;
				const startPosition : Number = (this._seekedValue / this._duration) * this._widthOfTimeline;
				this._currentOffset += this._widthOfTimeline * currentPercent;
				if (this._currentOffset + startPosition > this._widthOfTimeline) {
					this._currentOffset = this._widthOfTimeline - startPosition;
				}
				this.amount = 0;
				this.currentBufferBarWidth = this.buffered.width;
				trace('this._currentOffset: ' + (this._currentOffset));
				trace('this.currentBufferBarWidth: ' + (this.currentBufferBarWidth));
				TweenLite.killTweensOf(this);
				TweenLite.to(this, .7, {amount:1, onUpdate:this.updateBufferBar, onUpdateParams:[startPosition], ease:Quad.easeOut});
			}
		}

		public function set bitrate(value : Number) : void {
			this._bitrate = value;
		}

		private function updateBufferBar(startPosition : Number) : void {
			var widthPosition : Number = this.currentBufferBarWidth + (this._currentOffset - this.currentBufferBarWidth) * this.amount;
			this.buffered.graphics.clear();
			this.buffered.graphics.beginFill(0x0c2d59);
			this.buffered.graphics.drawRoundRect(startPosition, 1, widthPosition, 12, 6);
		}

		private function setTimerPositionAccordingBy(value : Number) : void {
			if (value > this.timer.view.width >> 1 && value < this._widthOfTimeline - this.timer.view.width) this.timer.view.x = value - this.timer.view.width / 2;
			else this.timer.view.x = value <= this.timer.view.width >> 1 ? 0 : this._widthOfTimeline - this.timer.view.width;
		}

		private function onThumbMouseDown(event : MouseEvent) : void {
			this.action.dispatch(ThumbAction.PRESSED, null);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, this.onThumbMouseUp);
			this.thumb.signals.enterFrame.add(this.onThumbEnterFrame);
			this.isThumbPressed = true;
		}

		private function onThumbEnterFrame(event : Event) : void {
			if (this.mouseX < this._widthOfTimeline && !isNaN(this._widthOfTimeline) && this.mouseX > 0) this.time = this.mouseX / this._widthOfTimeline * this._duration;
		}

		private function onThumbMouseUp(event : MouseEvent) : void {
			this.thumb.signals.enterFrame.remove(this.onThumbEnterFrame);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, this.onThumbMouseUp);
			this.action.dispatch(ThumbAction.RELEASED, null);
			this.isThumbPressed = false;
			var time : uint = this.thumb.view.x <= this.thumb.view.width >> 1 ? 0 : (this.thumb.view.x >= this._widthOfTimeline - (this.thumb.view.width >> 1) ? this._duration - 1 : this.thumb.view.x / this._widthOfTimeline * this._duration);
			this.seekTo(time);
		}

		private function seekTo(currentTime : uint) : void {
			this._seekedValue = currentTime;
			this._currentOffset = 0;
			this.time = currentTime;
			this.action.dispatch(PlayerCommands.SEEK, [currentTime]);
		}

		private function onMouseOver(event : MouseEvent) : void {
			if (!this.isThumbPressed) {
				this.signals.enterFrame.add(this.onUpdatePointerPosition);
				this.pointer.visible = true;
			}
			this.signals.mouseOut.addOnce(this.onMouseOut);
		}

		private function onMouseOut(event : MouseEvent) : void {
			this.signals.enterFrame.remove(this.onUpdatePointerPosition);
			this.signals.mouseOver.addOnce(this.onMouseOver);
			this.pointer.visible = false;
			this.setTimerPositionAccordingBy(this.thumb.view.x);
		}

		private function onUpdatePointerPosition(event : Event) : void {
			this.pointer.x = this.mouseX;
			this.setTimerPositionAccordingBy(this.pointer.x);
			var value : uint = this.pointer.x / this._widthOfTimeline * this._duration > 0 ? this.pointer.x / this._widthOfTimeline * this._duration : 0;
			this.timer.time = value;
		}

		private function onMouseClick(event : MouseEvent) : void {
			this.seekTo(this.mouseX / this._widthOfTimeline * this._duration);
		}
	}
}
