package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.config.impl.support.PluginMetadata;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.plugins.info.impl.AyyoPlugin;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	import org.osmf.events.MediaFactoryEvent;
	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.media.PluginInfoResource;
	import org.osmf.media.URLResource;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadPlugins implements ICommand {
		[Inject]
		public var logger : ILogger;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var player : MediaPlayerSprite;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var contextView : ContextView;
		/**
		 * @private
		 */
		private var isFactorySubscribed : Boolean;
		/**
		 * @private
		 */
		private var currentInfo : AyyoPlugin;

		public function execute() : void {
			this.subscribeFactory();
			this.next();
		}

		/**
		 * @private load next plugin in que
		 * @return void
		 */
		private function next() : void {
			this.playerConfig.plugins.length == 0 && this.dispose();
			if (this.playerConfig) {
				this.currentInfo = this.playerConfig.plugins.shift() as AyyoPlugin;
				var resource : URLResource = new URLResource(this.currentInfo.url);
				resource.addMetadataValue(PluginMetadata.CONFIG, this.currentInfo.config);
				resource.addMetadataValue(PluginMetadata.CONTAINER, this.contextView.view);
				resource.addMetadataValue(PluginMetadata.DISPATCHER, this.dispatcher);
				this.player.mediaFactory.loadPlugin(resource);
			}
		}

		private function dispose() : void {
			this.unsubscribeFactory();
			this.dispatcher.dispatchEvent(new ApplicationEvent(ApplicationEvent.READY));
			this.logger = null;
			this.playerConfig = null;
			this.contextView = null;
			this.dispatcher = null;
		}

		/**
		 * @private subscribes MediaFactory to specific events
		 * @return void
		 * @see #unsubscribeFactory()
		 */
		private function subscribeFactory() : void {
			if (!this.isFactorySubscribed) {
				this.player.mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD, this.onPluginLoaded);
				this.player.mediaFactory.addEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, this.onPluginError);
				this.isFactorySubscribed = true;
			}
		}

		/**
		 * @private unsubscribe MediaFactory from specific events
		 * @return void
		 * @see #subscribeFactory()
		 */
		private function unsubscribeFactory() : void {
			if (this.isFactorySubscribed) {
				this.player.mediaFactory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD, this.onPluginLoaded);
				this.player.mediaFactory.removeEventListener(MediaFactoryEvent.PLUGIN_LOAD_ERROR, this.onPluginError);
				this.isFactorySubscribed = false;
			}
		}

		// Handlers
		private function onPluginLoaded(event : MediaFactoryEvent) : void {
			this.unsubscribeFactory();
			var info : String = event.resource is URLResource ? (event.resource as URLResource).url : (event.resource as PluginInfoResource).pluginInfo.frameworkVersion;
			this.logger.debug("Plugin {0} loaded", [info]);
			this.next();
		}

		private function onPluginError(event : MediaFactoryEvent) : void {
			this.unsubscribeFactory();
			var info : String = event.resource is URLResource ? (event.resource as URLResource).url : (event.resource as PluginInfoResource).pluginInfo.frameworkVersion;
			this.logger.error("Error, while loading plugin {0}", [info]);
			this.next();
		}
	}
}
