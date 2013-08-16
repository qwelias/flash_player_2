package ayyo.player.modules.splash {
	import ayyo.player.modules.info.impl.ModuleInfo;
	import ayyo.player.modules.base.impl.AbstractModule;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SplashScreen extends AbstractModule {
		public function SplashScreen(autoCreate : Boolean = false) {
			super(autoCreate);
		}

		override public function initialize(moduleInfo : ModuleInfo) : void {
			super.initialize(moduleInfo);
			trace('moduleInfo.name: ' + (moduleInfo.name));
		}
	}
}
