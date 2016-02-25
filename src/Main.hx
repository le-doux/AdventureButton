
import luxe.Input;
import luxe.Vector;
import ActionButton.Direction;

class Main extends luxe.Game {

	var button : ActionButton;

    override function ready() {
    	button = (new ActionButton()).fromJson({
    		backgroundColor : {r:0,g:0,b:1},
    		illustrationColor : {r:1,g:1,b:1},
    		terrainPos : 0,
    		height : 0,
    		startSize : 100,
    		endSizeMult : 2,
    		pullDir : "Down",
    		outro : "FillScreen"
    	});
    } //ready

	override function onkeydown(e:KeyEvent) {
		if (e.keycode == Key.key_1) {
			button.showStart();
		}
		else if (e.keycode == Key.key_2) {
			button.showEnd();
		}

		if (e.keycode == Key.key_3) {
			button.animateAppear();
		}
		else if (e.keycode == Key.key_4) {
			button.animatePull();
		}

		if (e.keycode == Key.key_q) {
			if (button.curState == 0) {
				button.startSize += 5;
			}
			else {
				button.endSizeMult += 0.1;
			}
			button.updateCurSize();
		}
		else if (e.keycode == Key.key_a) {
			if (button.curState == 0) {
				button.startSize -= 5;
			}
			else {
				button.endSizeMult -= 0.1;
			}
			button.updateCurSize();
		}

		if (e.keycode == Key.left) {
			button.pullDir = Direction.Left;
		}
		else if (e.keycode == Key.right) {
			button.pullDir = Direction.Right;
		}
		else if (e.keycode == Key.up) {
			button.pullDir = Direction.Up;
		}
		else if (e.keycode == Key.down) {
			button.pullDir = Direction.Down;
		}
	}

    override function onkeyup( e:KeyEvent ) {

        if(e.keycode == Key.escape) {
            Luxe.shutdown();
        }

    } //onkeyup

    override function update(dt:Float) {
    	Luxe.draw.text({
    		pos: new Vector(0,0),
    		point_size: 20,
    		text: "outro: " + button.outro.getName(),
    		immediate: true
    	});

    	button.drawImmediate();
    } //update


} //Main
