package ayyo.player.view.api {
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;

	import me.scriptor.additional.api.IHaveActionSignal;
	import me.scriptor.additional.api.IResizable;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public interface IPlayerControllBar extends IPlayerView, IResizable, IHaveActionSignal {
		function get playPause() : IButton;

		function get timeline() : IVideoTimeline;

		function get timer() : IVideoTimer;

		function get audioTrack() : AudioTrackInfo;

		function get volume() : IVolumeBar;

		function get screenState() : IButton;

		function show() : void;

		function hide() : void;
	}
}
