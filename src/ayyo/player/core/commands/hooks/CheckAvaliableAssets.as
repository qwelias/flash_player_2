package ayyo.player.core.commands.hooks {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.commands.NullCommand;
	import ayyo.player.core.model.DataType;
	import ayyo.player.events.AssetEvent;
	import ayyo.player.events.BinDataEvent;
	import ayyo.player.plugins.event.PluginEvent;

	import robotlegs.bender.extensions.eventCommandMap.api.IEventCommandMap;
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
		[Inject]
		public var commandMap : IEventCommandMap;
		
		public function hook() : void {
			var event : Event = this.playerConfig.assets.length > 0 ? new BinDataEvent(BinDataEvent.LOAD, DataType.ASSETS) : new PluginEvent(PluginEvent.LOAD);
			this.dispacther.dispatchEvent(event);
			event is PluginEvent && this.commandMap.unmap(AssetEvent.REGISTRED).fromCommand(NullCommand);
			event = null;
			this.dispose();
		}

		private function dispose() : void {
			this.dispacther = null;
			this.playerConfig = null;
			this.commandMap = null;
		}
	}
}
