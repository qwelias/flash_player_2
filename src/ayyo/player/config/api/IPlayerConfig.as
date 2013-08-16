package ayyo.player.config.api {
	import org.osflash.signals.ISignal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IPlayerConfig  extends ICanInitialize {
		function get settings() : IPlayerSettings;

		function get assets() : Vector.<IPlayerAsset>;

		function get tooltip() : IPlayerTooltip;

		function get replaceWord() : IReplaceWordList;

		function get ready() : ISignal;
	}
}
