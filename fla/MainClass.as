package
{
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.system.fscommand;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	
	import player.Parameters;
	import player.State;
	import player.VideoSprite;
	import player.screenshot.ScreenShot;
	
	public class MainClass extends Sprite
	{
		private var _globalWidth:int = 850;
		private var _globalHeight:int = 477;
		
		private var _videoSprite:VideoSprite = null;
		private var _contextMenu:ContextMenu = null;
		private var _screenShot:ScreenShot = null;
		private var _contextMenuItem1:ContextMenuItem = null;
		private var _contextMenuItem2:ContextMenuItem = null;
		private var _globalParameters:Parameters = new Parameters();
		private var _globalState:State = new State();
		
		private var _resizeAllowed:Boolean = true;
		
		public function MainClass()
		{
			//_initInterface();
			this.addEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStageHandler);
		}
		
		private function _onThisAddedToStageHandler(_evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onThisAddedToStageHandler");
			}
			this.removeEventListener(Event.ADDED_TO_STAGE, _onThisAddedToStageHandler);
			_getParams();
			_initListeners();
			_onAddedToStageHandler();
		}
		
		private function _getParams():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._getParams");
			}
			try{ _globalParameters.auto_play                        = stage.loaderInfo.parameters["auto_play"];               }catch(err:Error){}
			try{ _globalParameters.bufferSize                       = stage.loaderInfo.parameters["bufferSize"];              }catch(err:Error){}
			try{ _globalParameters.content_url                      = stage.loaderInfo.parameters["url"];                     }catch(err:Error){}
			try{ _globalParameters.first_run                        = stage.loaderInfo.parameters["first_run"];               }catch(err:Error){}
			try{ _globalParameters.free                             = stage.loaderInfo.parameters["free"];                    }catch(err:Error){}
			_globalParameters.set_hours_until_start(stage.loaderInfo.parameters["hours_until_start"]);
			_globalParameters.set_hours_until_stop (stage.loaderInfo.parameters["hours_until_stop"]);
			try{ _globalParameters.mode_4x3                         = stage.loaderInfo.parameters["4x3"];                     }catch(err:Error){}
			try{ _globalParameters.player_type                      = stage.loaderInfo.parameters["player_type"];             }catch(err:Error){}
			try{ _globalParameters.screenshot_url                   = stage.loaderInfo.parameters["screenshot"];              }catch(err:Error){}
			try{ _globalParameters.start_time                       = stage.loaderInfo.parameters["start_time"];              }catch(err:Error){}
			try{ _globalParameters.subtitles_url                    = stage.loaderInfo.parameters["subtitles"];               }catch(err:Error){}
			try{ _globalParameters.forced_subtitles_url             = stage.loaderInfo.parameters["forced_subtitles"];               }catch(err:Error){}
			try{ _globalParameters.token                            = stage.loaderInfo.parameters["token"];                   }catch(err:Error){}
			try{ _globalParameters.tooltip_eng_lang_rus_subs_button = stage.loaderInfo.parameters["tooltip_eng_lang_rus_subs_button"]; }catch(err:Error){}
			try{ _globalParameters.tooltip_fullscreen               = stage.loaderInfo.parameters["tooltip_fullscreen"];      }catch(err:Error){}
			try{ _globalParameters.tooltip_license_icon             = stage.loaderInfo.parameters["tooltip_license_icon"];    }catch(err:Error){}
			try{ _globalParameters.tooltip_pause_button             = stage.loaderInfo.parameters["tooltip_pause_button"];    }catch(err:Error){}
			try{ _globalParameters.tooltip_play_button              = stage.loaderInfo.parameters["tooltip_play_button"];     }catch(err:Error){}
			try{ _globalParameters.tooltip_rus_lang_button          = stage.loaderInfo.parameters["tooltip_rus_lang_button"]; }catch(err:Error){}
			try{ _globalParameters.tooltip_sound_icon_off           = stage.loaderInfo.parameters["tooltip_sound_icon_off"];  }catch(err:Error){}
			try{ _globalParameters.tooltip_sound_icon_on            = stage.loaderInfo.parameters["tooltip_sound_icon_on"];   }catch(err:Error){}
			try{ _globalParameters.tooltip_timer                    = stage.loaderInfo.parameters["tooltip_timer"];           }catch(err:Error){}
			try{ _globalParameters.tooltip_timer_reverse            = stage.loaderInfo.parameters["tooltip_timer_reverse"];   }catch(err:Error){}
			try{ _globalParameters.tooltip_unfullscreen             = stage.loaderInfo.parameters["tooltip_unfullscreen"];    }catch(err:Error){}
			try{ _globalParameters.virtual_duration                 = stage.loaderInfo.parameters["virtual_duration"];        }catch(err:Error){}
			//try{ _globalParameters.tooltip_eng_lang_button         = stage.loaderInfo.parameters["tooltip_eng_lang_button"]; }catch(err:Error){}
			//try{ _globalParameters.tooltip_HQ_icon_off             = stage.loaderInfo.parameters["tooltip_HQ_icon_off"]; }catch(err:Error){}
			//try{ _globalParameters.tooltip_HQ_icon_on              = stage.loaderInfo.parameters["tooltip_HQ_icon_on"]; }catch(err:Error){}
			//try{ _globalParameters.tooltip_rus_subs_off_button     = stage.loaderInfo.parameters["tooltip_rus_subs_off_button"]; }catch(err:Error){}
			//try{ _globalParameters.tooltip_rus_subs_on_button      = stage.loaderInfo.parameters["tooltip_rus_subs_on_button"]; }catch(err:Error){}

			_globalParameters._isTrailer = (_globalParameters.player_type != "movie");
			
			_initInterface();
		}
		
		private function _initInterface():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._initInterface");
			}
			this.tabChildren = false;
			this.tabEnabled = false;
			stage.align = StageAlign.TOP_LEFT//.LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			/*if(_systemObject["trailer"] == "true"){
				if(_systemObject["small_trailer"] == "true"){
					_globalWidth = 283;
					_globalHeight = 159;
				}else{
					_globalWidth = 567;
					_globalHeight = 318;
				}				
			}else{
				_globalWidth = 850;
				_globalHeight = 477;
			}*/
			_globalWidth = stage.stageWidth;
			_globalHeight = stage.stageHeight;
			
			_contextMenu = new ContextMenu();
			_contextMenu.hideBuiltInItems();
			
			_contextMenuItem1 = new ContextMenuItem("\u00A9 Ayyo, 2012-2013");
			_contextMenu.customItems.push(_contextMenuItem1);
			
			_contextMenuItem2 = new ContextMenuItem("v2");
			_contextMenu.customItems.push(_contextMenuItem2);
			
			this.contextMenu = _contextMenu;

			_screenShot = new ScreenShot();
			_screenShot.width = _globalWidth;
			_screenShot.height = _globalHeight;
			//_screenShot.trailer = _systemObject["trailer"];
			_screenShot.loadScreenShot(_globalParameters.screenshot_url);
			addChild(_screenShot);

			_videoSprite = new VideoSprite(_globalWidth, _globalHeight, _globalParameters, _globalState);
			addChild(_videoSprite);
		}
		
		private function _initListeners():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._initListeners");
			}
			_videoSprite.addEventListener(VideoSprite.VIDEOSPRITE_PLAYER_RUN, _onPlayerBeginRunHandler);
			_videoSprite.addEventListener(VideoSprite.VIDEOSPRITE_PLAYER_TIMECOMPLETE, _onPlayerCompleteHandler);
		}
		
		private function _onPlayerCompleteHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onPlayerCompleteHandler");
			}
			if(!_globalParameters._isTrailer)
			{
				addChildAt(_screenShot, 0);
			}
			_videoSprite.addEventListener(VideoSprite.VIDEOSPRITE_PLAYER_RUN, _onPlayerBeginRunHandler);
		}
		
		private function _onPlayerBeginRunHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onPlayerBeginRunHandler");
			}
			if(_screenShot.parent)
			{
				removeChild(_screenShot);
			}
			_videoSprite.removeEventListener(VideoSprite.VIDEOSPRITE_PLAYER_RUN, _onPlayerBeginRunHandler);
		}
		
		/*private function _onSpriteClickHandler(evt:MouseEvent):void
		{
			//_videoSprite.onVideoPlayerClickHandler();
		}*/
		
		private function _onAddedToStageHandler():void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onAddedToStageHandler");
			}
			trace("main: _onAddedToStageHandler");
			stage.addEventListener(KeyboardEvent.KEY_DOWN, _onKeyDownHandler);
			stage.stageFocusRect = false;
			stage.addEventListener(Event.RESIZE, _onStageResizeHandler);
			stage.addEventListener(FullScreenEvent.FULL_SCREEN, _onFullscreenEventHandler);
			stage.fullScreenSourceRect = new Rectangle(0,0,Capabilities.screenResolutionX,Capabilities.screenResolutionY);
			//this.removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStageHandler);
		}
		
		private function _onKeyDownHandler(evt:KeyboardEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onKeyDownHandler");
			}
			//trace("main key:", evt.keyCode);
		}
		
		private function _onStageResizeHandler(evt:Event):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onStageResizeHandler");
			}
			if(_globalParameters._isTrailer)
			{
				if(stage.stageWidth >= 190)
					_resizeAllowed = true;
				else
					_resizeAllowed = false;
			}
			else
			{
				if(stage.stageWidth >= 425)
					_resizeAllowed = true;
				else
					_resizeAllowed = false;
			}
			if(_resizeAllowed)
			{
				_globalWidth = stage.stageWidth;
				_globalHeight = stage.stageHeight;
			
				if(_screenShot)
				{
					_screenShot.width = stage.stageWidth;
					_screenShot.height = stage.stageHeight;
				}
				if(_screenShot)
				{
					_screenShot.resizeAll();
				}
				/*if(_videoSprite)
				{
					_videoSprite.resizeAll();
				}*/
			}
		}
		
		private function _onFullscreenEventHandler(evt:FullScreenEvent):void
		{
			CONFIG::JSDEBUG {
				if(ExternalInterface.available) ExternalInterface.call("console.log", "MainClass._onFullscreenEventHandler("+evt.fullScreen+")");
			}
			if(evt.fullScreen)
			{
				_screenShot.x = (stage.stageWidth - _screenShot.width)/2;
				_screenShot.y = (stage.stage.stageHeight - _screenShot.height)/2;
			}
			else
			{
				_screenShot.x = 0;
				_screenShot.y = 0;
			}
		}
	}
}