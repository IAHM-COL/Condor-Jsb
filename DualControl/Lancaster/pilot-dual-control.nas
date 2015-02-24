###############################################################################
## $Id: pilot-dual-control.nas,v 1.3 2009/05/24 12:52:12 mfranz Exp $
##
## Nasal for main pilot for dual control over the multiplayer network.
##
##  Copyright (C) 2007 - 2009  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
###############################################################################

# Renaming (almost :)
var DCT = dual_control_tools;
var ADC = aircraft_dual_control;
# NOTE: By loading the aircraft specific dual control module
#       as <aircraft_dual_control> this file is generic.
#       The aircraft specific modul must set the variables
#       pilot_type and copilot_type to the name (with full path) of
#       main 3d model XML for the pilot and copilot aircraft.
#       This module should be loaded under the name dual_control.

######################################################################
# Connect to new crew member

var process_data = 0;

var connect = func (crew) {
	print("Trying connect crew member to pilot (pilot-dual-control.nas)");
	# Tweak MP/AI filters
	crew.getNode("controls/allow-extrapolation").setBoolValue(0);
	crew.getNode("controls/lag-adjust-system-speed").setValue(5);

	print("Dual control ... crew member connected.");
	var job="crew member";
	if (crew.getNode("sim/model/path").getValue() == ADC.pilot_type) {
		job="pilot";
		process_data = ADC.pilot_connect_pilot(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.engineer_type) {
		job="engineer";
		process_data = ADC.pilot_connect_engineer(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.navigator_type) {
		job="navigator";
		process_data = ADC.pilot_connect_navigator(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.radioman_type) {
		job="radioman";
		process_data = ADC.pilot_connect_radioman(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.bomber_type) {
		job="bomb aimer";
		process_data = ADC.pilot_connect_bomber(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.turretgunner_type) {
		job="turret gunner";
		process_data = ADC.pilot_connect_turretgunner(crew);
	}
	if (crew.getNode("sim/model/path").getValue() == ADC.tailgunner_type) {
		job="tail gunner";
		process_data = ADC.pilot_connect_tailgunner(crew);
	}
	setprop("/sim/messages/crew", "Hi. I'm your new "~job~" !");
}

######################################################################
# Main loop singleton class.

var main = {

	init : func {
		me.loopid = 0;
		me.active = 0;
		setlistener("/ai/models/model-added", func {
			settimer(func { me.activate(); }, 2);
		});
		settimer(func { me.activate(); }, 5);
		print("Pilot dual control ... initialized");
	},

	reset : func {
		me.active = 0;
		me.loopid += 1;
		me._loop_(me.loopid);
	},

	activate : func {
		if (!me.active) {
			me.reset();
		}
	},

	update : func {
		var mpplayers = props.globals.getNode("/ai/models").getChildren("multiplayer");
		var r_callsign = getprop("/sim/remote/pilot-callsign");

		foreach (var crew; mpplayers) {

			if ((crew.getChild("valid").getValue()) and
				(crew.getChild("callsign") != nil) and
				(crew.getChild("callsign").getValue() == r_callsign)) {

				if (me.active == 0) {
					# Note: sim/model/path tells which XML file of the model. 
          				if ((crew.getNode("sim/model/path") != nil) and
						(
							(crew.getNode("sim/model/path").getValue() == ADC.pilot_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.engineer_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.navigator_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.radioman_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.bomber_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.turretgunner_type) or 
							(crew.getNode("sim/model/path").getValue() == ADC.tailgunner_type)
						)
					) {
						connect(crew);
						me.active = 1;
					} else {
						print("Dual control ... crew member rejected - wrong aircraft type.");
						me.loopid += 1;
						return;
					}
				}

				# Mess with the MP filters. Highly experimental.
				if (copilot.getNode("controls/lag-time-offset") != nil) {
					var v = copilot.getNode("controls/lag-time-offset").getValue();
					copilot.getNode("controls/lag-time-offset").setValue(0.97 * v);
				}

				foreach (var w; process_data) {
					w.update();
				}
				return;
			}
		}
		if (me.active) {
			print("Dual control ... crew member disconnected.");
			ADC.pilot_disconnect_crew();
		}
		me.loopid += 1;
		me.active = 0;
	},

	_loop_ : func(id) {
		id == me.loopid or return;
		me.update();
		settimer(func { me._loop_(id); }, 0);
	}
};

######################################################################
# Initialization.
setlistener("/sim/signals/fdm-initialized", func {
	main.init();
});
