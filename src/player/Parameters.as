package player
{
	public class Parameters
	{
		public var                   token:String = null;
		public var             content_url:String = null;
		public var           subtitles_url:String = null;
		public var    forced_subtitles_url:String = null;
		public var          screenshot_url:String = null;
		public var             player_type:String = null;
		public var               auto_play:String = null;
		public var        virtual_duration:String = null;
		public var              start_time:String = null;
		public var              bufferSize:String = null;
		public var                mode_4x3:String = "false";
		public var                    free:String = null;
		public var               first_run:String = "true";
		public var     tooltip_play_button:String = null;
		public var    tooltip_pause_button:String = null;
		public var    tooltip_license_icon:String = null;
		public var           tooltip_timer:String = null;
		public var   tooltip_timer_reverse:String = null;
		//public var tooltip_HQ_icon_on:String = null;
		//public var tooltip_HQ_icon_off:String = null;
		public var   tooltip_sound_icon_on:String = null;
		public var  tooltip_sound_icon_off:String = null;
		public var      tooltip_fullscreen:String = null;
		public var    tooltip_unfullscreen:String = null;
		public var tooltip_rus_lang_button:String = null;
		//public var tooltip_eng_lang_button:String = null;
		//public var tooltip_rus_subs_on_button:String = null;
		//public var tooltip_rus_subs_off_button:String = null;
		public var tooltip_eng_lang_rus_subs_button:String = null;
		
		private var      _hours_until_start:Number = -1;
		private var       _hours_until_stop:Number = -1;
		
		public var _isTrailer:Boolean = false;

		public function Parameters():void
		{
			//
		}
	
		public function set_hours_until_start(val:String):void
		{
			try{
				_hours_until_start = Number(val);
			}catch(err:Error){}
		}
		
		public function set_hours_until_stop(val:String):void
		{
			try
			{
				_hours_until_stop = Number(val);
			}catch(err:Error){}
		}
		
		public function get hours_until_start():Number
		{
			return _hours_until_start;
		}
		
		public function get hours_until_stop():Number
		{
			return _hours_until_stop;
		}
	}
}