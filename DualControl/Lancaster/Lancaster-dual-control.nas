###############################################################################
##  Nasal for dual control of the Douglas DC3-C47 over the multiplayer network.
##
##  Copyright (C) 2007 - 2008  Anders Gidenstam  (anders(at)gidenstam.org)
##  This file is licensed under the GPL license version 2 or later.
##
##  Modified by Clément de l'Hamaide for Douglas DC3-C47 - 13/08/2011
##
###############################################################################

## Renaming (almost :)
var DCT = dual_control_tools;

## Pilot/copilot aircraft identifiers. Used by dual_control.
var pilot_type   = "Aircraft/Lancaster-Jsb/Models/lancaster.xml";
var engineer_type = "Aircraft/Lancaster-Jsb/Models/lancaster-engineer.xml";
var navigator_type = "Aircraft/Lancaster-Jsb/Models/lancaster-navigator.xml";
var radioman_type = "Aircraft/Lancaster-Jsb/Models/lancaster-radioman.xml";
var bomber_type = "Aircraft/Lancaster-Jsb/Models/lancaster-bomber.xml";
var turretgunner_type = "Aircraft/Lancaster-Jsb/Models/lancaster-turretgunner.xml";
var tailgunner_type = "Aircraft/Lancaster-Jsb/Models/lancaster-tailgunner.xml";

############################ PROPERTIES MP ###########################

# Engine 1 for pilot #################################################
var rpm_pilot        = ["engines/engine[0]/rpm", "engines/engine[1]/rpm", "engines/engine[2]/rpm", "engines/engine[3]/rpm"];
var throttle0_pilot  = ["sim/multiplay/generic/float[6]", "sim/multiplay/generic/float[7]"];
var mixture0_pilot   = ["sim/multiplay/generic/float[8]", "sim/multiplay/generic/float[9]"];
var propeller0_pilot = ["sim/multiplay/generic/float[10]", "sim/multiplay/generic/float[11]"];

# Engine 1 for engineer ##############################################
var rpm_eng         = ["engines/engine[0]/rpm", "engines/engine[1]/rpm"];
var throttle0_pilot  = ["sim/multiplay/generic/float[6]", "sim/multiplay/generic/float[7]"];
var mixture0_pilot   = ["sim/multiplay/generic/float[8]", "sim/multiplay/generic/float[9]"];
var propeller0_pilot = ["sim/multiplay/generic/float[10]", "sim/multiplay/generic/float[11]"];

var l_dual_control    = "dual-control/active";

######################################################################
###### Used by dual_control to set up the mappings for the pilot #####
######################## PILOT TO PILOT ##############################
######################################################################

var pilot_connect_pilot = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

		DCT.MostRecentSelector.new(
			props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
			props.globals.getNode("dual-control/crew/rpm0_engineer"), 
			props.globals.getNode("dual-control/crew/rpm0_engineer"), 
			0.1
		),

		DCT.MostRecentSelector.new(
			props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
			props.globals.getNode("dual-control/crew/throttle0_engineer"), 
			props.globals.getNode("dual-control/crew/throttle0_engineer"), 
			0.1
		),

		DCT.MostRecentSelector.new(
			props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
			props.globals.getNode("dual-control/crew/mixture0_engineer"), 
			props.globals.getNode("dual-control/crew/mixture0_engineer"), 
			0.1
		),

		DCT.MostRecentSelector.new(
			props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
			props.globals.getNode("dual-control/crew/propeller0_engineer"), 
			props.globals.getNode("dual-control/crew/propeller0_engineer"), 
			0.1
		),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_engineer = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_navigator = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_radioman = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_bomber = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_turretgunner = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

