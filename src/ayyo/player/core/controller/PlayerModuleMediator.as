package ayyo.player.core.controller {
	import ayyo.player.modules.base.api.IAyyoPlayerModule;
	import ayyo.player.modules.info.api.IModuleInfoMap;

	import robotlegs.bender.extensions.mediatorMap.api.IMediator;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerModuleMediator implements IMediator {
		[Inject]
		public var module : IAyyoPlayerModule;
		[Inject]
		public var moduleInfoMap : IModuleInfoMap;

		public function initialize() : void {
			this.module.ready.addOnce(this.onModuleReady);
			this.module.create();
			this.moduleInfoMap.handler.process(this.module);
		}

		public function destroy() : void {
			this.module && this.module.dispose();
			this.module = null;
			this.moduleInfoMap = null;
		}

		// Handlers
		private function onModuleReady() : void {
		}
	}
}
