package ayyo.player.modules.base.api {
	import ayyo.player.modules.info.impl.ModuleInfo;

	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;
	import me.scriptor.additional.api.IResizable;

	import org.osflash.signals.ISignal;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoPlayerModule extends IDisposable, IHaveView, IResizable {
		function get ready() : ISignal;

		function initialize(moduleInfo : ModuleInfo) : void;
	}
}
