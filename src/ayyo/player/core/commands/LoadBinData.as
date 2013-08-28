package ayyo.player.core.commands {
	import com.greensock.loading.data.LoaderMaxVars;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.DataType;
	import ayyo.player.core.model.api.IInfoObject;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.LoaderMax;

	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadBinData implements ICommand {
		[Inject]
		public var event : BinDataEvent;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		/**
		 * @private
		 */
		private var binLoader : LoaderMax;

		public function execute() : void {
			this.createLoader();
			var info : IInfoObject;
			var vector : Vector.<IInfoObject> = event.dataType == DataType.ASSETS ? this.playerConfig.assets : this.playerConfig.modules;
			while (vector.length) {
				info = this.event.dataType == DataType.ASSETS ? vector.shift() : vector.pop();
				info && this.binLoader.append(new BinaryDataLoader(info.url, {info:info}));
			}
			this.binLoader.numChildren > 0 && this.binLoader.load();
		}

		private function createLoader() : void {
			if (!this.binLoader) {
				this.binLoader = new LoaderMax(new LoaderMaxVars().maxConnections(1));
				this.binLoader.addEventListener(LoaderEvent.CHILD_COMPLETE, this.onChildLoaded);
				this.binLoader.addEventListener(LoaderEvent.COMPLETE, this.onChildrenLoaded);
			}
		}
		
		private function disposeLoader() : void {
			if (this.binLoader) {
				this.binLoader.removeEventListener(LoaderEvent.CHILD_COMPLETE, this.onChildLoaded);
				this.binLoader.removeEventListener(LoaderEvent.COMPLETE, this.onChildrenLoaded);
				this.binLoader.unload();
				this.binLoader = null;
			}
		}
		
		private function dispose() : void {
			this.disposeLoader();
			this.event = null;
			this.playerConfig = null;
			this.dispatcher = null;
		}
		
		//	Handlers
		private function onChildLoaded(event : LoaderEvent) : void {
			var bytes : ByteArray = new ByteArray();
			var loader : BinaryDataLoader = event.target as BinaryDataLoader;
			bytes.writeObject(loader.vars["info"]);
			bytes.writeBytes(loader.content as ByteArray);
			bytes && this.dispatcher.dispatchEvent(new BinDataEvent(BinDataEvent.COMPLETE, this.event.dataType, bytes));
		}

		private function onChildrenLoaded(event : LoaderEvent) : void {
			this.dispatcher.dispatchEvent(new BinDataEvent(BinDataEvent.LOADED, this.event.dataType));
			this.dispose();
		}
	}
}
