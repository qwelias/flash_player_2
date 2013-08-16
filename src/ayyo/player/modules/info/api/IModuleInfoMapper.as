package ayyo.player.modules.info.api {
	import ayyo.player.modules.base.api.IAyyoPlayerModule;
	import ayyo.player.modules.info.impl.ModuleInfo;

	import me.scriptor.additional.api.IDisposable;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IModuleInfoMapper extends IDisposable {
		function toModule(module : IAyyoPlayerModule) : void;

		function fromModule(module : IAyyoPlayerModule) : void;

		function get info() : ModuleInfo;
	}
}
