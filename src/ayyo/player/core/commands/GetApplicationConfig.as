package ayyo.player.core.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.core.model.DataType;
	import ayyo.player.events.AssetEvent;
	import ayyo.player.events.BinDataEvent;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class GetApplicationConfig implements ICommand {
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var dispatcher : IEventDispatcher;
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var logger : ILogger;

		private var flashvars:Object = {
//			token:"begintokensessionid%3Drepow44unrkvrgqffecisuewy9uwd54j%2Ccontentid%3D2404%2Ccountrycode%3Dru%2Cclientkey%3D6f17269e454fbbd63a1e3e9727ac89:0Dm5rQtp8CU9GWBUdNlINbu65-kendtoken",
//			url:"http://cdn.ayyo.ru/u17/2d/a6/706fbaf2-88cc-4901-b71e-18b149dfc89c.f4m",
			player_type: "movie"
		};

		public function execute() : void {
			var source : Object = this.contextView.view.root.loaderInfo.parameters;
			if (flashvars) {
				this.playerConfig.ready.addOnce(this.onConfigParsed);
				this.playerConfig.initialize(source);
			} else {
				this.logger.error("There are no any parameters for player.");
			}
		}

		private function onConfigParsed() : void {
			this.logger.debug("Config successfully parsed");
			var event : Event = this.playerConfig.assets.length > 0 ? new BinDataEvent(BinDataEvent.LOAD, DataType.ASSETS) : new AssetEvent(AssetEvent.REGISTRED);
			this.dispatcher.dispatchEvent(event);
			this.dispose();
		}

		private function dispose() : void {
			this.playerConfig = null;
			this.logger = null;
			this.dispatcher = null;
			this.contextView = null;
		}
	}
}
