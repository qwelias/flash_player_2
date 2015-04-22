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
			token:"begintokensessionid%3Dyb0y6wl9ki2yqlat57ulosv55bpbe9zn%2Ccontentid%3D185%2Ccountrycode%3Dru%2Cclientkey%3D6f17269e454fbbd63a1e3e9727ac89%3ASvbwhROcR1JZE6PJUJ03cAg-Qb4endtoken",
			autoplay: false,
			url:"http://cdn.ayyo.ru/u18/1a/9c/Disney.Planes_Fire_And_Rescue@AT_trailer@lang_rus@R_SD.mp4",
			screenshot:"https%3A%2F%2Fmedia.ayyo.ru%2Fmovies%2F185%2Fvideo_poster%2F850x477.jpg",
			player_type:"trailer",
			//assets:'{"name":"arialFontFamily","url":"./assets/fonts/arial.swf","type":"font"}',
			plugins:'{"url":"file:///Users/zaynutdinov/Documents/Projects/Private/AyyoPlayer/bin/plugins/SubtitlesPlugin.swf", "config":[{"url":"./force.srt","id":"ru","name":"Force russian"}, {"url":"http://cdn.ayyo.ru/u22/ec/96/VForVendetta-Feat-PAL-16x9-2.35_Russian.srt","id":"en","name":"English"}]}',
			buffer_size: 60
		};

		public function execute() : void {
			var source : Object = this.contextView.view.root.loaderInfo.parameters;
			trace("-->", "SOURCE", source);
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
