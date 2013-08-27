package ayyo.player.core.model.api {
	import ayyo.player.core.model.api.IHaveURL;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IInfoObject extends IHaveURL {
		function get name() : String;
	}
}
