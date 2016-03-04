import luxe.Color;
import luxe.Vector;
import phoenix.geometry.*;
import luxe.tween.Actuate;
import luxe.tween.actuators.GenericActuator.IGenericActuator;
import luxe.Visual;
using ColorExtender;
using PolylineExtender;

enum Direction {
	Left;
	Right;
	Up;
	Down;
}

enum OutroAnimation {
	Disappear;
	FillScreen;
	Emphasize;
}

//maybe this should all be a "Visual" class
class ActionButton extends Visual {

	public var startSize : Float;
	public var endSize : Float;
	public var curSize (default, set) : Float;

	private var editFrame = 0;
	private var isEditing = false;

	public var pullDir : Direction;
	public var outro : OutroAnimation;



	//saveable data (extract into its own struct-like object?)
	var backgroundColor : Color;
	public var illustrationColor : Color;
	public var terrainPos : Float;
	public var height : Float;

	public var terrain : Terrain;
	var geo : Array<Geometry> = [];

	public var stateController = 1; //needs a better name

	public var curState = 0; //0 - start, 1 - end

	public var illustrations : Array<Array<Polystroke>> = [[],[]];
	public var curIllustrationIndex = 0;
	public var curIllustration /*(get, null)*/ : Array<Polystroke>;

	public override function new(_options : luxe.options.VisualOptions) {
		super(_options);
		geometry = Luxe.draw.circle({
			x : 0, y : 0,
			r : 100, //arbitrary
			batcher : _options.batcher
		});
	}

	function set_curSize(size) : Float {
		curSize = size;
		scale = new Vector(curSize, curSize);

		if (isEditing) {
			if (editFrame == 0) startSize = curSize;
			if (editFrame == 1) endSize = curSize;
		}

		return curSize;
	}

	public function editStart() {
		editFrame = 0;
		isEditing = true;
		curSize = startSize;
	}

	public function editEnd() {
		editFrame = 1;
		isEditing = true;
		curSize = endSize;
	}

	public function animateAppear() : IGenericActuator {
		isEditing = false; //hack?
		curSize = 0;
		return Actuate.tween(this, 1.0, {curSize: startSize})
					.ease(luxe.tween.easing.Bounce.easeOut);
	}

	public function animatePull() : IGenericActuator {
		isEditing = false; //hack?
		curSize = startSize;
		return Actuate.tween(this, 3.0, {curSize: endSize})
					.ease(luxe.tween.easing.Quad.easeOut);
	}

	public function animateOutro() : IGenericActuator { //returning this will be tricky
		switch outro {
			case OutroAnimation.Disappear:
				return animateDisappear();
			case OutroAnimation.FillScreen:
				return animateFillScreen();
			case OutroAnimation.Emphasize:
				return animateEmphasize();
		}
	}

	function animateDisappear() : IGenericActuator {
		isEditing = false; //hack?
		curSize = endSize;
		return Actuate.tween(this, 1.0, {curSize: 0})
				.ease(luxe.tween.easing.Elastic.easeIn);
	}

	function animateFillScreen() : IGenericActuator {
		isEditing = false; //hack?
		curSize = endSize;
		return Actuate.tween(this, 1.0, {curSize: Luxe.screen.width})
				.ease(luxe.tween.easing.Quad.easeIn);
	}

	//TODO still broken
	function animateEmphasize() {
		isEditing = false; //hack?
		curSize = endSize;

		//hacky spoof object
		var returnObj = {
			complete : null,
			onComplete : function(method : Dynamic) {
				returnObj.complete = method;
			},
		};

		Actuate.tween(this, 0.6, {curSize: (endSize * 1.5)})
				.ease(luxe.tween.easing.Bounce.easeOut)
				.onComplete(function() {
					Actuate.tween(this, 0.2, {curSize: 0})
							.delay(0.4)
							.ease(luxe.tween.easing.Quad.easeIn)
							.onComplete(function() {
								returnObj.complete();
							});
				});

		return returnObj;
	}

	public function animateSequence() { //can't figure out how to return this
		animateAppear()
			.onComplete(function() {
				animatePull()
					.onComplete(function(){
							animateOutro();
						});
			});
	}

	public function toJson() {
		var illustration1 = [];
		for (p in illustrations[0]) {
			illustration1.push(p.toJson());
		}
		var illustration2 = [];
		for (p in illustrations[1]) {
			illustration2.push(p.toJson());
		}

		return {
			type : "action",
			backgroundColor : backgroundColor.toJson(),
			illustrationColor : illustrationColor.toJson(),
			terrainPos : terrainPos,
			height : height,
			startSize : startSize,
			endSize : endSize,
			pullDir : pullDir.getName(),
			outro : outro.getName(),
			illustration1: illustration1,
			illustration2: illustration2
		};
	}

	public function fromJson(json : Dynamic) : ActionButton {
		backgroundColor = (new Color()).fromJson(json.backgroundColor);
		illustrationColor = (new Color()).fromJson(json.illustrationColor);
		terrainPos = json.terrainPos;
		height = json.height;
		startSize = json.startSize;
		endSize = json.endSize;
		pullDir = Direction.createByName(json.pullDir);
		outro = OutroAnimation.createByName(json.outro);

		for (j in cast(json.illustration1, Array<Dynamic>)) {
			var p = new Polystroke({},[]).fromJson(j);
			illustrations[0].push(p);
		}
		for (j in cast(json.illustration2, Array<Dynamic>)) {
			var p = new Polystroke({},[]).fromJson(j);
			illustrations[1].push(p);
		}
		//switchIllustration(0);

		//curSize = startSize;

		//test stuff
		color = backgroundColor;

		return this;
	}
}