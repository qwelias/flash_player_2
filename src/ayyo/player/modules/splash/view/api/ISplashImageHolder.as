package ayyo.player.modules.splash.view.api {
	import me.scriptor.additional.api.IDisposable;
	import me.scriptor.additional.api.IHaveView;

	import flash.display.Bitmap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface ISplashImageHolder extends IHaveView, IDisposable {
		function get image() : Bitmap;
	}
}
