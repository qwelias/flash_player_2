package player.controlbar.timetext {
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	
	public class TimeText extends Sprite{

		private var _timeText:ClockIco;
		private var _delimiter:Delimiter;
		//private var _firstLaunch:Boolean = false;
		private var _startLeft:Number;
		private var _finishLeft:Number;
		private var _finishTimer:Timer = new Timer(3600000);
		
		public function TimeText()
		{
			//addEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStageHandler);
			_initInterface();
			_initListeners();
		}
		
		public function set firstLaunch(val:Boolean):void
		{
			//_firstLaunch = val;
			/*if(_firstLaunch)
			{
				var _days:Number = Math.floor(_startLeft/24);
				var time_word:String = "";
				if(_days < 1)
				{
					switch(_startLeft)
					{
						case 0:
							time_word = " часов ";
							break;
						case 1:
							time_word = " час ";
							break;
						case 2:
						case 3:
						case 4:
							time_word = " часа ";
							break;
						case 5:
						case 6:
						case 7:
						case 8:
						case 9:
						case 10:
						case 11:
						case 12:
						case 13:
						case 14:
						case 15:
						case 16:
						case 17:
						case 18:
						case 19:
						case 20:
							time_word = " часов ";
							break;
						case 21:
							time_word = " час ";
							break;
						case 22:
						case 23:
						case 24:
							time_word = " часа ";
							break;
						default:
							time_word = " часа ";
							break;
					}
					_timeText.txt.text = "У вас есть " + _startLeft + time_word + "для начала просмотра";
				}
				else
				{
					switch(_days)
					{
						case 0:
							time_word = " дней "
							break;
						case 1:
							time_word = " день ";
							break;
						case 2:
						case 3:
						case 4:
							time_word = " дня ";
							break;
						case 5:
						case 6:
						case 7:
						case 8:
						case 9:
						case 10:
						case 11:
						case 12:
						case 13:
						case 14:
						case 15:
						case 16:
						case 17:
						case 18:
						case 19:
						case 20:
							time_word = " дней ";
							break;
						default:
							var s:String = _days.toString();
							switch(Number(s.charAt(s.length - 1)))
							{
								case 1:
									time_word = " день ";
									break;
								case 2:
								case 3:
								case 4:
									time_word = " дня ";
									break;
								case 5:
								case 6:
								case 7:
								case 8:
								case 9:
								case 0:
									time_word = " дней "
									break;
							}
							break;
					}
					_timeText.txt.text = "У вас есть " + _days + time_word +"для начала просмотра";
				}
				_timeText.txt.width = _timeText.txt.textWidth+25;
			}
			else
			{*/
				_timeText.txt.text = _finishLeft+" ч.";
				_timeText.txt.width = _timeText.txt.textWidth+25;
			//}
		}
			
		public function set startLeft(val:Number):void
		{
			_startLeft = val;
		}
		
		public function set finishLeft(val:Number):void
		{
			_finishLeft = val;
			_finishTimer.addEventListener(TimerEvent.TIMER, _onFinishTimerHandler);
		}
		
		public function get finishLeft():Number
		{
			return _finishLeft;
		}
		
		private function _initInterface():void
		{
			_timeText = new ClockIco();
			//_timeText.txt.autoSize = true;
			_timeText.txt.selectable = false;
			_timeText.x = 12;
			_timeText.y = 12;
			addChild(_timeText);
			
			_delimiter = new Delimiter();
			_delimiter.x = 0;
			_delimiter.y = 0;
			//addChild(_delimiter);
		}
		
		private function _initListeners():void{
			
		}
		
		private function _onFinishTimerHandler(evt:TimerEvent):void
		{
			if(_finishLeft >= 0)
			{
				_finishLeft--;
			}
		}
		
		private function _onThisAddedToStageHandler(evt:Event):void
		{
			/*if(_firstLaunch)
			{
				var _days:Number = Math.floor(_startLeft/24);
				if(_days < 1)
				{
					_timeText.txt.text = "У вас есть "+_startLeft+" часов для начала просмотра";
				}
				else
				{
					_timeText.txt.text = "У вас есть "+_days+" дней для начала просмотра";
				}
				_timeText.txt.width = _timeText.txt.textWidth+5;
				//_delimiter.x = 632;
			}
			else
			{*/
				_timeText.txt.text = _finishLeft+" ч.";
				_timeText.txt.width = _timeText.txt.textWidth+5;
				//_delimiter.x = 96;
			//}
		}
	}
}
