package ayyo.player.view.impl {
	import ayyo.player.view.api.IButton;
	import ayyo.player.view.api.IPlayerControllBar;
	import ayyo.player.view.api.IVolumeBar;
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;
	import ayyo.player.view.impl.controllbar.PlayPauseButton;
	import ayyo.player.view.impl.controllbar.ScreenStateSwitcher;
	import ayyo.player.view.impl.controllbar.VolumeBar;

	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

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

		public function PlayerControllBar(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this._matrix = new Matrix();
				this.addChild(this.playPause.view);
				this.addChild(this.audioTrack.view);
				this.addChild(this.volume.view);
				this.addChild(this.screenState.view);

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
				this.graphics.beginGradientFill(GradientType.LINEAR, [0x001e21, 0x000d21], [.9, .9], [0, 0xff], this._matrix);
				this.graphics.drawRoundRect(0, 0, screen.width - MARGIN * 2, HEIGHT, 12);

				this.x = MARGIN;
				this.y = screen.height - this.height - PADDING;

				this.playPause.view.x = 2;
				this.playPause.view.y = HEIGHT - this.playPause.view.height >> 1;

				this.screenState.view.x = screen.width - MARGIN * 2 - this.screenState.view.width - PADDING;
				this.screenState.view.y = HEIGHT - this.screenState.view.height >> 1;

				this.volume.view.x = this.screenState.view.x - this.volume.view.width - PADDING;
				this.volume.view.y = HEIGHT - 10 >> 1;

				this.audioTrack.view.x = this.volume.view.x - this.audioTrack.view.width - PADDING;
				this.audioTrack.view.y = HEIGHT - 10 >> 1;
			}
		}

		public function get action() : ISignal {
			return this._action ||= new Signal(String);
		}

		public function show() : void {
			this.tweener.play();
		}

		public function hide() : void {
			this.tweener.reverse();
		}

		public function get tweener() : TweenLite {
			return this._tweener ||= TweenLite.fromTo(this, .5, {alpha:0}, {alpha:1, ease:Quad.easeOut});
		}
	}
}
