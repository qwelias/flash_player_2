package ayyo.player.modules.splash.commands {
	import ayyo.player.config.api.IAyyoPlayerConfig;
	import ayyo.player.modules.splash.view.api.ISplashImageHolder;
	import ayyo.player.modules.splash.view.impl.ImageHolder;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;
	import robotlegs.bender.framework.api.ILogger;

	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class LoadScreenshot implements ICommand {
		[Inject]
		public var playerConfig : IAyyoPlayerConfig;
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var logger : ILogger;
		/**
		 * @private
		 */
		private var imageLoader : Loader;

		public function execute() : void {
			this.playerConfig.settings.screenshot && this.loadImage();
		}

		private function loadImage() : void {
			this.createLoader();
			this.imageLoader.load(new URLRequest(this.playerConfig.settings.screenshot));
		}
		
		private function dispose() : void {
			this.disposeLoader();
			this.contextView = null;
			this.playerConfig = null;
			this.logger = null;
		}

		private function createLoader() : void {
			if (!this.imageLoader) {
				this.imageLoader = new Loader();
				this.imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.onImageLoaded);
				this.imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, this.onErrorOccured);
			}
		}

		private function disposeLoader() : void {
			if (this.imageLoader) {
				this.imageLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, this.onImageLoaded);
				this.imageLoader.unload();
				this.imageLoader = null;
			}
		}

		// Handlers
		private function onImageLoaded(event : Event) : void {
			var image : Bitmap = this.imageLoader.content as Bitmap;
			var imageHolder : ISplashImageHolder = new ImageHolder(image);
			//this.contextView.view.addChild(imageHolder.view);
			this.logger.debug("Screenshot loaded from {0}", [this.playerConfig.settings.screenshot]);
			this.dispose();
		}
		
		private function onErrorOccured(event : IOErrorEvent) : void {
			this.logger.error(event.text);
		}
	}
}
