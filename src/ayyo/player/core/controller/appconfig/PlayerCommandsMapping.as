package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.commands.ConnectToVideo;
	import ayyo.player.core.commands.GetApplicationConfig;
	import ayyo.player.core.commands.LoadBinData;
	import ayyo.player.core.commands.LoadPlugins;
	import ayyo.player.core.commands.NullCommand;
	import ayyo.player.core.commands.RegisterAsset;
	import ayyo.player.core.commands.SwitchPlayPause;
	import ayyo.player.core.commands.SwitchScreenState;
	import ayyo.player.core.commands.guards.OnlyIfPreloaderExists;
	import ayyo.player.core.commands.guards.OnlyIfTypeIsAssets;
	import ayyo.player.core.commands.hooks.CheckAvaliableAssets;
	import ayyo.player.core.commands.hooks.CreatePreloader;
	import ayyo.player.core.commands.hooks.DisposePreloader;
	import ayyo.player.core.commands.hooks.InitInterface;
	import ayyo.player.core.commands.hooks.InitMediaPlayer;
	import ayyo.player.core.commands.hooks.InitStageOptions;
	import ayyo.player.core.commands.hooks.LoadSplashScreen;
	import ayyo.player.core.commands.hooks.SaveScreen;
	import ayyo.player.core.model.PlayerCommands;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.events.AssetEvent;
	import ayyo.player.events.BinDataEvent;
	import ayyo.player.events.PlayerEvent;
	import ayyo.player.events.ResizeEvent;
	import ayyo.player.plugins.event.PluginEvent;

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

			this.commandMap.map(ApplicationEvent.LAUNCH).toCommand(GetApplicationConfig).withHooks(InitStageOptions, InitMediaPlayer).once();
			this.commandMap.map(BinDataEvent.LOAD, BinDataEvent).toCommand(LoadBinData).withHooks(CreatePreloader);
			this.commandMap.map(BinDataEvent.LOADED, BinDataEvent).toCommand(RegisterAsset).withGuards(OnlyIfTypeIsAssets);
			this.commandMap.map(AssetEvent.REGISTRED).toCommand(NullCommand).withHooks(CheckAvaliableAssets);
			this.commandMap.map(PluginEvent.LOAD).toCommand(LoadPlugins);

			this.commandMap.map(ApplicationEvent.READY).toCommand(NullCommand).withHooks(DisposePreloader, LoadSplashScreen).withGuards(OnlyIfPreloaderExists).once();

			this.commandMap.map(PlayerEvent.SPLASH_LOADED, PlayerEvent).toCommand(ConnectToVideo).once();
			this.commandMap.map(PlayerEvent.CAN_LOAD, PlayerEvent).toCommand(NullCommand).withHooks(InitInterface);
			this.commandMap.map(PlayerCommands.FULLSCREEN, PlayerEvent).toCommand(SwitchScreenState);
			this.commandMap.map(PlayerCommands.NORMALSCREEN, PlayerEvent).toCommand(SwitchScreenState);
			this.commandMap.map(PlayerCommands.PLAY, PlayerEvent).toCommand(SwitchPlayPause);
			this.commandMap.map(PlayerCommands.PAUSE, PlayerEvent).toCommand(SwitchPlayPause);
		}

		[PreDestroy]
		public function destroy() : void {
			this.commandMap.unmap(BinDataEvent.LOAD, BinDataEvent).fromCommand(LoadBinData);
			this.commandMap.unmap(BinDataEvent.LOADED, BinDataEvent).fromCommand(RegisterAsset);
			this.commandMap.unmap(ResizeEvent.RESIZE, ResizeEvent).fromCommand(NullCommand);

			this.commandMap.unmap(PlayerEvent.CAN_LOAD, PlayerEvent).fromCommand(NullCommand);
			this.commandMap.unmap(PlayerCommands.FULLSCREEN, PlayerEvent).fromCommand(SwitchScreenState);
			this.commandMap.unmap(PlayerCommands.NORMALSCREEN, PlayerEvent).fromCommand(SwitchScreenState);
			this.commandMap.unmap(PlayerCommands.PLAY, PlayerEvent).fromCommand(SwitchPlayPause);
			this.commandMap.unmap(PlayerCommands.PAUSE, PlayerEvent).fromCommand(SwitchPlayPause);

			this.commandMap = null;

			this.connector = null;
		}
	}
}
