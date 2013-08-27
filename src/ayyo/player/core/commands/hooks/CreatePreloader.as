package ayyo.player.core.commands.hooks {
	import ayyo.player.core.model.PlayerConstants;
	import ayyo.player.preloader.api.IAyyoPreloader;
	import ayyo.player.preloader.impl.AyyoPreloader;

	import me.scriptor.mvc.model.api.IApplicationModel;

	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.IHook;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class CreatePreloader implements IHook {
		[Inject]
		public var model : IApplicationModel;
		[Inject]
		public var contextView : ContextView;
		
		public function hook() : void {
			this.checkForPreloader();
			var preloader : IAyyoPreloader = this.model.getVariable(PlayerConstants.PRELOADER);
			this.contextView.view.addChild(preloader.view);
			preloader.show();
			this.dispose();
		}

		private function dispose() : void {
			this.model = null;
			this.contextView = null;
		}

		private function checkForPreloader() : void {
			!this.model.getVariable(PlayerConstants.PRELOADER) && this.model.setVariable(PlayerConstants.PRELOADER, new AyyoPreloader());
		}
	}
}
