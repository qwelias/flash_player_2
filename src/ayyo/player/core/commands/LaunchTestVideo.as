package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;

	import osmf.patch.SmoothedMediaFactory;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.elements.F4MElement;
	import org.osmf.elements.F4MLoader;
	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.layout.ScaleMode;
	import org.osmf.media.MediaElement;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;
	import org.osmf.metadata.Metadata;

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
		public var factory : SmoothedMediaFactory;

		public function execute() : void {
			this.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, this.onPluginLoaded);
			this.factory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, this.onPluginError);
			this.factory.loadPlugin(new URLResource("file:///Users/zaynutdinov/Documents/Projects/Private/AyyoPlayer/bin/plugins/test/TestPlugin.swf"));
		}

		private function playVideo() : void {
			var resource : URLResource = new URLResource(this.playerConfig.video.url);
			var media : MediaElement;
			var player : MediaPlayerSprite = new MediaPlayerSprite();
			if (this.playerConfig.video.url.indexOf("f4m") != -1) {
				this.factory.customToken = this.playerConfig.video.token;
				media = new F4MElement(resource, new F4MLoader(this.factory));
			} else {
				media = this.factory.createMediaElement(resource);
			}

			var subs : Metadata = new Metadata();
			subs.addValue("Testvalue", 42);
			media.addMetadata("subs", subs);

			player.mediaPlayer.autoDynamicStreamSwitch = true;
			player.mediaPlayer.autoPlay = true;
			player.mediaPlayer.autoRewind = false;
			player.scaleMode = ScaleMode.ZOOM;
			player.mediaPlayer.media = media;

			this.contextView.view.addChild(player);
		}

		private function onPluginError(event : MediaFactoryEvent) : void {
			var info : String;
			if (event.resource is URLResource) info = (event.resource as URLResource).url;
			else if (event.resource is PluginInfoResource) info = (event.resource as PluginInfoResource).pluginInfo.frameworkVersion;
			this.logger.error("Plugin loading failure at {0}", [info]);
		}

		private function onPluginLoaded(event : MediaFactoryEvent) : void {
			var info : String;
			if (event.resource is URLResource) info = (event.resource as URLResource).url;
			else if (event.resource is PluginInfoResource) info = (event.resource as PluginInfoResource).pluginInfo.frameworkVersion;
			this.logger.debug("Plugin loaded from {0}", [info]);

			this.playVideo();
		}
	}
}
