package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.DataType;
	import ayyo.player.core.model.api.IInfoObject;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.LoaderMax;

	import flash.events.IEventDispatcher;

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
				info = vector.shift();
				info && this.binLoader.append(new BinaryDataLoader(info.url, {info:info}));
			}
			this.binLoader.numChildren > 0 && this.binLoader.load();
		}

		private function createLoader() : void {
			if (!this.binLoader) {
				this.binLoader = new LoaderMax();
				this.binLoader.addEventListener(LoaderEvent.COMPLETE, this.onChildrenLoaded);
			}
		}

		private function onChildrenLoaded(event : LoaderEvent) : void {
		}
	}
}
