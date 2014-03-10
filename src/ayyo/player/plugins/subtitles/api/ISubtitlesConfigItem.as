package ayyo.player.plugins.subtitles.api {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface ISubtitlesConfigItem {
		function get id() : String;

		function get name() : String;

		function get url() : String;
	}
}
