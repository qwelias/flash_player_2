package ayyo.player.core.controller {
	import ayyo.player.view.api.PlayPauseState;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.view.api.IPlayerControllBar;
	import ayyo.player.view.impl.controllbar.ActiveZone;
	import robotlegs.bender.extensions.mediatorMap.api.IMediator;
	import robotlegs.bender.framework.api.ILogger;
	import org.osmf.events.TimeEvent;
	import org.osmf.media.MediaElement;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllbarMediator implements IMediator {
		[Inject]
		public var controlls : IPlayerControllBar;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var video : MediaElement;
		/**
		 * @private
		 */
		private var _activeZone : ActiveZone;

		public function initialize() : void {
			this.controlls.show();
			this.controlls.action.add(this.onControlAction);
			this.controlls.view.parent.addChildAt(this.activeZone, this.controlls.view.parent.getChildIndex(this.controlls.view));

			this.activeZone.addEventListener(MouseEvent.CLICK, this.onActiveZoneClick);
			this.dispatcher.addEventListener(PlayerEvent.CAN_PLAY, this.onMediaPlayable);
			this.dispatcher.addEventListener(TimeEvent.COMPLETE, this.onPlaybackComplete);
		}

		public function destroy() : void {
			this.activeZone.removeEventListener(MouseEvent.CLICK, this.onActiveZoneClick);
			this.activeZone.parent && this.activeZone.parent.removeChild(this.activeZone);
			this._activeZone = null;
			
			this.controlls.action.remove(this.onControlAction);
			this.controlls = null;
			this.logger = null;
			this.playerConfig = null;
			this.dispatcher = null;
		}

		public function get activeZone() : ActiveZone {
			return this._activeZone ||= new ActiveZone();
		}

		// Handlers
		private function onMediaPlayable(event : PlayerEvent) : void {
			this.dispatcher.removeEventListener(PlayerEvent.CAN_PLAY, this.onMediaPlayable);
			if (event.params) this.video = event.params[0] as MediaElement;
			this.controlls.playPause.enable();
			this.playerConfig.settings.autoplay && this.controlls.playPause.click();
		}

		private function onControlAction(action : String) : void {
			if (action == PlayerCommands.PLAY || action == PlayerCommands.PAUSE) this.dispatcher.dispatchEvent(new PlayerEvent(action, [this.video]));
			else this.dispatcher.dispatchEvent(new PlayerEvent(action));
		}

		private function onActiveZoneClick(event : MouseEvent) : void {
			this.controlls.playPause.click();
		}
		
		private function onPlaybackComplete(event : TimeEvent) : void {
			this.controlls.playPause.state = PlayPauseState.PLAY;
		}
	}
}
