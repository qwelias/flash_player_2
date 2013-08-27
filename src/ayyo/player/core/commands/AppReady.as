package ayyo.player.core.commands {
	import ayyo.player.events.ApplicationEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AppReady implements ICommand {
		[Inject]
		public var dispacther : IEventDispatcher;
		
		public function execute() : void {
			this.dispacther.dispatchEvent(new ApplicationEvent(ApplicationEvent.READY));
			this.dispose();
		}

		private function dispose() : void {
			this.dispacther = null;
		}
	}
}
