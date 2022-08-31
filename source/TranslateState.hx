package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.util.FlxColor;

class TranslateState extends MusicBeatState
{
    var text:FlxText;

    var bg:FlxSprite;

    var languages:Array<String> = ['English','Русский','Español','Deutsch','Polski','Português','Português (brasileiro)',"Français"];

    public static var onComplete:() -> Void;

    var curSelected:Int = 0;
    
    override public function create()
    {
        curSelected = FlxG.save.data.translationCS;
        
        bg = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
		bg.color = 0xFFea71fd;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

        text = new FlxText();
        text.setFormat(Paths.font('vcr.ttf'), 45, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        text.text = '< Ъуъ >';
        text.screenCenter(X);
        text.screenCenter(Y);
        text.scrollFactor.set();
        add(text);

        super.create();
    }

    override public function update(elapsed:Float) {
        text.text = "< " + languages[curSelected] + " >";
        FlxG.save.data.language = languages[curSelected];
        FlxG.save.data.translationCS = curSelected;
        if(controls.UI_LEFT_P)
            changeSelected(-1);
        if(controls.UI_RIGHT_P)
            changeSelected(1);

        if(controls.BACK || controls.ACCEPT)
        {
            LoadingState.loadAndSwitchState(new MainMenuState());
        }

        super.update(elapsed);
    }

    function changeSelected(change:Int = 0):Void
    {
        curSelected += change;
    
        if (curSelected >= languages.length)
            curSelected = 0;
        if (curSelected < 0)
            curSelected = languages.length - 1;

        FlxG.sound.play(Paths.sound('scrollMenu'));
    }
}