package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.PlayerEvent;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.elements.F4MElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ConnectToVideo implements ICommand {
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject(name="video")]
		public var video : F4MElement;

		public function execute() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			(this.player.mediaFactory as SmoothedMediaFactory).customToken = this.playerConfig.video.token;
			this.video.resource = resource;

			this.video.addEventListener(MediaElementEvent.TRAIT_ADD, this.onAddMediaTrait);

			(this.video.getTrait(MediaTraitType.LOAD) as LoadTrait).load();
		}

		private function onAddMediaTrait(event : MediaElementEvent) : void {
			trace('event.traitType: ' + (event.traitType));
			if (event.traitType == MediaTraitType.LOAD) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_LOAD));
			else if (event.traitType == MediaTraitType.ALTERNATIVE_AUDIO) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.ALTERNATIVE_AUDIO, [this.video.getTrait(event.traitType)]));
			else if (event.traitType == MediaTraitType.PLAY) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.CAN_PLAY));
			else if (event.traitType == MediaTraitType.TIME) this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.TIME_TRAIT, [this.video.getTrait(MediaTraitType.TIME)]));
		}
	}
}
