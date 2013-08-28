package ayyo.player.modules.controllpanel {
	import ayyo.player.events.ModuleEvent;
	import ayyo.player.modules.base.impl.AbstractModule;
	import ayyo.player.modules.controllpanel.controller.config.ControllBarCommandsMapping;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllPanel extends AbstractModule {
		public function ControllPanel(autoCreate : Boolean = false) {
			super(autoCreate);
		}

		override protected function onContextInited() : void {
			this.context.	configure(ControllBarCommandsMapping);
			this.dispatcher.addEventListener(ModuleEvent.READY, this.onModuleReady);
			super.onContextInited();
		}
		
		//	Handlers
		private function onModuleReady(event : ModuleEvent) : void {
			this.ready.dispatch();
		}
	}
}
