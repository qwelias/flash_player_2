package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.commands.GetApplicationConfig;
	import ayyo.player.core.commands.LoadBinData;
	import ayyo.player.core.commands.RegisterAsset;
	import ayyo.player.core.commands.RegisterModule;
	import ayyo.player.core.commands.guards.OnlyIfTypeIsAssets;
	import ayyo.player.core.commands.guards.OnlyIfTypeIsModule;
	import ayyo.player.core.commands.hooks.InitStageOptions;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerCommandsMapping {
		[Inject]
		public var commandMap : IEventCommandMap;

		[PostConstruct]
		public function initialize() : void {
			this.commandMap.map(ApplicationEvent.LAUNCH).toCommand(GetApplicationConfig).withHooks(InitStageOptions).once();
			this.commandMap.map(BinDataEvent.LOAD, BinDataEvent).toCommand(LoadBinData);
			this.commandMap.map(BinDataEvent.COMPLETE, BinDataEvent).toCommand(RegisterAsset).withGuards(OnlyIfTypeIsAssets);
			this.commandMap.map(BinDataEvent.COMPLETE, BinDataEvent).toCommand(RegisterModule).withGuards(OnlyIfTypeIsModule);
		}

		[PreDestroy]
		public function destroy() : void {
			this.commandMap.unmap(BinDataEvent.LOAD, BinDataEvent).fromCommand(LoadBinData);
			this.commandMap.unmap(BinDataEvent.COMPLETE, BinDataEvent).fromCommand(RegisterAsset);
			this.commandMap.unmap(BinDataEvent.COMPLETE, BinDataEvent).fromCommand(RegisterModule);
			this.commandMap = null;
		}
	}
}
