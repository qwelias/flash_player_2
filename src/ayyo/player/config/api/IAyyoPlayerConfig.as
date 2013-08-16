package ayyo.player.config.api {
	import ayyo.player.modules.info.impl.ModuleInfo;

	import org.osflash.signals.ISignal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoPlayerConfig  extends ICanInitialize {
		function get settings() : IAyyoPlayerSettings;

		function get assets() : Vector.<IAyyoPlayerAsset>;

		function get modules() : Vector.<ModuleInfo>;

		function get tooltip() : IAyyoPlayerTooltip;

		function get replaceWord() : IReplaceWordList;

		function get ready() : ISignal;
	}
}
