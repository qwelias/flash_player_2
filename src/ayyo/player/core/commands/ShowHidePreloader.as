package ayyo.player.core.commands {
	import ayyo.player.core.commands.hooks.CreatePreloader;
	import ayyo.player.core.commands.hooks.DisposePreloader;
	import ayyo.player.core.model.PlayerConstants;
	import ayyo.player.events.PlayerEvent;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.framework.api.ILogger;
	import robotlegs.bender.framework.impl.applyHooks;
	
	import flash.external.ExternalInterface;

	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public class ShowHidePreloader implements ICommand {
		[Inject]
		public var event : PlayerEvent;
		[Inject]
		public var model : IApplicationModel;
		[Inject]
		public var logger : ILogger;

		public function execute() : void {
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "ShowHidePreloader execute()");
			}
			var hook : Array = this.model.getVariable(PlayerConstants.PRELOADER) != null ? [DisposePreloader] : [CreatePreloader];
			applyHooks(hook);
			this.dispose();
		}

		private function dispose() : void {
			this.event = null;
			this.model = null;
			this.logger = null;
		}
	}
}
