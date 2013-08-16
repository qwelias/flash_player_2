package ayyo.player.modules.base.controller.config {
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.modules.base.commands.LoadModuleConfigFile;
	import ayyo.player.modules.base.commands.TellIamReady;
	import ayyo.player.modules.base.commands.guards.OnlyIfConfigURLNotSetted;
	import ayyo.player.modules.base.commands.guards.OnlyIfConfigURLSetted;

	import me.scriptor.additional.api.IResizable;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.extensions.enhancedLogging.impl.LoggerProvider;
	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;
	import robotlegs.bender.extensions.modularity.api.IModuleConnector;
	import robotlegs.bender.framework.api.IContext;
	import robotlegs.bender.framework.api.ILogger;
	import robotlegs.bender.framework.api.LogLevel;

	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModulePrepare {
		[Inject]
		public var commandMap : IEventCommandMap;
		[Inject]
		public var mediatorMap : IMediatorMap;
		[Inject]
		public var connector : IModuleConnector;
		[Inject]
		public var context : IContext;
		[Inject]
		public var contextView : ContextView;

		[PostConstruct]
		public function init() : void {
			// injecting base objects
			var playerConfig : IPlayerConfig = this.context.injector.parent.getInstance(IPlayerConfig) as IPlayerConfig;
			playerConfig && this.context.injector.map(IPlayerConfig).toValue(playerConfig);

			this.context.injector.map(IResizable, "module").toValue(this.contextView.view.parent);

			// relaying events

			// reciving events
			this.connector.onDefaultChannel().receiveEvent(Event.RESIZE);

			// injecting logger system
			var loggerProvider : LoggerProvider = new LoggerProvider(this.context.injector.parent.getInstance(IContext));
			this.context.injector.map(ILogger).toProvider(loggerProvider);

			// TODO change to ERROR for release
			this.context.logLevel = LogLevel.DEBUG;

			// mapping commands
			this.commandMap.map(Event.INIT).toCommand(LoadModuleConfigFile).withGuards(OnlyIfConfigURLSetted).once();
			this.commandMap.map(Event.INIT).toCommand(TellIamReady).withGuards(OnlyIfConfigURLNotSetted).once();
			this.commandMap.map(Event.OPEN).toCommand(TellIamReady).once();
		}

		[PreDestroy]
		public function destroy() : void {
			this.context.injector.hasMapping(IPlayerConfig) && this.context.injector.unmap(IPlayerConfig);
			this.context.injector.hasMapping(IResizable, "module") && this.context.injector.unmap(IResizable, "module");
			this.context.injector.hasMapping(ILogger) && this.context.injector.unmap(ILogger);

			this.commandMap = null;
			this.mediatorMap = null;
			this.contextView = null;
			this.connector = null;
			this.context = null;
		}
	}
}
