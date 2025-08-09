package backend;

class Replay
{
	// 整个组>摁压类型>行数>时间
	static public var saveData:Array<Array<Array<Float>>> = [[], []];
	static public var hitData:Array<Array<Array<Float>>> = [[], []];

	static public var songName:String = '';
	static public var songScore:Int = 0;
	static public var songLength:Float = 0;
	static public var songHits:Int = 0;
	static public var songMisses:Int = 0;

	static public var ratingPercent:Float = 0;
	static public var ratingFC:String = '';
	static public var ratingName:String = '';

	static public var highestCombo:Int = 0;
	static public var NoteTime:Array<Float> = [];
	static public var NoteMs:Array<Float> = [];

	static public var songSpeed:Float = 0;
	static public var playbackRate:Float = 0;
	static public var healthGain:Float = 0;
	static public var healthLoss:Float = 0;
	static public var cpuControlled:Bool = false;
	static public var practiceMode:Bool = false;
	static public var instakillOnMiss:Bool = false;
	static public var opponent:Bool = false;
	static public var flipChart:Bool = false;
	static public var nowTime:String = '';

	static public var mania:Int = 3; // 键位数变量，默认为4键 //但神必Psych EK默认为“3”
	static var isPaused:Bool = false;
	static var checkArray:Array<Float> = [];
	static var allowHit:Array<Bool> = [];

	/////////////////////////////////////////////

	static public function push(time:Float, type:Int, state:Int)
	{
		if (!PlayState.replayMode && type < mania)
			try
			{
				saveData[state][type].push(time);
			}
	}

	static public function pauseCheck(time:Float, type:Int)
	{
		if (PlayState.replayMode || type >= mania)
			return;
		checkArray[type] = time;
	}

	static public function keysCheck()
	{
		if (!PlayState.replayMode)
		{
			if (isPaused)
			{
				for (key in 0...mania)
				{
					if (key < checkArray.length && !PlayState.instance.controls.pressed(PlayState.instance.keysArray[key]) && checkArray[key] != -9999)
						push(checkArray[key], key, 1);
				}

				// 重置检查数组
				for (i in 0...mania)
					checkArray[i] = -9999;
				isPaused = false;
			}
		}
		else
		{
			for (type in 0...mania)
			{
				if (type < hitData[1].length && hitData[1][type].length > 0 && hitData[1][type][0] < Conductor.songPosition)
					holdCheck(type);
			}
		}
	}

	static function holdCheck(type:Int)
	{
		if (type >= hitData[0].length || type >= hitData[1].length) 
			return;
			
		if (hitData[0][type][0] >= Conductor.songPosition)
		{
			PlayState.instance.keysCheck(type, Conductor.songPosition);
			if (allowHit[type])
			{
				PlayState.instance.keyPressed(type, hitData[1][type][0]);
				allowHit[type] = false;
			}
		}
		else
		{
			PlayState.instance.keysCheck(type, Conductor.songPosition); // 长键多一帧的检测
			if (allowHit[type])
			{
				PlayState.instance.keyPressed(type, hitData[1][type][0]); // 摁下松开时间如果太短导致没检测到
			}
			PlayState.instance.keyReleased(type);
			allowHit[type] = true;
			hitData[0][type].splice(0, 1);
			hitData[1][type].splice(0, 1);
		}
	}

	static public function init()
	{
		// 只能这么复制 --狐月影
		hitData = [[], []];
		for (state in 0...2)
		{
			hitData[state] = [];
			for (type in 0...mania)
			{
				hitData[state][type] = [];
				for (hit in 0...saveData[state][type].length)
				{
					hitData[state][type].push(saveData[state][type][hit]);
				}
			}
		}
		
		// 初始化允许命中数组
		allowHit = [];
		for (i in 0...mania)
			allowHit.push(true);
	}

	static public function reset()
	{
		// 愚蠢但是有用 --狐月影
		saveData = [[], []];
		hitData = [[], []];
		
		for (state in 0...2)
		{
			saveData[state] = [];
			hitData[state] = [];
			for (type in 0...mania)
			{
				saveData[state][type] = [];
				hitData[state][type] = [];
			}
		}
		
		// 初始化检查数组
		checkArray = [];
		for (i in 0...mania)
			checkArray.push(-9999);
		
		// 初始化允许命中数组
		allowHit = [];
		for (i in 0...mania)
			allowHit.push(true);
		
		isPaused = false;
	}

	static public function putDetails(putData:Array<Dynamic>)
	{
		// 六百六十六 -狐月影
		songName = putData[0];
		songScore = putData[1];
		songLength = putData[2];
		songHits = putData[3];
		songMisses = putData[4];
		ratingPercent = putData[5];
		ratingFC = putData[6];
		ratingName = putData[7];
		highestCombo = putData[8];
		NoteTime = putData[9];
		NoteMs = putData[10];
		songSpeed = putData[11];
		playbackRate = putData[12];
		healthGain = putData[13];
		healthLoss = putData[14];
		cpuControlled = putData[15];
		practiceMode = putData[16];
		instakillOnMiss = putData[17];
		opponent = putData[18];
		flipChart = putData[19];
		nowTime = putData[20];
	}
}