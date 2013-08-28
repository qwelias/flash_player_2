package ayyo.player.modules.controllpanel.controller.config {
	import ayyo.player.events.ModuleEvent;
	import ayyo.player.modules.controllpanel.commands.AddControllPanelUIElements;
	import ayyo.player.modules.controllpanel.commands.ParseControllBarConfig;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;

	import flash.events.DataEvent;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllBarCommandsMapping {
		[Inject]
		public var commandMap : IEventCommandMap;

		[PostConstruct]
		public function initialize() : void {
			this.commandMap.map(DataEvent.DATA, DataEvent).toCommand(ParseControllBarConfig).once();
			this.commandMap.map(ModuleEvent.READY).toCommand(AddControllPanelUIElements).once();
		}

		[PreDestroy]
		public function destroy() : void {
			this.commandMap = null;
		}
	}
}
