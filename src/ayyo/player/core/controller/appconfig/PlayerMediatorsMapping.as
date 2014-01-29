package ayyo.player.core.controller.appconfig {
	import ayyo.player.core.controller.AudioTrackInfoMediator;
	import ayyo.player.core.controller.ControllbarMediator;
	import ayyo.player.core.controller.ResizeObjectMediator;
	import ayyo.player.core.controller.SubtitlesMediator;
	import ayyo.player.core.controller.VolumeBarMediator;
	import ayyo.player.plugins.subtitles.impl.view.ISubtextField;
	import ayyo.player.view.api.IPlayerControllBar;
	import ayyo.player.view.api.IVolumeBar;
	import ayyo.player.view.impl.controllbar.AudioTrackInfo;

	import me.scriptor.additional.api.IResizable;

	import robotlegs.bender.extensions.matching.ITypeMatcher;
	import robotlegs.bender.extensions.matching.TypeMatcher;
	import robotlegs.bender.extensions.mediatorMap.api.IMediatorMap;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerMediatorsMapping {
		[Inject]
		public var mediatorMap : IMediatorMap;
		/**
		 * @private
		 */
		private var resizable : ITypeMatcher;
		/**
		 * @private
		 */
		private var subtextField : ITypeMatcher;
		/**
		 * @private
		 */
		private var controllBar : ITypeMatcher;
		/**
		 * @private
		 */
		private var volumeBar : ITypeMatcher;

		[PostConstruct]
		public function initialize() : void {
			this.initMatchers();

			this.mediatorMap.mapMatcher(this.resizable).toMediator(ResizeObjectMediator);
			this.mediatorMap.mapMatcher(this.subtextField).toMediator(SubtitlesMediator);
			this.mediatorMap.mapMatcher(this.controllBar).toMediator(ControllbarMediator);
			this.mediatorMap.mapMatcher(this.volumeBar).toMediator(VolumeBarMediator);
			this.mediatorMap.map(AudioTrackInfo).toMediator(AudioTrackInfoMediator);
		}

		private function initMatchers() : void {
			this.resizable = new TypeMatcher().anyOf(IResizable);
			this.subtextField = new TypeMatcher().anyOf(ISubtextField);
			this.controllBar = new TypeMatcher().anyOf(IPlayerControllBar);
			this.volumeBar = new TypeMatcher().anyOf(IVolumeBar);
		}

		[PreDestroy]
		public function destroy() : void {
			this.mediatorMap.unmapMatcher(this.resizable).fromMediator(ResizeObjectMediator);
			this.mediatorMap.unmapMatcher(this.subtextField).fromMediator(SubtitlesMediator);
			this.mediatorMap.unmapMatcher(this.controllBar).fromMediator(ControllbarMediator);
			this.mediatorMap.unmapMatcher(this.volumeBar).fromMediator(VolumeBarMediator);
			this.mediatorMap.unmap(AudioTrackInfo).fromMediator(AudioTrackInfoMediator);

			this.disposeMatchers();
			this.mediatorMap = null;
		}

		private function disposeMatchers() : void {
			this.resizable = null;
			this.subtextField = null;
			this.controllBar = null;
			this.volumeBar = null;
		}
	}
}
