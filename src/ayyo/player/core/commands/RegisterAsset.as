package ayyo.player.core.commands {
	import ayyo.player.asstes.info.impl.AssetInfo;
	import ayyo.player.core.model.AssetType;
	import ayyo.player.events.AssetEvent;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import ru.etcs.utils.FontLoader;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class RegisterAsset implements ICommand {
		[Inject]
		public var event : BinDataEvent;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			this.event.data.position = 0;
			var info : AssetInfo = new AssetInfo(this.event.data.readObject());
			var bytes : ByteArray = new ByteArray();
			this.event.data.readBytes(bytes, 0, this.event.data.bytesAvailable);
			this.event.data.clear();
			switch(info.type) {
				case AssetType.FONT:
					var fontLoader : FontLoader = new FontLoader();
					fontLoader.addEventListener(Event.COMPLETE, this.assetRegistredHandler);
					fontLoader.loadBytes(bytes);
					break;
				default:
			}
		}

		private function dispose() : void {
			this.dispatcher = null;
			this.event = null;
		}

		// Handlers
		/**
		 * @private
		 */
		private function assetRegistredHandler(event : Event) : void {
			var registrator : Object = event.target;
			registrator = null;
			this.dispatcher.dispatchEvent(new AssetEvent(AssetEvent.REGISTRED));
			this.dispose();
		}
	}
}
