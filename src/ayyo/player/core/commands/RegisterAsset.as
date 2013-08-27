package ayyo.player.core.commands {
	import ayyo.player.asstes.info.impl.AssetInfo;
	import ayyo.player.core.model.AssetType;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	import ru.etcs.utils.FontLoader;

	import flash.utils.ByteArray;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class RegisterAsset implements ICommand {
		[Inject]
		public var event : BinDataEvent;

		public function execute() : void {
			this.event.data.position = 0;
			var info : AssetInfo = new AssetInfo(this.event.data.readObject());
			var bytes : ByteArray = new ByteArray();
			this.event.data.readBytes(bytes, 0, this.event.data.bytesAvailable);
			this.event.data.clear();
			switch(info.type) {
				case AssetType.FONT:
					var fontLoader : FontLoader = new FontLoader();
					fontLoader.loadBytes(bytes);
					break;
				default:
			}
		}
	}
}
