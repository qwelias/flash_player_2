package ayyo.player.core.commands {
	import by.blooddy.crypto.serialization.JSON;
	import ayyo.player.config.api.IPlayerConfig;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class GetApplicationConfig implements ICommand {
		[Inject]
		public var playerConfig : IPlayerConfig;

		public function execute() : void {
			var source : Object = by.blooddy.crypto.serialization.JSON.decode('{"settings":{"screenshot":"banner.jpg","type":"movie","free":false,"timeLeft":48},"assets":[],"tooltip":{"playButton":"Смотреть","pauseButton":"Пауза","timeLeft":"У вас осталось %HOURS% часов, чтобы посмотреть фильм","timer":"Посмотреть сколько осталось","timerReverse":"Посмотреть продолжительность","highQuality":"Включить отличное качество","standartQuality":"Включить стандартное качество","sound":"Включить звук","mute":"Выключить звук","fullscreen":"Развернуть на весь экран","window":"Свернуть"},"replaceWord":{"forTimeLeft":"%HOURS%"}}');
			playerConfig.initialize(source);
		}
	}
}
