package ayyo.player.modules.splash.controller.config {
	import ayyo.player.events.ModuleEvent;
	import ayyo.player.modules.splash.commands.LoadScreenshot;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SplashCommandsMapping {
		[Inject]
		public var commandMap : IEventCommandMap;

		[PostConstruct]
		public function initialize() : void {
			this.commandMap.map(ModuleEvent.READY).toCommand(LoadScreenshot).once();
		}

		[PreDestroy]
		public function destroy() : void {
		}
	}
}
