package ayyo.player.view.impl {
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.ui.Mouse;
	import flash.geom.Point;

	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IPlayerControllBar;
	import ayyo.player.view.api.IVideoTimeline;
	import ayyo.player.view.api.IVideoTimer;
	import ayyo.player.view.api.IVolumeBar;
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;
	import ayyo.player.view.impl.controllbar.PlayPauseButton;
	import ayyo.player.view.impl.controllbar.ScreenStateSwitcher;
	import ayyo.player.view.impl.controllbar.VideoTimeline;
	import ayyo.player.view.impl.controllbar.VideoTimer;
	import ayyo.player.view.impl.controllbar.VolumeBar;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;
	import org.osflash.signals.natives.NativeSignal;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerControllBar extends Sprite implements IPlayerControllBar {
		private static const MARGIN : Number = 30;
		private static const HEIGHT : Number = 40;
		private static const PADDING : Number = 10;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _playPause : IButton;
		/**
		 * @private
		 */
		private var _volume : IVolumeBar;
		/**
		 * @private
		 */
		private var _screenState : IButton;
		/**
		 * @private
		 */
		private var _matrix : Matrix;
		/**
		 * @private
		 */
		private var _action : Signal;
		/**
		 * @private
		 */
		private var _tweener : TweenLite;
		/**
		 * @private
		 */
		private var _track : AudioTrackInfo;
		/**
		 * @private
		 */
		private var _timeline : VideoTimeline;
		/**
		 * @private
		 */
		private var _timer : VideoTimer;
		/**
		 * @private
		 */
		private var hideTimeoutID : uint;
		/**
		 * @private
		 */
		private var _enterFrame : NativeSignal;
		/**
		 * @private
		 */
		private var _mousePoint : Point;

		public function PlayerControllBar(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this._matrix = new Matrix();

				this.addChild(this.playPause.view);
				this.addChild(this.timeline.view);
				this.addChild(this.timer.view);
				this.addChild(this.audioTrack.view);
				this.addChild(this.volume.view);
				this.addChild(this.screenState.view);

				this.stage ? this.addListeners() : this.addEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);

				this.alpha = 0;

				this.playPause.action.add(this.action.dispatch);
				this.screenState.action.add(this.action.dispatch);

				this.filters = [new DropShadowFilter(1, 90, 0xfff2b3, .2, 0, 0, 1, BitmapFilterQuality.MEDIUM, true)];

				this.cacheAsBitmap = true;
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.removeListeners();
				this._tweener.kill();
				this.isCreated = false;
			}
		}

		public function get view() : DisplayObject {
			return this;
		}

		public function get playPause() : IButton {
			return this._playPause ||= new PlayPauseButton();
		}

		public function get timeline() : IVideoTimeline {
			return this._timeline ||= new VideoTimeline();
		}

		public function get timer() : IVideoTimer {
			return this._timer ||= new VideoTimer();
		}

		public function get audioTrack() : AudioTrackInfo {
			return this._track ||= new AudioTrackInfo();
		}

		public function get volume() : IVolumeBar {
			return this._volume ||= new VolumeBar();
		}

		public function get screenState() : IButton {
			return this._screenState ||= new ScreenStateSwitcher();
		}

		public function resize(screen : Rectangle = null) : void {
			if (screen) {
				this.graphics.clear();
				this._matrix.identity();
				this._matrix.createGradientBox(screen.width - MARGIN * 2, HEIGHT, -Math.PI / 2);
				this.graphics.beginGradientFill(GradientType.LINEAR, [0x000d21, 0x001e21], [.9, .9], [0, 0xff], this._matrix);
				this.graphics.drawRoundRect(0, 0, screen.width - MARGIN * 2, HEIGHT, 12);

				this.x = MARGIN;
				this.y = screen.height - this.height - PADDING;

				this.playPause.view.x = 3;
				this.playPause.view.y = (HEIGHT - this.playPause.view.height >> 1) + 1;

				this.screenState.view.x = screen.width - MARGIN * 2 - this.screenState.view.width - PADDING;
				this.screenState.view.y = HEIGHT - this.screenState.view.height >> 1;

				this.volume.view.x = this.screenState.view.x - this.volume.view.width - PADDING;
				this.volume.view.y = HEIGHT - this.volume.view.height >> 1;

				this.audioTrack.view.x = this.volume.view.x - this.audioTrack.view.width - PADDING;
				this.audioTrack.view.y = HEIGHT - 10 >> 1;

				this.timer.view.x = this.audioTrack.view.x - this.timer.view.width - PADDING;
				this.timer.view.y = HEIGHT - this.timer.view.height >> 1;

				this.timeline.view.x = this.playPause.view.x + this.playPause.view.width + PADDING;
				this.timeline.view.y = HEIGHT - 14 >> 1;
				this.timeline.view.width = screen.width - (screen.width - this.timer.view.x) - this.timeline.view.x - PADDING;
			}
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String);
		}

		public function get enterFrame() : ISignal {
			return this._enterFrame ||= new NativeSignal(this, Event.ENTER_FRAME);
		}

		public function get mousePoint() : Point {
			return this._mousePoint ||= new Point(this.mouseX, this.mouseY);
		}

		public function show() : void {
			clearTimeout(this.hideTimeoutID);
			this.tweener.play();
			Mouse.show();
		}

		public function hide() : void {
			clearTimeout(this.hideTimeoutID);
			this.tweener.reverse();
			Mouse.hide();
			this.enterFrame.add(this.onEnterFrame);
		}

		public function get tweener() : TweenLite {
			return this._tweener ||= TweenLite.fromTo(this, .5, {alpha:0}, {alpha:1, ease:Quad.easeOut});
		}

		private function addListeners() : void {
			this.stage.addEventListener(Event.MOUSE_LEAVE, this.onMouseLeave);
			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyDown);
		}

		private function removeListeners() : void {
			this.stage.removeEventListener(Event.MOUSE_LEAVE, this.onMouseLeave);
		}

		// Handlers
		private function onMouseLeave(event : Event) : void {
			clearTimeout(this.hideTimeoutID);
			this.enterFrame.removeAll();
			this.mousePoint.x = this.mouseX;
			this.mousePoint.y = this.mouseY;
			this.hideTimeoutID = setTimeout(this.hide, 1000);
		}

		private function onEnterFrame(event : Event) : void {
			if (Math.abs(this.mousePoint.x - this.mouseX) > 3 || Math.abs(this.mousePoint.y - this.mouseY) > 3) {
				this.mousePoint.x = this.mouseX;
				this.mousePoint.y = this.mouseY;
				this.show();
			} else {
				this.alpha == 1 && this.onMouseLeave(null);
			}
		}

		private function onAddedToStage(event : Event) : void {
			this.removeEventListener(Event.ADDED_TO_STAGE, this.onAddedToStage);
			this.addListeners();
		}

		private function onKeyDown(event : KeyboardEvent) : void {
			if (event.keyCode == Keyboard.SPACE) this.playPause.click();
			else if (event.keyCode == Keyboard.F) this.screenState.click();
		}
	}
}
