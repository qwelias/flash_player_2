package ayyo.player.modules.info.api {
	import ayyo.player.modules.info.impl.ModuleInfo;
	import ayyo.player.modules.info.impl.ModuleInfoHandler;

	import me.scriptor.additional.api.IDisposable;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IModuleInfoMap extends IDisposable {
		function map(info : ModuleInfo) : IModuleInfoMapper;

		function unmap(info : ModuleInfo) : IModuleInfoMapper;

		function get handler() : ModuleInfoHandler;
	}
}
