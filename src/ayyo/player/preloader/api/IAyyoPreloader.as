package ayyo.player.preloader.api {
	import org.osflash.signals.ISignal;
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;
	import me.scriptor.additional.api.IResizable;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IAyyoPreloader extends IDisposable, IResizable, IHaveView {
		function show(immediately : Boolean = false) : void;

		function hide(immediately : Boolean = false) : void;

		function get animationComplete() : ISignal;


		function set progress(value : Number) : void;

		function get progress() : Number;
	}
}
