package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
#if (MODS_ALLOWED || sys)
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	public static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var boobas:FlxTypedGroup<FlxSprite>;
	var ngSpr:FlxSprite;

	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO, FlxKey.NUMPADZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	var swagShader:ColorSwap = null;

	override public function create():Void
	{
		// TODO: Refactor this to use OpenFlAssets.
		#if MODS_ALLOWED
		// Just to load a mod on start up if ya got one. For mods that change the menu music and bg
		if (FileSystem.exists("modsList.txt")){
			
			var list:Array<String> = CoolUtil.listFromString(File.getContent("modsList.txt"));
			var foundTheTop = false;
			for (i in list){
				var dat = i.split("|");
				if (dat[1] == "1" && !foundTheTop){
					foundTheTop = true;
					Paths.currentModDirectory = dat[0];
				}
				
			}
		}
		#end

		@:privateAccess
		{
			trace("We loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets into the default library");
		}

		FlxG.autoPause = false;

		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();


		FlxG.game.focusLostFramerate = 60;
		FlxG.sound.muteKeys = muteKeys;
		FlxG.sound.volumeDownKeys = volumeDownKeys;
		FlxG.sound.volumeUpKeys = volumeUpKeys;
		FlxG.keys.preventDefaultKeys = [TAB];

		PlayerSettings.init();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		swagShader = new ColorSwap();
		super.create();

		ClientPrefs.loadPrefs();

		Highscore.load();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {
			#if desktop
			DiscordClient.initialize();
			Application.current.onExit.add (function (exitCode) {
				DiscordClient.shutdown();
			});
			#end
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var funnyTeam:FlxSprite;

	function startIntro():Void
	{
		Application.current.window.title = 'The Funkin World of Gumball - Title Screen';

		persistentUpdate = true;

		boobas = new FlxTypedGroup<FlxSprite>();
		swagShader = new ColorSwap();

		if(!ClientPrefs.lowQuality)
		{
			var bg:FlxSprite = new FlxSprite(-1200, -100).loadGraphic(Paths.image('gumballBG/GumballWeek_BG', 'shared'));
			bg.antialiasing = ClientPrefs.globalAntialiasing;
			bg.scrollFactor.set(0.9, 0.9);
			bg.active = false;
			bg.scale.x = 1.3;
			bg.scale.y = 1.3;
			add(bg);
		}

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('funkinWorldBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.updateHitbox();
		logoBl.screenCenter();
		logoBl.shader = swagShader.shader;
		// logoBl.color = FlxColor.BLACK;

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = ClientPrefs.globalAntialiasing;
		//add(gfDance);
		boobas.add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = ClientPrefs.globalAntialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		boobas.add(titleText);
		add(boobas);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52);
		ngSpr.loadGraphic(Paths.image('kade'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.globalAntialiasing;

		funnyTeam = new FlxSprite(0, 0);
		funnyTeam.loadGraphic(Paths.image('team'));
		if(!ClientPrefs.lowQuality)
			add(funnyTeam);
		funnyTeam.visible = false;
		funnyTeam.setGraphicSize(Std.int(funnyTeam.width * 0.5));
		funnyTeam.updateHitbox();
		funnyTeam.screenCenter();
		funnyTeam.antialiasing = ClientPrefs.globalAntialiasing;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else
		{
			/*var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(110);
			initialized = true;
		}

		#if VIDEOS_ALLOWED
		if(FlxG.random.bool(1))
			{
				var video:FlxVideo = new FlxVideo(Paths.video('devChaos'));
				FlxG.sound.music.volume = 0;
				video.finishCallback = function()
				{
					FlxG.switchState(new MainMenuState());
					FlxG.sound.music.volume = 1;
				}
			}
		#end


		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	var fullscreenBind:FlxKey;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.keys.anyJustPressed([fullscreenBind]))
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{
			if (ClientPrefs.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;
			// FlxG.sound.music.stop();

			boobas.forEach(function(spr:FlxSprite)
			{
				FlxTween.tween(spr, {y: 720}, 1.9, {ease: FlxEase.expoIn, startDelay: 0.4});
			});

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				// Get current version of Kade Engine

				if (FlxG.save.data.language == null)
				{
					FlxG.switchState(new TranslateState());
				}
				else
				{
					FlxG.switchState(new MainMenuState());
				}
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?yFun:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			money.y += yFun;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, ?yFun:Float = 0)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		coolText.y += yFun;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function addAAAText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
		FlxTween.tween(coolText, {x:1280}, 0.2);
	}

	override function beatHit()
	{
		super.beatHit();

		if(!skippedIntro) FlxTween.tween(FlxG.camera, {zoom:1.025}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});

		logoBl.animation.play('bump', true);
		danceLeft = !danceLeft;

		if (danceLeft)
			logoBl.angle = -4;//gfDance.animation.play('danceRight');
		else
			logoBl.angle = 4;//gfDance.animation.play('danceLeft');

		switch (curBeat)
		{
			case 0:
				deleteCoolText();
			case 1:
				createCoolText(['These people'], -120);
				funnyTeam.visible = true;
			case 3:
				addMoreText('present', 230);
			// credTextShit.text += '\npresent...';
			// credTextShit.addText();
			case 4:
				deleteCoolText();
				funnyTeam.visible = false;
			// credTextShit.visible = false;
			// credTextShit.text = 'In association \nwith';
			// credTextShit.screenCenter();
			case 5:
				addMoreText('mod about tawog');
			case 7:
				addMoreText('lmao');
			case 8:
				deleteCoolText();
			case 9:
				if (ClientPrefs.watermarks)
					createCoolText(['Psych Engine', 'by']);
				else
					addMoreText(curWacky[0]);
			case 11:
				if (ClientPrefs.watermarks)
				{
					addMoreText('Shadow Mario and RiverOaken');
					//ngSpr.visible = true;
				}
				else
				{
					addMoreText(curWacky[1]);
				}
				
			// credTextShit.text += '\nNewgrounds';
			case 12:
				deleteCoolText();
				//ngSpr.visible = false;
			// credTextShit.visible = false;

			// credTextShit.text = 'Shoutouts Tom Fulp';
			// credTextShit.screenCenter();
			// credTextShit.visible = false;
			// credTextShit.text = "Friday";
			// credTextShit.screenCenter();
			case 13:
				addMoreText('The Funkin World of Gumball');
			// credTextShit.text += '\nNight';
			case 15:
				trace('I shit my pants 0_0');
				deleteCoolText();
				addMoreText('A'); // credTextShit.text += '\nFunkin';
				new FlxTimer().start(0.02, function(tmr:FlxTimer){
					deleteCoolText();
					addMoreText('AA');
					new FlxTimer().start(0.02, function(tmr:FlxTimer){
						deleteCoolText();
						addMoreText('AAA');
						new FlxTimer().start(0.02, function(tmr:FlxTimer){
							deleteCoolText();
							addAAAText('AAAA');
						});
					});
				});

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			trace("Skipping intro...");
			
			FlxG.camera.zoom = 30; // ZOOOOM
			FlxTween.tween(FlxG.camera, {zoom: 1}, 1.1, {ease: FlxEase.expoOut}); // No more zoom 😭

			remove(ngSpr);
			remove(funnyTeam);

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			/*FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (logoBl.angle == -4)
					FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
				if (logoBl.angle == 4)
					FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
			}, 0);*/

			// It always bugged me that it didn't do this before.
			// Skip ahead in the song to the drop.
			// fuck - FlxG.sound.music.time = 9400; // 9.4 seconds

			skippedIntro = true;
		}
	}
}