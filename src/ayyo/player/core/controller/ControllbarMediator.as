package ayyo.player.core.controller {
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IPlayerControllBar;
	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;
	import org.osmf.media.MediaElement;
	import flash.events.IEventDispatcher;
	import flash.geom.Rectangle;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllbarMediator implements IMediator {
		[Inject]
		public var controlls : IPlayerControllBar;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject(name="screen")]
		public var screen : Rectangle;
		/**
		 * @private
		 */
		private var video : MediaElement;

		public function initialize() : void {
			this.controlls.show();
			this.controlls.action.add(this.onControlAction);

			this.dispatcher.addEventListener(PlayerEvent.CAN_PLAY, this.onMediaPlayable);
		}

		private function onMediaPlayable(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.CAN_PLAY, this.onMediaPlayable);
			if(event.params) this.video = event.params[0] as MediaElement;
			this.controlls.playPause.enable();
		}

		public function destroy() : void {
			this.controlls.action.remove(this.onControlAction);
			this.controlls = null;
			this.logger = null;
			this.screen = null;
			this.dispatcher = null;
		}

		// Handlers
		private function onControlAction(action : String) : void {
			if(action == PlayerCommands.PLAY || action == PlayerCommands.PAUSE) this.dispatcher.dispatchEvent(new PlayerEvent(action, [this.video]));
			else this.dispatcher.dispatchEvent(new PlayerEvent(action));
		}
	}
}
