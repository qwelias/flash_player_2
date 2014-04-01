package ayyo.player.view.impl.controllbar {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.api.IVideoTimer;

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
			this.container.graphics.beginFill(0, .8);
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
						else if(thumbXPosition > this._widthOfTimeline - this.thumb.view.width / 2) thumbXPosition = this._widthOfTimeline - this.thumb.view.width / 2;
						
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
