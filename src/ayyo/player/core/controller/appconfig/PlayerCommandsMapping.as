package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.commands.GetApplicationConfig;
	import ayyo.player.core.commands.hooks.InitStageOptions;
	import ayyo.player.events.ApplicationEvent;

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
		}

		[PreDestroy]
		public function destroy() : void {
			this.commandMap = null;
		}
	}
}
