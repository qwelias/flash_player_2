package player.controlbar.tooltips {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.events.Event;
	import fl.transitions.Tween;
	import fl.transitions.easing.Regular;
	import flash.display.BlendMode;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import fl.transitions.TweenEvent;
	
	public class ToolTips extends Sprite{
		
		private var _interfaceObject:Object = [];
		private var _text:String = "";
		private var _arrowX:Number = 0;
		private var _globalX:Number = 0;
		private var _timer:Timer = new Timer(500);
		private var _endTimer:Timer = new Timer(5000);
		private var _beginTween:Tween;
		private var _endTween:Tween;

		public function ToolTips() {
			_initInterface();
			this.alpha = 0;
			this.mouseChildren = false;
			this.mouseEnabled = false;
			this.blendMode = BlendMode.LAYER;
			this.addEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, _onThisRemovedFromStageHandler);
		}
		
		public function set text(val:String):void{
			_text = val;
			_initText();
			_initGlobalCoords();
		}
		
		public function set arrowX(val:Number):void{
			_arrowX = val;
			_initArrowCoords();
		}
		
		public function set globalX(val:Number):void{
			_globalX = val;
						
		}
		
		private function _initInterface():void{
			_interfaceObject["hintSprite"] = new Sprite();
			
			_interfaceObject["hintLeft"] = new HintBackgLeft();
			_interfaceObject["hintCenter"] = new HintBackgCenter();
			_interfaceObject["hintRight"] = new HintBackgRight();
			_interfaceObject["hintArrow"] = new HintBackgArrow();
			
			_interfaceObject["hintText"] = new TextField();
			_interfaceObject["hintTextFormat"] = new TextFormat();
			_interfaceObject["hintTextFormat"].color = 0x5e5e5e;
			_interfaceObject["hintTextFormat"].size = 11;
			_interfaceObject["hintTextFormat"].align = TextFormatAlign.CENTER;
			_interfaceObject["hintTextFormat"].font = "Arial";
			
			_interfaceObject["hintText"].defaultTextFormat = _interfaceObject["hintTextFormat"];
			
			_interfaceObject["hintSprite"].addChild(_interfaceObject["hintLeft"]);
			_interfaceObject["hintSprite"].addChild(_interfaceObject["hintCenter"]);
			_interfaceObject["hintSprite"].addChild(_interfaceObject["hintRight"]);
			_interfaceObject["hintSprite"].addChild(_interfaceObject["hintArrow"]);
			_interfaceObject["hintSprite"].addChild(_interfaceObject["hintText"]);
			
			addChild(_interfaceObject["hintSprite"]);
		}
		
		private function _initText():void{
			
			_interfaceObject["hintText"].text = _text;
			_interfaceObject["hintText"].x = _interfaceObject["hintLeft"].width - 2;
			_interfaceObject["hintText"].y = 3;
			_interfaceObject["hintText"].width = _interfaceObject["hintText"].textWidth + 10;
			_interfaceObject["hintText"].height = _interfaceObject["hintText"].textHeight + 5;
		
		}
		
		private function _initGlobalCoords():void{
			
			_interfaceObject["hintLeft"].x = 0;
			_interfaceObject["hintLeft"].y = 0;
			
			_interfaceObject["hintRight"].x = _interfaceObject["hintLeft"].x + _interfaceObject["hintText"].width;
			_interfaceObject["hintRight"].y = 0;
			
			_interfaceObject["hintCenter"].x = _interfaceObject["hintLeft"].x + _interfaceObject["hintLeft"].width;
			_interfaceObject["hintCenter"].y = 0;
			_interfaceObject["hintCenter"].width = _interfaceObject["hintRight"].x - _interfaceObject["hintCenter"].x;
			
		}
		
		private function _initArrowCoords():void{
			_interfaceObject["hintArrow"].x = _interfaceObject["hintLeft"].x + _arrowX - _interfaceObject["hintArrow"].width/2;
			_interfaceObject["hintArrow"].y = 25.9;
		}
		
		private function _onAddedToStageHandler(evt:Event):void{
			//this.removeEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStageHandler);
			_timer.addEventListener(TimerEvent.TIMER, _onTimerEventHandler);
			_timer.reset();
			_timer.start();
		}
		
		private function _onTimerEventHandler(evt:TimerEvent):void{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, _onTimerEventHandler);
			_beginTween = new Tween(this, "alpha", Regular.easeOut, 0, 1, 5);
			_beginTween.addEventListener(TweenEvent.MOTION_FINISH, _onBeginMotionHandler);
		}
		
		private function _onBeginMotionHandler(evt:TweenEvent):void{
			_endTimer.addEventListener(TimerEvent.TIMER, _onEndTimerHandler);
			_endTimer.start();
			_beginTween.removeEventListener(TweenEvent.MOTION_FINISH, _onBeginMotionHandler);
		}
		
		private function _onEndTimerHandler(evt:TimerEvent):void{
			_endTimer.removeEventListener(TimerEvent.TIMER, _onEndTimerHandler);
			_endTimer.stop();
			_endTween = new Tween(this, "alpha", Regular.easeOut, 1, 0, 5);
		}
		
		private function _onThisRemovedFromStageHandler(evt:Event):void{
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, _onTimerEventHandler);
			_interfaceObject["hintArrow"].x = 0;
			this.alpha = 0;
		}

	}
	
}
