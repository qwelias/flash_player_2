package ayyo.player.modules.controllpanel.commands {
	import ayyo.player.core.model.PlayerConstants;
	import ayyo.player.events.ConfigEvent;
	import ayyo.player.modules.controllpanel.events.PluginEvent;
	import ayyo.player.modules.controllpanel.plugins.api.IControllPanelPlugin;

	import robotlegs.bender.extensions.commandCenter.api.ICommand;
	import robotlegs.bender.extensions.contextView.ContextView;

	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AddControllPanelUIElements implements ICommand {
		[Inject]
		public var contextView : ContextView;
		[Inject]
		public var event : ConfigEvent;
		[Inject]
		public var dispatcher : IEventDispatcher;

		public function execute() : void {
			var plugins : Array = this.event.config[PlayerConstants.PLUGINS_NAME];
			var description : String;
			var type : Class;
			var plugin : IControllPanelPlugin;
			while(plugins.length) {
				description = plugins.shift();
				trace('description: ' + (description));
				if (ApplicationDomain.currentDomain.hasDefinition(description)) {
					type = ApplicationDomain.currentDomain.getDefinition(description) as Class;
					plugin = new type();
					plugin && this.dispatcher.dispatchEvent(new PluginEvent(PluginEvent.REGISTER, plugin));
				}
			}
		}
	}
}
