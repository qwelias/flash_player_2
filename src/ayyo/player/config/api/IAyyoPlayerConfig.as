package ayyo.player.config.api {
	import ayyo.player.core.model.api.IInfoObject;

	import org.osflash.signals.ISignal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoPlayerConfig  extends ICanInitialize {
		function get settings() : IAyyoPlayerSettings;

		function get video() : IAyyoVideoSettings;

		function get assets() : Vector.<IInfoObject>;

		function get modules() : Vector.<IInfoObject>;

		function get tooltip() : IAyyoPlayerTooltip;

		function get replaceWord() : IReplaceWordList;

		function get ready() : ISignal;
	}
}
