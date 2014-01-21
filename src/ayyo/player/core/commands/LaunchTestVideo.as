package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.events.DRMEvent;
	import org.osmf.events.MediaErrorEvent;
	import org.osmf.events.MediaPlayerStateChangeEvent;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DRMState;

	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LaunchTestVideo implements ICommand {
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var factory : SmoothedMediaFactory;

		public function execute() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			var media : MediaElement;
			if (this.playerConfig.video.url.indexOf("f4m") != -1) {
				this.logger.info("This is f4m video");
				this.factory.customToken = "type=online," + this.playerConfig.video.token + ",os=" + escape(Capabilities.os) + ",flashversion=" + escape(Capabilities.version) + ",browser=" + (ExternalInterface.available ? escape(ExternalInterface.call("window.navigator.userAgent.toString")) : "unknown");
				media = new F4MElement(resource, new F4MLoader(this.factory));
			} else {
				this.logger.info("This is not f4m video");
				media = this.factory.createMediaElement(resource);
			}
			this.logger.info("Load media: '{0}' with token={1}", [this.playerConfig.video.url, this.playerConfig.video.token]);

			this.player.mediaPlayer.autoDynamicStreamSwitch = true;
			this.player.mediaPlayer.autoPlay = true;
			this.player.mediaPlayer.autoRewind = false;
			this.player.mediaPlayer.media = media;

			this.player.mediaPlayer.addEventListener(MediaErrorEvent.MEDIA_ERROR, this.mediaErrorEventHandler);
			this.player.mediaPlayer.addEventListener(DRMEvent.DRM_STATE_CHANGE, this.drmStateChangeHandler);
			this.player.mediaPlayer.addEventListener(MediaPlayerStateChangeEvent.MEDIA_PLAYER_STATE_CHANGE, this.stateChangeHandler);

			this.contextView.view.addChild(this.player);
		}

		private function stateChangeHandler(event : MediaPlayerStateChangeEvent) : void {
			this.logger.info("Media player state changes to '{0}'", [event.state]);
		}

		private function drmStateChangeHandler(event : DRMEvent) : void {
			this.logger.info("DRM State is {0}", [event.drmState]);
			switch(event.drmState) {
				case DRMState.AUTHENTICATION_COMPLETE:
					// SendEventJS.sendEvent("authentication_complete.drmevent");
					break;
				case DRMState.AUTHENTICATION_ERROR:
					// SendEventJS.sendEvent("authentication_error.drmerror");
					this.logger.error("DRM auth error with '{0}' message has been handled.", [event.mediaError.errorID]);
					break;
			}
		}

		private function mediaErrorEventHandler(event : MediaErrorEvent) : void {
		}
	}
}