var pilot_connect_tailgunner = func (crew) {
	# Make sure dual-control is activated in the FDM FCS.
	print("Pilot section");
	setprop(l_dual_control, 1);

	# VHF 22 Comm. Comm 1 is owned by pilot, 2 by copilot.
	VHF22.make_master(0);
	VHF22.make_slave_to(1, crew);

	return [
		##################################################
		# Map engineer properties to buffer properties

		DCT.MostRecentSelector.new(crew.getNode(rpm[0]), props.globals.getNode(rpm0_engineer), props.globals.getNode(rpm0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(throttle[0]), props.globals.getNode(throttle0_engineer), props.globals.getNode(throttle0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(mixture[0]), props.globals.getNode(mixture0_engineer), props.globals.getNode(mixture0_engineer), 0.0001),
		DCT.MostRecentSelector.new(crew.getNode(propeller[0]), props.globals.getNode(propeller0_engineer), props.globals.getNode(propeller0_engineer), 0.0001),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(instrument_lights),
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1]),
#			] ~ VHF22.master_send_state(0), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(battery_switch),
#				props.globals.getNode(starter_switch[0]),
#				props.globals.getNode(starter_switch[1]),
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#			] ~ VHF22.slave_send_buttons(1), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(crew.getNode(TDM_mpp), [
#				func(v){props.globals.getNode("dual-control/crew/"~instrument_lights, 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){props.globals.getNode("dual-control/crew/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(1)
#		),

#		DCT.SwitchDecoder.new(crew.getNode(switch_mpp), [
#				func(b){props.globals.getNode("dual-control/crew/"~battery_switch, 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~running[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[0], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~cranking[1], 1).setValue(b);},
#				func(b){props.globals.getNode("dual-control/crew/"~brake_parking, 1).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(0)
#		),

		##################################################      
		# Map the most recent value between pilot and engineer to pilot properties

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/rpm0_engineer", 1), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				props.globals.getNode("dual-control/crew/rpm0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/throttle0_engineer", 1), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				props.globals.getNode("dual-control/crew/throttle0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/mixture0_engineer", 1), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				props.globals.getNode("dual-control/crew/mixture0_engineer"), 
				0.1
			),

			DCT.MostRecentSelector.new(
				props.globals.getNode("dual-control/crew/propeller0_engineer", 1), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				props.globals.getNode("dual-control/crew/propeller0_engineer"), 
				0.1
			),

		##### BOOLEAN PROPERTIES #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[0], 1), props.globals.getNode(running[0]), props.globals.getNode(running[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~running[1], 1), props.globals.getNode(running[1]), props.globals.getNode(running[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[0], 1), props.globals.getNode(cranking[0]), props.globals.getNode(cranking[0]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cranking[1], 1), props.globals.getNode(cranking[1]), props.globals.getNode(cranking[1]), 0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_parking, 1), 
#				props.globals.getNode(brake_parking), 
#				props.globals.getNode(brake_parking), 
#				0.1
#			),

			##### OTHERS #####
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[0], 1), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				props.globals.getNode(magnetos_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~magnetos_cmd[1], 1), 
#				props.globals.getNode(magnetos_cmd[1]), 
#                               props.globals.getNode(magnetos_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[0], 1), 
#				props.globals.getNode(fuel_cmd[0]), 
#                               props.globals.getNode(fuel_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~fuel_cmd[1], 1), 
#				props.globals.getNode(fuel_cmd[1]), 
#				props.globals.getNode(fuel_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[0], 1), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				props.globals.getNode(cowl_flaps_cmd[0]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~cowl_flaps_cmd[1], 1), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				props.globals.getNode(cowl_flaps_cmd[1]), 
#				0.1
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/crew/"~brake_cmd[0], 1), 
#				props.globals.getNode(brake_cmd[0]), 
#				props.globals.getNode(brake_cmd[0]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~brake_cmd[1], 1), 
#				props.globals.getNode(brake_cmd[1]), 
#				props.globals.getNode(brake_cmd[1]), 
#				0.000001
#			),
#			DCT.MostRecentSelector.new(
#				props.globals.getNode("dual-control/copilot/"~flaps_cmd, 1), 
#				props.globals.getNode(flaps_cmd), 
#				props.globals.getNode(flaps_cmd), 
#				0.1
#			),
#
		];
	}

	##############
	var pilot_disconnect_crew = func {
		setprop(l_dual_control, 0);
		VHF22.make_master(1);
	}

	######################################################################
	##### Used by dual_control to set up the mappings for the copilot ####
	######################## COPILOT TO PILOT ############################
	######################################################################

	var engineer_connect_pilot = func(pilot) {
		# Make sure dual-control is activated in the FDM FCS.
		print("Crew section");
		setprop(l_dual_control, 1);

		VHF22.make_slave_to(0, pilot);
		VHF22.make_master(1);
		VHF22.animate_aimodel(0, pilot);

	return [
		##################################################
		# Map pilot properties to buffer properties

#		DCT.StableTrigger.new(pilot.getNode(rudder), func(v){v -= pilot.getNode(rudder_trim).getValue(); props.globals.getNode(rudder_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(aileron), func(v){ v -= pilot.getNode(aileron_trim).getValue(); props.globals.getNode(aileron_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(elevator), func(v){v -=  pilot.getNode(elevator_trim).getValue(); props.globals.getNode(elevator_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(throttle[0]), func(v){props.globals.getNode(throttle_cmd[0], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(throttle[1]), func(v){props.globals.getNode(throttle_cmd[1], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(mixture[0]), func(v){props.globals.getNode(mixture_cmd[0], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(mixture[1]), func(v){props.globals.getNode(mixture_cmd[1], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(propeller[0]), func(v){props.globals.getNode(propeller_cmd[0], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(propeller[1]), func(v){props.globals.getNode(propeller_cmd[1], 1).setValue(v);}),

#		DCT.StableTrigger.new(pilot.getNode(elevator_trim), func(v){props.globals.getNode(elevator_trim_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(rudder_trim), func(v){props.globals.getNode(rudder_trim_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(aileron_trim), func(v){props.globals.getNode(aileron_trim_cmd, 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(brake[0]), func(v){props.globals.getNode(brake_cmd[0], 1).setValue(v);}),
#		DCT.StableTrigger.new(pilot.getNode(brake[1]), func(v){props.globals.getNode(brake_cmd[1], 1).setValue(v);}),
#		DCT.Translator.new(pilot.getNode(rpm[0]), props.globals.getNode(rpm_cmd[0], 1)),
#		DCT.Translator.new(pilot.getNode(rpm[1]), props.globals.getNode(rpm_cmd[1], 1)),

		##################################################
		# Switch Encoder
#		DCT.TDMEncoder.new([
#				props.globals.getNode(magnetos_cmd[0]),
#				props.globals.getNode(magnetos_cmd[1]),
#				props.globals.getNode(fuel_cmd[0]),
#				props.globals.getNode(fuel_cmd[1]),
#				props.globals.getNode(cowl_flaps_cmd[0]),
#				props.globals.getNode(cowl_flaps_cmd[1])
#			] ~ VHF22.master_send_state(1), props.globals.getNode(TDM_mpp)
#		),

#		DCT.SwitchEncoder.new([
#				props.globals.getNode(running[0]),
#				props.globals.getNode(running[1]),
#				props.globals.getNode(cranking[0]),
#				props.globals.getNode(cranking[1]),
#				props.globals.getNode(brake_parking),
#				props.globals.getNode(lock_wheel),
#			] ~ VHF22.slave_send_buttons(0), props.globals.getNode(switch_mpp)
#		),

		##################################################
		# Switch decoder
#		DCT.TDMDecoder.new(pilot.getNode(TDM_mpp), [
#				func(v){pilot.getNode(instrument_lights, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~instrument_lights, 1).setValue(v);},
#				func(v){pilot.getNode(magnetos_cmd[0]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~magnetos_cmd[0], 1).setValue(v);},
#				func(v){pilot.getNode(magnetos_cmd[1]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~magnetos_cmd[1], 1).setValue(v);},
#				func(v){pilot.getNode(fuel_cmd[0]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_cmd[0], 1).setValue(v);},
#				func(v){pilot.getNode(fuel_cmd[1]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~fuel_cmd[1], 1).setValue(v);},
#				func(v){pilot.getNode(cowl_flaps_cmd[0]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~cowl_flaps_cmd[0], 1).setValue(v);},
#				func(v){pilot.getNode(cowl_flaps_cmd[1]~"-pos", 1).setValue(v); props.globals.getNode("dual-control/pilot/"~cowl_flaps_cmd[1], 1).setValue(v);},
#				func(v){pilot.getNode(flaps_cmd, 1).setValue(v); props.globals.getNode("dual-control/pilot/"~flaps_cmd, 1).setValue(v);},
#			] ~ VHF22.slave_receive_master_state(0)
#		),

#		DCT.SwitchDecoder.new(pilot.getNode(switch_mpp), [
#				func(b){props.globals.getNode(running[0]).setValue(b);},
#				func(b){props.globals.getNode(running[1]).setValue(b);},
#				func(b){props.globals.getNode(cranking[0]).setValue(b);},
#				func(b){props.globals.getNode(cranking[1]).setValue(b);},
#				func(b){props.globals.getNode(brake_parking).setValue(b);},
#				func(b){props.globals.getNode(lock_wheel).setValue(b);},
#			] ~ VHF22.master_receive_slave_buttons(1)
#		),

		##################################################
		# Enable animation for copilot
#		DCT.Translator.new(props.globals.getNode(rudder_cmd), pilot.getNode(rudder_cmd)),
#		DCT.Translator.new(props.globals.getNode(aileron_cmd), pilot.getNode(aileron_cmd)),
#		DCT.Translator.new(props.globals.getNode(elevator_cmd), pilot.getNode(elevator_cmd)),
#		DCT.Translator.new(props.globals.getNode(elevator_trim_cmd), pilot.getNode(elevator_trim_cmd)),
#		DCT.Translator.new(props.globals.getNode(rudder_trim_cmd), pilot.getNode(rudder_trim_cmd)),
#		DCT.Translator.new(props.globals.getNode(aileron_trim_cmd), pilot.getNode(aileron_trim_cmd)),
#		DCT.Translator.new(props.globals.getNode(throttle[0]), pilot.getNode(throttle_cmd[0])),
#		DCT.Translator.new(props.globals.getNode(throttle[1]), pilot.getNode(throttle_cmd[1])),
#		DCT.Translator.new(props.globals.getNode(mixture[0]), pilot.getNode(mixture_cmd[0])),
#		DCT.Translator.new(props.globals.getNode(mixture[1]), pilot.getNode(mixture_cmd[1])),
#		DCT.Translator.new(props.globals.getNode(propeller[0]), pilot.getNode(propeller_cmd[0])),
#		DCT.Translator.new(props.globals.getNode(propeller[1]), pilot.getNode(propeller_cmd[1])),
#		DCT.Translator.new(props.globals.getNode(battery_switch~"-pos", 1), pilot.getNode(battery_switch~"-pos")),
#		DCT.Translator.new(props.globals.getNode(oil_dilution[0]~"-pos", 1), pilot.getNode(oil_dilution[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(oil_dilution[1]~"-pos", 1), pilot.getNode(oil_dilution[1]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(parachute_signal~"-pos", 1), pilot.getNode(parachute_signal~"-pos")),
#		DCT.Translator.new(props.globals.getNode(pitot_heat[0]~"-pos", 1), pilot.getNode(pitot_heat[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(pitot_heat[0]~"-pos[1]", 1), pilot.getNode(pitot_heat[0]~"-pos[1]")),
#		DCT.Translator.new(props.globals.getNode(prop_heat~"-pos", 1), pilot.getNode(prop_heat~"-pos")),
#		DCT.Translator.new(props.globals.getNode(window_heat~"-pos", 1), pilot.getNode(window_heat~"-pos")),
#		DCT.Translator.new(props.globals.getNode(boost_pump[0]~"-pos", 1), pilot.getNode(boost_pump[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(boost_pump[1]~"-pos", 1), pilot.getNode(boost_pump[1]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(carb_heat[0]~"-pos", 1), pilot.getNode(carb_heat[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(starter_switch[0]~"-pos", 1), pilot.getNode(starter_switch[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(starter_switch[1]~"-pos", 1), pilot.getNode(starter_switch[1]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(prop_feather[0]~"-pos", 1), pilot.getNode(prop_feather[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(prop_feather[1]~"-pos", 1), pilot.getNode(prop_feather[1]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(landing_lights[0]~"-pos", 1), pilot.getNode(landing_lights[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(landing_lights[1]~"-pos", 1), pilot.getNode(landing_lights[0]~"-pos[1]")),
#		DCT.Translator.new(props.globals.getNode(passing_lights~"-pos", 1), pilot.getNode(passing_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(running_lights~"-pos", 1), pilot.getNode(running_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(tail_lights~"-pos", 1), pilot.getNode(tail_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(cabin_lights~"-pos", 1), pilot.getNode(cabin_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(recognition_lights[0]~"-pos", 1), pilot.getNode(recognition_lights[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(recognition_lights[0]~"-pos[1]", 1), pilot.getNode(recognition_lights[0]~"-pos[1]")),
#		DCT.Translator.new(props.globals.getNode(recognition_lights[0]~"-pos[2]", 1), pilot.getNode(recognition_lights[0]~"-pos[2]")),
#		DCT.Translator.new(props.globals.getNode(compass_lights~"-pos", 1), pilot.getNode(compass_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(formation_lights~"-pos", 1), pilot.getNode(formation_lights~"-pos")),
#		DCT.Translator.new(props.globals.getNode(brake_parking~"-pos", 1), pilot.getNode(brake_parking~"-pos")),
#		DCT.Translator.new(props.globals.getNode(lock_wheel~"-pos", 1), pilot.getNode(lock_wheel~"-pos")),
#		DCT.Translator.new(props.globals.getNode(gear_lock_cmd~"-pos", 1), pilot.getNode(gear_lock_cmd~"-pos")),
#		DCT.Translator.new(props.globals.getNode(fuel_cmd[0]~"-pos", 1), pilot.getNode(fuel_cmd[0]~"-pos")),
#		DCT.Translator.new(props.globals.getNode(fuel_cmd[1]~"-pos", 1), pilot.getNode(fuel_cmd[1]~"-pos")),
#		DCT.Translator.new(props.globals.getNode("controls/engines/engine/cowl-flaps-pos", 1), pilot.getNode("controls/engines/engine/cowl-flaps-pos")),
#		DCT.Translator.new(props.globals.getNode("controls/engines/engine[1]/cowl-flaps-pos", 1), pilot.getNode("controls/engines/engine[1]/cowl-flaps-pos")),
#		DCT.Translator.new(props.globals.getNode("systems/hydraulics/flaps-down-psi"), pilot.getNode("systems/hydraulics/flaps-down-psi")),
#		DCT.Translator.new(props.globals.getNode("systems/hydraulics/flaps-up-psi"), pilot.getNode("systems/hydraulics/flaps-up-psi")),
#		DCT.Translator.new(props.globals.getNode(gear_down_cmd, 1), pilot.getNode(gear_down_cmd)),
#		DCT.Translator.new(props.globals.getNode("systems/hydraulics/landing-gear-psi"), pilot.getNode("systems/hydraulics/landing-gear-psi")),
#		DCT.Translator.new(props.globals.getNode("systems/hydraulics/pump-psi"), pilot.getNode("systems/hydraulics/pump-psi")),
#		DCT.Translator.new(props.globals.getNode("systems/electrical/outputs/instrument-lights"), pilot.getNode("systems/electrical/outputs/instrument-lights")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/details-high"), pilot.getNode("sim/model/config/details-high")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/version"), pilot.getNode("sim/model/config/version")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/show-pilot"), pilot.getNode("sim/model/config/show-pilot")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/show-copilot"), pilot.getNode("sim/model/config/show-copilot")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/show-yokes"), pilot.getNode("sim/model/config/show-yokes")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/glass-reflection"), pilot.getNode("sim/model/config/glass-reflection")),
#		DCT.Translator.new(props.globals.getNode("sim/model/config/light-cone"), pilot.getNode("sim/model/config/light-cone")),
#		DCT.Translator.new(props.globals.getNode("instrumentation/altimeter/indicated-altitude-ft"), pilot.getNode("instrumentation/altimeter/indicated-altitude-ft")),
#		DCT.Translator.new(
#			props.globals.getNode("instrumentation/attitude-indicator/indicated-roll-deg"), 
#			pilot.getNode("instrumentation/attitude-indicator/indicated-roll-deg")
#		),
#		DCT.Translator.new(
#			props.globals.getNode("instrumentation/vertical-speed-indicator/indicated-speed-fpm"), 
#			pilot.getNode("instrumentation/vertical-speed-indicator/indicated-speed-fpm")
#		),
#		DCT.Translator.new(props.globals.getNode("instrumentation/heading-indicator/indicated-heading-deg"), 
#			pilot.getNode("instrumentation/heading-indicator/indicated-heading-deg")
#		),
#		DCT.Translator.new(props.globals.getNode("orientation/heading-magnetic-deg"), pilot.getNode("orientation/heading-magnetic-deg")),
#		DCT.Translator.new(props.globals.getNode("orientation/heading-deg"), pilot.getNode("orientation/heading-deg")),

#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~magnetos_cmd[0], 1), 
#			props.globals.getNode(magnetos_cmd[0]), 
#			props.globals.getNode(magnetos_cmd[0]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~magnetos_cmd[1], 1), 
#			props.globals.getNode(magnetos_cmd[1]), 
#			props.globals.getNode(magnetos_cmd[1]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~fuel_cmd[0], 1), 
#			props.globals.getNode(fuel_cmd[0]), 
#			props.globals.getNode(fuel_cmd[0]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~fuel_cmd[1], 1), 
#			props.globals.getNode(fuel_cmd[1]), 
#			props.globals.getNode(fuel_cmd[1]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~cowl_flaps_cmd[0], 1), 
#			props.globals.getNode(cowl_flaps_cmd[0]), 
#			props.globals.getNode(cowl_flaps_cmd[0]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~cowl_flaps_cmd[1], 1), 
#			props.globals.getNode(cowl_flaps_cmd[1]), 
#			props.globals.getNode(cowl_flaps_cmd[1]), 
#			0.1
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~instrument_lights, 1), 
#			props.globals.getNode(instrument_lights), 
#			props.globals.getNode(instrument_lights), 
#			0.001
#		),
#		DCT.MostRecentSelector.new(
#			props.globals.getNode("dual-control/pilot/"~flaps_cmd, 1), 
#			props.globals.getNode(flaps_cmd), props.globals.getNode(flaps_cmd), 
#			0.1
#		),
#
	];
}

var engineer_disconnect_pilot = func {
	setprop(l_dual_control, 0);
	VHF22.make_master(0);
}
