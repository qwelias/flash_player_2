package player.screenshot {
	import flash.display.Sprite;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.external.ExternalInterface;
	
	public class ScreenShot extends Sprite{
		
		private var _width:Number;
		private var _height:Number;
		private var _loader:Loader;
		private var _loaderContext:LoaderContext;
		private var _image:Bitmap;

		public function ScreenShot()
		{
			_initInterface();
		}
		
		override public function set width(w:Number):void
		{
			_width = w;
		}
		
		override public function set height(h:Number):void
		{
			_height = h;
		}
		
		public function resizeAll():void
		{
			var _mediaWidth:Number = _image.width;
			var _mediaHeight:Number = _image.height;
			
			if(_width/_height > (_mediaWidth/_mediaHeight + 0.02))
			{	
				_image.height = _height + 14;
				_image.width = _mediaWidth * ((_height + 14)/_mediaHeight);
				_image.x = (_width - _mediaWidth * ((_height + 14)/_mediaHeight)) / 2;
				_image.y = -7;
				ExternalInterface.call("console.log", "resize shot: 1111"+_width+":"+_height+":::"+_image.width+":"+_image.height);
			}
			else if(_height/_width > (_mediaHeight/_mediaWidth + 0.02))
			{
				_image.width = _width;
				_image.height = _mediaHeight * (_width/_mediaWidth);
				_image.x = 0;
				_image.y = (_height - _mediaHeight * (_width/_mediaWidth)) / 2;
				ExternalInterface.call("console.log", "resize shot: _width/_height"+_width+":"+_height+":::"+_image.width+":"+_image.height);
			}
			else if(_width/_height <= (_mediaWidth/_mediaHeight + 0.02))
			{
				_image.width = _width;
				_image.height = _mediaHeight * (_width/_mediaWidth);
				_image.x = 0;
				_image.y = (_height - _mediaHeight * (_width/_mediaWidth)) / 2;
			}
			else if(_height/_width <= (_mediaHeight/_mediaWidth + 0.02))
			{
				_image.height = _height + 14;
				_image.width = _mediaWidth * ((_height + 14)/_mediaHeight);
				_image.x = (_width - _mediaWidth * ((_height + 14)/_mediaHeight)) / 2;
				_image.y = -7;
			}
			ExternalInterface.call("console.log", "resize shot: "+_width+":"+_height+":::"+_image.width+":"+_image.height);
		}
		
		public function loadScreenShot(url:String):void
		{
			_loadScreenShot(url);
		}
		
		private function _initInterface():void
		{
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _onLoaderCompleteHandler);
			_loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(evt:SecurityErrorEvent):void{});
			addChild(_loader);
			
			_loaderContext = new LoaderContext();
			_loaderContext.checkPolicyFile = true;
			
			_image = new Bitmap();
			addChild(_image);
		}
		
		private function _loadScreenShot(url:String):void
		{
			try{
                _loader.load(new URLRequest(url), _loaderContext);
            }catch(error:Error){}
		}
		
		private function _onLoaderCompleteHandler(evt:Event):void
		{
			_loader.cacheAsBitmap = true;
			_image = Bitmap(_loader.content);
			_image.smoothing = true;
			
			var _mediaWidth:Number = _image.width;
			var _mediaHeight:Number = _image.height;
			
			if(_width/_height > (_mediaWidth/_mediaHeight + 0.02))
			{	
				_image.height = _height + 14;
				_image.width = _mediaWidth * ((_height + 14)/_mediaHeight);
				_image.x = (_width - _mediaWidth * ((_height + 14)/_mediaHeight)) / 2;
				_image.y = -7;
			}
			else if(_height/_width > (_mediaHeight/_mediaWidth + 0.02))
			{
				_image.width = _width;
				_image.height = _mediaHeight * (_width/_mediaWidth);
				_image.x = 0;
				_image.y = (_height - _mediaHeight * (_width/_mediaWidth)) / 2;
			}
			
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _onLoaderCompleteHandler);
		}
	}
}
