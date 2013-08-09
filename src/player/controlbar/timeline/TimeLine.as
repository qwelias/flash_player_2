package player.controlbar.timeline
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import player.State;
	import player.events.PlayButtonEvent;
	import player.events.SeekTimeEvent;
	
	public class TimeLine extends Sprite
	{
		//private var _interfaceObject:Object = [];
		public static const TIMELINE_DURATION_OVER :String = "timeline.duration.over";
		public static const TIMELINE_DURATION_OUT  :String = "timeline.duration.out";
		public static const TIMELINE_SEEK_BEGIN    :String = "timeline.seek.begin";
		public static const TIMELINE_SEEK_FINISH   :String = "timeline.seek.finish";
		private var _timeCodeDuration:TextField = null;
		private var _timeCodeDurationFormat:TextFormat = null;
		private var _timeCodeCurrent:TextField = null;
		private var _timeCodeCurrentFormat:TextFormat = null;
		private var _lineBackg:Sprite = null;
		private var _lineBuffer:Sprite = null;
		private var _bufferMask:Sprite = null;
		private var _lineProgress:Sprite = null;
		private var _progressMask:Sprite = null;
		/*private var  = null;
		private var  = null;*/
		private var _delimiter:Delimiter = null;
		private var _backgLeft:TimeLineBckgLeft = null
		private var _backgRight:TimeLineBckgRight = null
		private var _backgCenter:TimeLineBckgCenter = null;
		private var _bufferLeft:TimeLineBufferLeft = null;
		private var _bufferRight:TimeLineBufferRight = null;
		private var _bufferFront:TimeLineBufferFront = null;
		private var _bufferCenter:TimeLineBufferCenter = null;
		private var _cursor:TimeLineCursor = null;
		private var _progressLeft:TimeLineProgLeft = null;
		private var _progressCenter:TimeLineProgCenter = null;
		private var _progressFront:TimeLineProgFront = null;
		private var _progressRight:TimeLineProgRight = null;
		private var _timeScroller:TimeScroller = null;
		/*private var  = null;
		private var  = null;
		private var  = null;
		private var  = null;*/
		private var _width:Number;
		private var _scPressed:Boolean = false;
		private var _progressPercent:Number = 0;
		private var _currentTime:Number = 0;
		private var _duration:Number = 1;
		private var _bufferLength:Number = 0;
		private var _activeWidth:Number = 0;
		//private var _played:Boolean = false;
		private var _activeBackgOver:Boolean = false;
		private var _reverseDuration:Boolean = false;
		//private var _trailer:String;
		private var _maxBuffer:Number = -1;
		private var _activeTween:Boolean = false;
		private var _playerComplete:Boolean = false;
		
		private var _globalState:State;

		public function TimeLine(globalState:State)
		{
			_globalState = globalState;
			_initInterface();
			_initListeners();
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "TimeLine._initInterface");
			}
			_delimiter = new Delimiter();
			_delimiter.x = 0;
			_delimiter.y = -9;
			//_delimiter.width = 1;
			addChild(_delimiter);
			
			_timeCodeDuration = new TextField();
			_timeCodeDurationFormat = new TextFormat();
			_timeCodeDurationFormat.color = 0x959595;
			_timeCodeDurationFormat.size = 11;
			_timeCodeDurationFormat.font = "Arial";
			_timeCodeDurationFormat.align = TextFormatAlign.CENTER;
			_timeCodeDuration.selectable = false;
			_timeCodeDuration.defaultTextFormat = _timeCodeDurationFormat;
			_timeCodeDuration.text = "00:00:00";
			_timeCodeDuration.width = _timeCodeDuration.textWidth + 30;
			_timeCodeDuration.height = _timeCodeDuration.textHeight + 3;
			addChild(_timeCodeDuration);
			
			_timeCodeCurrent = new TextField();
			_timeCodeCurrentFormat = new TextFormat();
			_timeCodeCurrentFormat.color = 0xFFFFFF;
			_timeCodeCurrentFormat.size = 9;
			_timeCodeCurrentFormat.bold = true;
			_timeCodeCurrentFormat.font = "Arial";
			_timeCodeCurrentFormat.align = TextFormatAlign.CENTER;
			_timeCodeCurrent.selectable = false;
			_timeCodeCurrent.defaultTextFormat = _timeCodeCurrentFormat;
			_timeCodeCurrent.text = "00:00:00";
			_timeCodeCurrent.width = _timeCodeCurrent.textWidth + 4;
			_timeCodeCurrent.x = 10;

			_lineBackg = new Sprite();
			_backgLeft = new TimeLineBckgLeft();
			_backgRight = new TimeLineBckgRight();
			_backgCenter = new TimeLineBckgCenter();
			_lineBackg.addChild(_backgLeft);
			_lineBackg.addChild(_backgCenter);
			_lineBackg.addChild(_backgRight);
			
			_lineBuffer = new Sprite();
			_bufferLeft = new TimeLineBufferLeft();
			_bufferRight = new TimeLineBufferRight();
			_bufferFront = new TimeLineBufferFront();
			_bufferCenter = new TimeLineBufferCenter();
			_lineBuffer.addChild(_bufferLeft);
			_lineBuffer.addChild(_bufferCenter);
			_lineBuffer.addChild(_bufferFront);
			_lineBuffer.addChild(_bufferRight);
			_lineBuffer.mouseEnabled = false;
			_lineBuffer.mouseChildren = false;
			
			_bufferMask = new Sprite();
			
			_cursor = new TimeLineCursor();
			_cursor.mouseChildren = false;
			_cursor.mouseEnabled = false;
			
			_lineProgress = new Sprite();
			_progressLeft = new TimeLineProgLeft();
			_progressRight = new TimeLineProgRight();
			_progressFront = new TimeLineProgFront();
			_progressCenter = new TimeLineProgCenter();
			_lineProgress.addChild(_progressLeft);
			_lineProgress.addChild(_progressCenter);
			//_lineProgress.addChild(_progressFront);
			_lineProgress.addChild(_progressRight);
			_lineProgress.mouseEnabled = false;
			_lineProgress.mouseChildren = false;
			
			_progressMask = new Sprite();
			
			_timeScroller = new TimeScroller();
			_timeScroller.x = 19;
			_timeScroller.y = 8.5;
			
			_timeCodeCurrent.height = _timeCodeCurrent.textHeight + 2;
			_timeCodeCurrent.y = _lineBackg.y - 11;
			
			addChild(_lineBackg);
			addChild(_lineBuffer);
			addChild(_bufferMask);
			addChild(_lineProgress);
			addChild(_progressMask);
			addChild(_timeScroller);
			addChild(_timeCodeCurrent);
		}
		
		private function _initListeners():void
		{
			_lineBackg.addEventListener(MouseEvent.MOUSE_UP, _onScrollerClickHandler);
			_lineBackg.addEventListener(MouseEvent.MOUSE_DOWN, _onBackgDownHandler);
			_lineBackg.addEventListener(MouseEvent.MOUSE_MOVE, _onScrollerMoveHandler);
			_lineBackg.addEventListener(MouseEvent.MOUSE_OUT, _onScrollerOutHandler);
			_lineBackg.addEventListener(MouseEvent.MOUSE_OVER, _onScrollerOverHandler);
			
			_timeScroller.addEventListener(MouseEvent.MOUSE_UP, _onScrollerClickHandler);
			_timeScroller.addEventListener(MouseEvent.MOUSE_DOWN, _onScrollerDownHandler);
			_timeScroller.addEventListener(MouseEvent.MOUSE_MOVE, _onScrollerMoveHandler);
			_timeScroller.addEventListener(MouseEvent.MOUSE_OUT, _onScrollerOutHandler);
			
			_timeCodeDuration.addEventListener(MouseEvent.MOUSE_OVER, _onDurationMouseOverHandler);
			_timeCodeDuration.addEventListener(MouseEvent.MOUSE_OUT, _onDurationMouseOutHandler);
			_timeCodeDuration.addEventListener(MouseEvent.MOUSE_DOWN, _onDurationMouseDownHandler);
			_timeCodeDuration.addEventListener(MouseEvent.MOUSE_UP, _onDurationMouseUpHandler);
			
		}
		
		public function set activeTween(val:Boolean):void
		{
			_activeTween = val;
		}
		
		/*public function set trailer(val:String):void
		{
			_trailer = val;
			if(_trailer == "true" && _timeCodeDuration.parent){
				removeChild(_timeCodeDuration);
			}
		}*/
		
		public function resetMaxBuffer():void
		{
			_maxBuffer = -1;
		}
		
		public function get reverseDuration():Boolean
		{
			return _reverseDuration;
		}
		
		/*public function set played(val:Boolean):void
		{
			_played = val;
		}*/
		
		public function get durationX():Number
		{
			return _timeCodeDuration.x;
		}
		
		public function get durationWidth():Number
		{
			return _timeCodeDuration.width;
		}
		
		public function playerComplete():void
		{
			_playerComplete = true;
			_timeScroller.x = 0*_activeWidth + 19;
			resetMaxBuffer();
			currentTime = 0;
			bufferLength = 0;
			_setTimeCode(_timeScroller.x, 0);
		}
		
		public function resetPlayerComplete():void
		{
			_playerComplete = false;
		}
		
		override public function set width(w:Number):void
		{
			_width = w;
			var bLx:Number = _delimiter.x + 10;
			var bCx:Number = bLx + _backgLeft.width;
			var bCw:Number;
			var tDx:Number = _width - _timeCodeDuration.width;
			//if(_trailer == "false")
				bCw = tDx - _backgLeft.width - _backgRight.width;
			//else
			//	bCw = tDx - _backgLeft.width - _backgRight.width + _timeCodeDuration.width;
			var bRx:Number = bCx + bCw;
			var pRx:Number = bRx - 16;
			_activeWidth = Math.floor(pRx + _progressRight.width - 10 - 19);
			
			_timeScroller.x = (_currentTime/_duration)*_activeWidth + 19;
			currentTime = _currentTime;
			
			_redrawProgressMask();
			_redrawBufferMask();
			
			/*if(_timeCodeCurrent.parent && _trailer == "true")
			{
				removeChild(_timeCodeCurrent);
			}*/
			
			_timeCodeDuration.x = _width - _timeCodeDuration.width;
			_timeCodeDuration.y = -1;
			
			_backgLeft.x = _delimiter.x + 10;
			_backgLeft.y = 1;
			_backgCenter.x = _backgLeft.x + _backgLeft.width;
			_backgCenter.y = 0;
			//if(_trailer == "false")
				_backgCenter.width = _timeCodeDuration.x - _backgLeft.width - _backgRight.width;
			//else
			//	_backgCenter.width = _timeCodeDuration.x - _backgLeft.width - _backgRight.width + _timeCodeDuration.width;
			_backgRight.x = _backgCenter.x + _backgCenter.width;
			_backgRight.y = 1;
					
			_bufferLeft.x = _backgLeft.x + 1;
			_bufferLeft.y = _backgLeft.y;
			_bufferRight.x = _backgRight.x + 1;
			_bufferRight.y = _backgRight.y;
			_bufferCenter.x = _bufferLeft.x + _bufferLeft.width;
			_bufferCenter.y = _backgCenter.y + 1;
			_bufferCenter.width = _bufferRight.x - _bufferLeft.x - _bufferLeft.width;
			_bufferFront.y = _bufferCenter.y;
	
			_cursor.y = _bufferFront.y + 1;
			
			_progressLeft.x = _backgLeft.x - 2;
			_progressLeft.y = _backgLeft.y - 4;
			_progressRight.x = _backgRight.x - 16;
			_progressRight.y = _backgRight.y - 4;
			_progressCenter.x = _progressLeft.x + _progressLeft.width;
			_progressCenter.y = _backgCenter.y - 3;
			_progressCenter.width = _progressRight.x - _progressLeft.x - _progressLeft.width;
			_progressFront.x = 0;
			_progressFront.y = 0;
			
			_lineProgress.mask = _progressMask;
			_lineBuffer.mask = _bufferMask;
			//_activeWidth = Math.floor(_progressRight.x + _progressRight.width - 10 - 19);
			//trace("second active width:", _activeWidth);
			_redrawProgressMask();
			_redrawBufferMask();
			if(!_activeBackgOver){
				_setTimeCode(_timeScroller.x, _currentTime);
			}
			//trace(_progressPercent, _timeScroller.x);
		}
		
		public function set resizeAll(w:Number):void
		{
			width = w;
			_timeScroller.x = _progressPercent * _activeWidth + 19;
		}
		
		public function set currentTime(val:Number):void
		{
			if(!_timeCodeCurrent.parent)
			{
				addChild(_timeCodeCurrent);
			}
			
			if(!_playerComplete)
			{
				_currentTime = val;
				_timeScroller.x = (_currentTime/_duration)*_activeWidth + 19;
			}
			
			_refreshProgressPercent();
			//_timeCodeCurrent.text = _calculateTime(_currentTime);
			if(!_activeBackgOver)
			{
				_setTimeCode(_timeScroller.x, _currentTime);
			}
			if(_duration > 1)
			{
				if(_reverseDuration)
				{
					_timeCodeDuration.text = "–" + _calculateTime(_duration - _currentTime);
				}
				else
				{
					_timeCodeDuration.text = _calculateTime(_duration);
				}
			}
			_redrawProgressMask();
		}
		
		public function set duration(val:Number):void
		{
			_duration = val;
		}
		
		public function set bufferLength(val:Number):void
		{
			_bufferLength = val;
			_redrawBufferMask();
		}
		
		private function _redrawBufferMask():void
		{
			if(_activeTween)
			{
				_bufferFront.x = 7 + ((Math.round(_currentTime + _bufferLength))/_duration)*_lineBackg.width;
				_maxBuffer = _bufferFront.x;
				
			}
			else
			{
				if(_bufferFront.x <= _lineBackg.width + 8)
				{
					_bufferFront.visible = true;
					if(_maxBuffer > 7 + ((Math.round(_currentTime + _bufferLength))/_duration)*_lineBackg.width)
					{
						_bufferFront.x = _maxBuffer;
					}
					else
					{
						_bufferFront.x = 7 + ((Math.round(_currentTime + _bufferLength))/_duration)*_lineBackg.width;
						_maxBuffer = _bufferFront.x;
					}
				}
				else
				{
					_bufferFront.visible = false;
					_bufferFront.x = _lineBackg.width + 10;
					_maxBuffer = _bufferFront.x;
				}
			}
			_bufferMask.graphics.clear();
			_bufferMask.graphics.beginFill(0x321456);
			_bufferMask.graphics.drawRect(_bufferLeft.x, _bufferLeft.y, _bufferFront.x - _bufferMask.x - 10, _bufferCenter.height);
			_bufferMask.graphics.endFill();
		}
		
		private function _redrawProgressMask():void
		{
			/*if(_timeScroller.x >= 10 + _timeCodeCurrent.width/2 && _timeScroller.x <= Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width/2){
				_timeCodeCurrent.x = _timeScroller.x - _timeCodeCurrent.width/2;
			}else{
				if(_timeScroller.x >= Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width/2){
					_timeCodeCurrent.x = Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width;
				}else{
					_timeCodeCurrent.x = _timeCodeCurrent.x;
				}
			}*/
			_progressMask.graphics.clear();
			_progressMask.graphics.beginFill(0x321456);
			_progressMask.graphics.drawRect(_progressLeft.x, _progressLeft.y, _timeScroller.x - _progressMask.x - (_timeScroller.width/2) + 3, _progressCenter.height);
			_progressMask.graphics.endFill();
			//_progressPercent = (_timeScroller.x - _lineBackg.x)/_activeWidth;
		}
		
		private function _calculateTime(time:Number):String
		{
			var h:Number = Math.floor(time/3600);
			var m:Number = Math.floor((time%3600)/60);
			var s:Number = Math.floor((time%3600)%60);
			
			return (h == 0 ? "00"+":":(h<10 ? "0"+h.toString()+":" : h.toString()+":"))
			+(m<10 ? "0"+m.toString() : m.toString())+":"
				+(s<10 ? "0"+s.toString() : s.toString());
		}
		
		private function _setTimeCode(coordX:Number, time:Number):void
		{
			if(time >= 0 && time <= _duration)
			{
				_timeCodeCurrent.text = _calculateTime(time);
			}
			if(coordX >= 10 + _timeCodeCurrent.width/2 && coordX <= Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width/2)
			{
				_timeCodeCurrent.x = coordX - _timeCodeCurrent.width/2;
			}
			else
			{
				if(coordX >= Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width/2)
				{
					_timeCodeCurrent.x = Math.floor(_backgRight.x + _backgRight.width) - _timeCodeCurrent.width;
				}
				else
				{
					_timeCodeCurrent.x = 10;
				}
			}
		}
		
		private function _onDurationMouseOverHandler(evt:MouseEvent):void
		{
			dispatchEvent(new Event(TIMELINE_DURATION_OVER, true));
			_timeCodeDuration.textColor = 0xa7d8ff;
		}
		
		private function _onDurationMouseOutHandler(evt:MouseEvent):void
		{
			dispatchEvent(new Event(TIMELINE_DURATION_OUT, true));
			_timeCodeDuration.textColor = 0x959595;
		}
		
		private function _onDurationMouseDownHandler(evt:MouseEvent):void
		{
			_timeCodeDuration.textColor = 0x34a4ff;
		}
		
		private function _onDurationMouseUpHandler(evt:MouseEvent):void
		{
			_reverseDuration = !_reverseDuration;
			if(_duration > 1)
			{
				if(_reverseDuration)
				{
					_timeCodeDuration.text = "–" + _calculateTime(_duration - _currentTime);
				}
				else
				{
					_timeCodeDuration.text = _calculateTime(_duration);
				}
			}
			_timeCodeDuration.textColor = 0xa7d8ff;
		}
		
		private function _onScrollerOverHandler(evt:MouseEvent):void
		{
			addChild(_cursor);
			_activeBackgOver = true;
		}
				
		private function _onBackgDownHandler(evt:MouseEvent):void
		{
			if(_cursor.parent)
			{
				removeChild(_cursor);
			}
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, false, true));
			dispatchEvent(new Event(TIMELINE_SEEK_BEGIN, true));
			_timeScroller.mouseEnabled = false;
			_timeScroller.mouseChildren = false;
			_activeBackgOver = false;
			_onScrollerDownHandler(evt);
			_refreshProgressPercent();
		}
		
		private function _onScrollerOutHandler(evt:MouseEvent):void
		{
			if(_cursor.parent)
			{
				removeChild(_cursor);
			}
			_setTimeCode(_timeScroller.x, _progressPercent*_duration);
			dispatchEvent(new Event(TIMELINE_SEEK_FINISH, true));
			_timeScroller.mouseEnabled = true;
			_timeScroller.mouseChildren = true;
			_activeBackgOver = false;
			_scPressed = false;
			_redrawProgressMask();
			_refreshProgressPercent();
		}
		
		private function _onScrollerClickHandler(evt:MouseEvent):void
		{
			//trace("click");
			_timeScroller.mouseEnabled = true;
			_timeScroller.mouseChildren = true;
			_activeBackgOver = false;
			_scPressed = false;
			_redrawProgressMask();
			_refreshProgressPercent();
			dispatchEvent(new SeekTimeEvent(SeekTimeEvent.SEEK_TIME_CHANGE, _progressPercent*_duration, true));
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, _globalState.played, true));
			dispatchEvent(new Event(TIMELINE_SEEK_FINISH, true));
		}
		
		private function _onScrollerDownHandler(evt:MouseEvent):void
		{
			if(_cursor.parent)
			{
				removeChild(_cursor);
			}
			dispatchEvent(new PlayButtonEvent(PlayButtonEvent.PLAYED_CHANGE, false, true));
			dispatchEvent(new Event(TIMELINE_SEEK_BEGIN, true));
			_activeBackgOver = false;
			_scPressed = true;
			if(mouseX >= 19 && mouseX <= (_progressRight.x + _progressRight.width - 10.5))
			{
				_timeScroller.x = mouseX;
				_refreshProgressPercent();
			}
			_redrawProgressMask();
		}
		
		private function _onScrollerMoveHandler(evt:MouseEvent):void
		{
			if(_scPressed)
			{
				if(mouseX >= 19 && mouseX <= (_progressRight.x + _progressRight.width - 10))
				{
					_refreshProgressPercent();
					_timeScroller.x = mouseX;
					_setTimeCode(_timeScroller.x, _progressPercent*_duration);
					_redrawProgressMask();
					evt.updateAfterEvent();
				}
			}
			else
			{
				_cursor.x = mouseX;
				_setTimeCode(mouseX, ((mouseX - 19)/(_activeWidth - 1))*_duration);
			}
		}
		
		private function _refreshProgressPercent():void
		{
			_progressPercent = (_timeScroller.x - 19)/_activeWidth;
		}
	}
}
