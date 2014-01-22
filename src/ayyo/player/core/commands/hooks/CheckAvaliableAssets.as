package ayyo.player.core.commands.hooks {
	import ayyo.player.core.model.DataType;
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.events.ApplicationEvent;
	import ayyo.player.events.BinDataEvent;

	import robotlegs.bender.framework.api.IHook;

	import flash.events.Event;
	import flash.events.IEventDispatcher;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class CheckAvaliableAssets implements IHook {
		[Inject]
		public var dispacther : IEventDispatcher;
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		
		public function hook() : void {
			var event : Event = this.playerConfig.assets.length > 0 ? new BinDataEvent(BinDataEvent.LOAD, DataType.ASSETS) : new ApplicationEvent(ApplicationEvent.READY);
			this.dispacther.dispatchEvent(event);
			this.dispose();
		}

		private function dispose() : void {
			this.dispacther = null;
			this.playerConfig = null;
		}
	}
}
