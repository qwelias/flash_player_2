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

		function set margin(value : uint) : void;

		function get margin() : uint;

		function set bottomPadding(value : uint) : void;

		function get bottomPadding() : uint;

		function show() : void;

		function hide() : void;
	}
}
