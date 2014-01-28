package ayyo.player.core.commands.hooks {
	import robotlegs.bender.framework.api.IHook;

	import org.osmf.media.MediaPlayerSprite;
	import org.osmf.metadata.Metadata;
	import org.osmf.traits.LoadTrait;
	import org.osmf.traits.MediaTraitType;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadVideo implements IHook {
		[Inject]
		public var player : MediaPlayerSprite;

		public function hook() : void {
			if (this.player.media.getMetadata("isLoadStarted")) this.dispose();
			else {
				var meta : Metadata = new Metadata();
				var trait : LoadTrait = this.player.media.getTrait(MediaTraitType.LOAD) as LoadTrait;
				meta.addValue("videoLoadingStarted", true);
				this.player.media.addMetadata("isLoadStarted", meta);
				trait && trace(trait.loadState);
			}
		}

		private function dispose() : void {
			this.player = null;
		}
	}
}
