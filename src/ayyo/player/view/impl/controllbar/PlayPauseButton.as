package ayyo.player.view.impl.controllbar {
	import ayyo.player.core.model.PlayerCommands;

	import flash.display.Bitmap;
	import flash.events.MouseEvent;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayPauseButton extends AbstractButton {
		[Embed(source="./../../../../../../assets/controlbar/play.normal.png")]
		private var PlayButtonGraphics : Class;
		[Embed(source="./../../../../../../assets/controlbar/pause.normal.png")]
		private var PauseButtonGraphics : Class;
		/**
		 * @private
		 */
		private var _playState : Bitmap;
		/**
		 * @private
		 */
		private var _pauseState : Bitmap;

		public function PlayPauseButton(autoCreate : Boolean = true) {
			super(autoCreate);
		}

		override protected function createButton() : void {
			super.createButton();
			this._playState = new PlayButtonGraphics() as Bitmap;
			this._pauseState = new PauseButtonGraphics() as Bitmap;
			this.addChild(this._playState);
			this.enable();
			this.disable();
		}

		override protected function onButtonClick(event : MouseEvent) : void {
			super.onButtonClick(event);
			if (this._playState.parent) {
				this._playState.parent.removeChild(this._playState);
				this.addChild(this._pauseState);
				this.action.dispatch(PlayerCommands.PLAY);
			} else if (this._pauseState.parent) {
				this._pauseState.parent.removeChild(this._pauseState);
				this.addChild(this._playState);
				this.action.dispatch(PlayerCommands.PAUSE);
			}
		}
		
		override protected function enableButton() : void {
			super.enableButton();
			this.alpha = 1;
		}
		
		override protected function disableButton() : void {
			super.disableButton();
			this.alpha = .5;
		}
	}
}
