package ayyo.player.modules.controllpanel {
	import ayyo.player.events.ModuleEvent;
	import ayyo.player.modules.base.impl.AbstractModule;
	import ayyo.player.modules.controllpanel.controller.config.ControllBarCommandsMapping;
	import ayyo.player.modules.controllpanel.controller.config.ControllBarInjections;
	import ayyo.player.modules.controllpanel.controller.config.ControllBarMediatorsMapping;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ControllPanel extends AbstractModule {
		public function ControllPanel(autoCreate : Boolean = false) {
			super(autoCreate);
		}

		override protected function onContextInited() : void {
			this.context.	configure(ControllBarCommandsMapping).
							configure(ControllBarInjections).
							configure(ControllBarMediatorsMapping);
			this.dispatcher.addEventListener(ModuleEvent.READY, this.onModuleReady);
			super.onContextInited();
		}
		
		//	Handlers
		private function onModuleReady(event : ModuleEvent) : void {
			this.ready.dispatch();
		}
	}
}
