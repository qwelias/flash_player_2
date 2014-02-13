package ayyo.player.core.commands.hooks {
	import robotlegs.bender.framework.api.ILogger;
	import org.osmf.events.MediaErrorEvent;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.PlayerEvent;

	import robotlegs.bender.framework.api.IHook;

	import org.osmf.elements.ImageElement;
	import org.osmf.events.MediaElementEvent;
	import org.osmf.layout.HorizontalAlign;
	import org.osmf.layout.LayoutMetadata;
	import org.osmf.layout.ScaleMode;
	import org.osmf.layout.VerticalAlign;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.URLResource;
	import org.osmf.traits.DisplayObjectTrait;
	import org.osmf.traits.MediaTraitType;

	import flash.display.Loader;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadSplashScreen implements IHook {
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var logger : ILogger;
		/**
		 * @private
		 */
		private var _image : ImageElement;

		public function hook() : void {
			var resource : URLResource = new URLResource(this.playerConfig.settings.screenshot);
			this._image = this.player.mediaFactory.createMediaElement(resource) as ImageElement;
			this._image.smoothing = true;
			this._image.addEventListener(MediaElementEvent.TRAIT_ADD, this.onTraitAdded);
			this._image.addEventListener(MediaErrorEvent.MEDIA_ERROR, this.onMediaError);
			var layout : LayoutMetadata = new LayoutMetadata();
			layout.scaleMode = ScaleMode.LETTERBOX;
			layout.verticalAlign = VerticalAlign.MIDDLE;
			layout.horizontalAlign = HorizontalAlign.CENTER;
			layout.percentWidth = 100;
			layout.percentHeight = 100;
			this._image.addMetadata(LayoutMetadata.LAYOUT_NAMESPACE, layout);
			this.player.media = this._image;
		}
		
		private function dispose() : void {
			this._image.removeEventListener(MediaElementEvent.TRAIT_ADD, this.onTraitAdded);
			this._image.removeEventListener(MediaErrorEvent.MEDIA_ERROR, this.onMediaError);
			this._image = null;
			this.playerConfig = null;
			this.dispatcher = null;
			this.logger = null;
		}
		
		private function nextStep() : void {
			this.dispatcher.dispatchEvent(new PlayerEvent(PlayerEvent.SPLASH_LOADED));
			this.dispose();
		}

		private function onMediaError(event : MediaErrorEvent) : void {
			this.logger.error(event.error.message);
			this.nextStep();
		}

		private function onTraitAdded(event : MediaElementEvent) : void {
			event.traitType == MediaTraitType.DISPLAY_OBJECT && this.next();
		}

		private function next() : void {
			var trait : DisplayObjectTrait = this._image.getTrait(MediaTraitType.DISPLAY_OBJECT) as DisplayObjectTrait;
			trait.displayObject is Loader && this.nextStep();
		}
	}
}
