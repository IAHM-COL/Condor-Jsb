var checkFuel=func() {
	var amount=0.00;
	var target=0.00;
	var pctin=0.00;
	var pctout=0.00;

	# carburator tank 6 is on engine 0, left outboard #####################################################################
	target=getprop("/consumables/fuel/tank[6]/level-lbs");
	if (target<24.5) {
		amount=25-target;
		if (getprop("/consumables/fuel/tank[0]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[0]/level-lbs");
		}
		setprop("/consumables/fuel/tank[0]/level-lbs",getprop("/consumables/fuel/tank[0]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[6]/level-lbs",getprop("/consumables/fuel/tank[6]/level-lbs")+amount);
	}

	# carburator tank 7 is on engine 1, left inboard ######################################################################
	target=getprop("/consumables/fuel/tank[7]/level-lbs");
	if (target<24.5) {
		amount=25-target;
		if (getprop("/consumables/fuel/tank[0]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[0]/level-lbs");
		}
		setprop("/consumables/fuel/tank[0]/level-lbs",getprop("/consumables/fuel/tank[0]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[7]/level-lbs",getprop("/consumables/fuel/tank[7]/level-lbs")+amount);
	}

	# carburator tank 8 is on engine 2, right inboard #####################################################################
	target=getprop("/consumables/fuel/tank[8]/level-lbs");
	if (target<24.5) {
		amount=25-target;
		if (getprop("/consumables/fuel/tank[1]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[1]/level-lbs");
		}
		setprop("/consumables/fuel/tank[1]/level-lbs",getprop("/consumables/fuel/tank[1]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[8]/level-lbs",getprop("/consumables/fuel/tank[8]/level-lbs")+amount);
	}

	# carburator tank 9 is on engine 3, right outboard ####################################################################
	target=getprop("/consumables/fuel/tank[9]/level-lbs");
	if (target<24.5) {
		amount=25-target;
		if (getprop("/consumables/fuel/tank[1]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[1]/level-lbs");
		}
		setprop("/consumables/fuel/tank[1]/level-lbs",getprop("/consumables/fuel/tank[1]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[9]/level-lbs",getprop("/consumables/fuel/tank[9]/level-lbs")+amount);
	}

	# Now tank 2 into tank 0, left side intermediate to main tank ##########################################################
	target=getprop("/consumables/fuel/tank[0]/level-lbs");
	if (target<4200) {
		amount=4218-target;
		if (getprop("/consumables/fuel/tank[2]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[2]/level-lbs");
		}
		setprop("/consumables/fuel/tank[2]/level-lbs",getprop("/consumables/fuel/tank[2]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[0]/level-lbs",getprop("/consumables/fuel/tank[0]/level-lbs")+amount);
	}

	# Now tank 3 into tank 1, right side intermediate to main tank #########################################################
	target=getprop("/consumables/fuel/tank[1]/level-lbs");
	if (target<4200) {
		amount=4218-target;
		if (getprop("/consumables/fuel/tank[3]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[3]/level-lbs");
		}
		setprop("/consumables/fuel/tank[3]/level-lbs",getprop("/consumables/fuel/tank[3]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[1]/level-lbs",getprop("/consumables/fuel/tank[1]/level-lbs")+amount);
	}

	# Now tank 4 into tank 2, left side reserve to intermediate tank #######################################################
	target=getprop("/consumables/fuel/tank[2]/level-lbs");
	if (target<2770) {
		amount=2784-target;
		if (getprop("/consumables/fuel/tank[4]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[4]/level-lbs");
		}
		setprop("/consumables/fuel/tank[4]/level-lbs",getprop("/consumables/fuel/tank[4]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[2]/level-lbs",getprop("/consumables/fuel/tank[2]/level-lbs")+amount);
	}

	# Now tank 5 into tank 3, right side reserve to intermediate tank ######################################################
	target=getprop("/consumables/fuel/tank[3]/level-lbs");
	if (target<2770) {
		amount=2784-target;
		if (getprop("/consumables/fuel/tank[5]/level-lbs")<amount) {
			amount=getprop("/consumables/fuel/tank[5]/level-lbs");
		}
		setprop("/consumables/fuel/tank[5]/level-lbs",getprop("/consumables/fuel/tank[5]/level-lbs")-amount);
		setprop("/consumables/fuel/tank[3]/level-lbs",getprop("/consumables/fuel/tank[3]/level-lbs")+amount);
	}

	settimer (checkFuel, 1);
}

settimer (checkFuel, 1);

