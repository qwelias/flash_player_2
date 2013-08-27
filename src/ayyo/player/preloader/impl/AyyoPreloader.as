package ayyo.player.preloader.impl {
	import com.greensock.events.TweenEvent;
	import ayyo.player.preloader.api.IAyyoPreloader;

	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;

	import org.osflash.signals.ISignal;
	import org.osflash.signals.Signal;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AyyoPreloader extends Sprite implements IAyyoPreloader {
		public static const BOUNDS : Number = 30;
		public static const COLOR : uint = 0xe7e7e7;
		/**
		 * @private
		 */
		private var isCreated : Boolean;
		/**
		 * @private
		 */
		private var _progress : Number;
		/**
		 * @private
		 */
		private var _showHide : TweenLite;
		/**
		 * @private
		 */
		private var _animation : TweenLite;
		/**
		 * @private
		 */
		private var _film : FilmShape;
		/**
		 * @private
		 */
		private var _animationComplete : ISignal;

		public function AyyoPreloader(autoCreate : Boolean = true) {
			autoCreate && this.create();
		}

		public function create() : void {
			if (!this.isCreated) {
				this.addChild(this.film);
				this.hide(true);
				this.isCreated = true;
			}
		}

		public function dispose() : void {
			if (this.isCreated) {
				this.stop();
				this.film.dispose();
				this.animation.kill();
				this.showHide.kill();
				this.animationComplete.removeAll();
				
				this._film = null;
				this._animationComplete = null;
				this._animation = null;
				this._showHide = null;
				this.isCreated = false;
				this.parent && this.parent.removeChild(this);
			}
		}

		public function resize(screen : Rectangle = null) : void {
			this.x = screen.width >> 1;
			this.y = screen.height >> 1;
		}
		
		public function play() : void {
			this.animation.play(null, false);
		}

		public function stop() : void {
			this.animation.pause();
		}

		public function show(immediately : Boolean = false) : void {
			this.play();
			immediately ? this.showHide.pause(this.showHide._totalTime) : this.showHide.play();
		}

		public function hide(immediately : Boolean = false) : void {
			immediately ? this.showHide.pause(0) : this.showHide.reverse(null, true);
		}

		public function get progress() : Number {
			return this._progress ||= 0;
		}

		public function set progress(value : Number) : void {
			this.progress != value && this.update(value);
		}

		public function get view() : DisplayObject {
			return this;
		}
		
		public function get film() : FilmShape {
			return this._film ||= new FilmShape();
		}

		public function get showHide() : TweenLite {
			this._showHide ||= TweenLite.fromTo(this, .7,
				{alpha:0},
				{
					alpha:1,
					ease:Cubic.easeOut,
					onReverseComplete:this.animationComplete.dispatch,
					onReverseCompleteParams:[TweenEvent.REVERSE_COMPLETE, this],
					onComplete:this.animationComplete.dispatch,
					onCompleteParams:[TweenEvent.COMPLETE, this]
				});
			return this._showHide;
		}
		
		public function get animation() : TweenLite {
			return this._animation ||= TweenLite.to(this.film, 1, {rotation:360, ease:Linear.easeNone, onComplete:this.resetAnimation});
		}
		
		public function get animationComplete() : ISignal {
			return this._animationComplete ||= new Signal(String, IAyyoPreloader);
		}

		private function update(value : Number) : void {
			this._progress = value;
		}

		private function resetAnimation() : void {
			this.animation.invalidate();
			this.play();
		}
	}
}
