package ayyo.player.core.commands {
	import robotlegs.bender.extensions.contextView.ContextView;
	import flash.display.LoaderInfo;
	import ayyo.player.modules.base.api.IAyyoPlayerModule;
	import flash.events.Event;
	import flash.display.Loader;
	import ayyo.player.modules.info.api.IModuleInfoMap;
	import ayyo.player.events.BinDataEvent;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class RegisterModule implements ICommand {
		[Inject]
		public var event : BinDataEvent;
		[Inject]
		public var moduleInfoMap : IModuleInfoMap;
		[Inject]
		public var contextView : ContextView;
		/**
		 * @private
		 */
		private var info : ModuleInfo;

		public function execute() : void {
			this.event.data.position = 0;
			this.info = new ModuleInfo(this.event.data.readObject());
			var bytes : ByteArray = new ByteArray();
			this.event.data.readBytes(bytes, 0, this.event.data.bytesAvailable);
			this.event.data.clear();
			var loader : Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onModuleInited);
			loader.loadBytes(bytes);
		}
		
		private function dispose() : void {
			this.info = null;
			this.moduleInfoMap = null;
			this.contextView = null;
			this.event = null;
		}
		
		//	Handlers
		private function onModuleInited(event : Event) : void {
			var loader : Loader = (event.target as LoaderInfo).loader;
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onModuleInited);
			var module : IAyyoPlayerModule = loader.content as IAyyoPlayerModule;
			loader.unload();
			module && this.moduleInfoMap.map(this.info).toModule(module);
			module && this.contextView.view.addChildAt(module.view, 0);
			
			this.dispose();
		}
	}
}
