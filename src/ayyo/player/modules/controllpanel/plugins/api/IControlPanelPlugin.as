package ayyo.player.modules.controllpanel.plugins.api {
	import me.scriptor.additional.api.IHaveActionSignal;
	import me.scriptor.additional.api.IHaveView;
	import me.scriptor.additional.api.IDisposable;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IControlPanelPlugin extends IHaveView, IDisposable, IHaveActionSignal {
	}
}
