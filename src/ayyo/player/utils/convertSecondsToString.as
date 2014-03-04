package ayyo.player.utils {
	/**
	 * @author Aziz Zaynutdinov (aziz.zaynutdinov at playstorm.com)
	 */
	public function convertSecondsToString(value : uint, duration : uint, isEstimated : Boolean = false) : String {
		var result : String = "00:00:00";
		value = isEstimated ? duration - value : value;
		var hours : uint = value / 3600;
		var minutes : uint = (value - hours * 3600) / 60;
		var seconds : uint = value - hours * 3600 - minutes * 60;
		result = (hours < 10 ? "0" : "") + hours.toString() + ":" + (minutes < 10 ? "0" : "") + minutes.toString() + ":" + (seconds < 10 ? "0" : "") + seconds.toString();
		return result;
	}
}
