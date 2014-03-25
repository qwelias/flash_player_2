package ayyo.player.view.impl.controllbar {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.view.api.PlayPauseState;

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

		override public function set state(value : String) : void {
			super.state = value;
			this.removeChildren();
			if (value == PlayPauseState.PLAY) this.addChild(this._playState);
			else if (value == PlayPauseState.PAUSE) this.addChild(this._pauseState);
		}

		override protected function onButtonClick(event : MouseEvent) : void {
			super.onButtonClick(event);
			var newState : String = this._playState.parent ? PlayPauseState.PAUSE : PlayPauseState.PLAY;
			var eventType : String = this._playState.parent ? PlayerCommands.PLAY : PlayerCommands.PAUSE;
			this.state = newState;
			this.action.dispatch(eventType);
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
