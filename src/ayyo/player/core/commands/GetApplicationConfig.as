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
//			token:"begintokensessionid%3Dyb0y6wl9ki2yqlat57ulosv55bpbe9zn%2Ccontentid%3D185%2Ccountrycode%3Dru%2Cclientkey%3D6f17269e454fbbd63a1e3e9727ac89%3ASvbwhROcR1JZE6PJUJ03cAg-Qb4endtoken",
			token: "begintokensessionid%3Drepow44unrkvrgqffecisuewy9uwd54j%2Ccontentid%3D1275%2Ccountrycode%3Dru%2Cclientkey%3D6f17269e454fbbd63a1e3e9727ac89:D_Kys7l_HR8S7mJAi6Yiz7SG1IUendtoken",
			autoplay: false,
			url:"http://cdn.ayyo.ru/u16/bf/91/b441e5cc-f1a0-4bf5-857e-1c47c98df669.f4m",
			screenshot:"http://media.ayyo.ru/movies/1275/video_poster/850x477.jpg",
			player_type:"movie",
			//assets:'{"name":"arialFontFamily","url":"./assets/fonts/arial.swf","type":"font"}',
			buffer_size: 60
		};

		public function execute() : void {
			var source : Object = this.contextView.view.root.loaderInfo.parameters;
			trace("-->", "SOURCE", source.toString());
			if (flashvars) {
				this.playerConfig.ready.addOnce(this.onConfigParsed);
				this.playerConfig.initialize(flashvars);
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
