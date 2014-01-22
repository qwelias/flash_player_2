package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.commands.AppReady;
	import ayyo.player.core.commands.GetApplicationConfig;
	import ayyo.player.core.commands.LaunchTestVideo;
	import ayyo.player.core.commands.LoadBinData;
	import ayyo.player.core.commands.NullCommand;
	import ayyo.player.core.commands.RegisterAsset;
	import ayyo.player.core.commands.guards.OnlyIfPreloaderExists;
	import ayyo.player.core.commands.guards.OnlyIfTypeIsAssets;
	import ayyo.player.core.commands.hooks.CreatePreloader;
	import ayyo.player.core.commands.hooks.DisposePreloader;
	import ayyo.player.core.commands.hooks.InitStageOptions;
	import ayyo.player.core.commands.hooks.SaveScreen;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.events.BinDataEvent;
	import ayyo.player.events.ResizeEvent;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.modularity.api.IModuleConnector;

	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerCommandsMapping {
		[Inject]
		public var commandMap : IEventCommandMap;
		[Inject]
		public var connector : IModuleConnector;

		[PostConstruct]
		public function initialize() : void {
			this.connector.onDefaultChannel().relayEvent(Event.RESIZE);
			this.commandMap.map(ResizeEvent.RESIZE, ResizeEvent).toCommand(NullCommand).withHooks(SaveScreen);
			
			this.commandMap.map(ApplicationEvent.LAUNCH).toCommand(GetApplicationConfig).withHooks(InitStageOptions).once();
			this.commandMap.map(BinDataEvent.LOAD, BinDataEvent).toCommand(LoadBinData).withHooks(CreatePreloader);
			this.commandMap.map(BinDataEvent.ITEM_LOADED, BinDataEvent).toCommand(RegisterAsset).withGuards(OnlyIfTypeIsAssets);
			this.commandMap.map(BinDataEvent.COMPLETE, BinDataEvent).toCommand(AppReady).withGuards(OnlyIfTypeIsAssets).once();
			
			this.commandMap.map(ApplicationEvent.READY).toCommand(LaunchTestVideo).withHooks(DisposePreloader).withGuards(OnlyIfPreloaderExists).once();
		}

		[PreDestroy]
		public function destroy() : void {
			this.commandMap.unmap(BinDataEvent.LOAD, BinDataEvent).fromCommand(LoadBinData);
			this.commandMap.unmap(BinDataEvent.COMPLETE, BinDataEvent).fromCommand(RegisterAsset);
			this.commandMap.unmap(ResizeEvent.RESIZE, ResizeEvent).fromCommand(NullCommand);
			this.commandMap = null;
			
			this.connector = null;
		}
	}
}
