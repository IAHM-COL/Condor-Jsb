var login_listener=nil;
var track_listener=nil;

var login=func() {
	if (getprop("skynet/login-pending")) {
		var httpstring="http://www.TheJabberwocky.net/SkyNet.php?usr="~getprop("skynet/username")~"&pwd="~getprop("skynet/password");
		var params1=props.Node.new({
			"url"		:	httpstring,
			"targetnode"	:	"/skynet/response",
			"complete"	:	"/skynet/response/complete"
		});
		fgcommand("xmlhttprequest", params1);
		removelistener(login_listener);
		login_listener=setlistener("skynet/response/complete", login_cb);
	}
}

var logout=func() {
	setprop("skynet/session", "null");
	setMenus();
	login_listener=setlistener("skynet/login-pending", login);
}

var tracker=func() {
	if (getprop("skynet/response/login")=="confirmed") {
print("tracker 1");
		var sess=getprop("skynet/session") or "";
		var cmd="SETPOSITION" or "";
		var lat=getprop("position/latitude-deg") or "";
		var lon=getprop("position/longitude-deg") or "";
		var alt=getprop("position/altitude-ft") or 0;
		var hdg=getprop("orientation/heading-deg") or 0;
		var httpstring="http://www.TheJabberwocky.net/SkyNet.php?sess="~sess~"&cmd="~cmd~"&lat="~lat~"&lon="~lon~"&alt="~alt~"&hdg="~hdg;
		var params1=props.Node.new({
			"url"		:	httpstring,
			"targetnode"	:	"/skynet/response",
			"complete"	:	"/skynet/response/complete"
		});
		setprop("skynet/response/complete", 'false');
		fgcommand("xmlhttprequest", params1);
		track_listener=setlistener("skynet/response/complete", tracker_cb);
	}
}

var login_cb=func() {
	if (getprop("skynet/login-pending")) {
		var loginvalid=getprop("skynet/response/login");
		if (streq(loginvalid, "confirmed")) {
			var session=getprop("skynet/response/session");
			setprop("skynet/session", getprop("skynet/response/session"));

			var sess=getprop("skynet/session") or "";
			var callsign=getprop("skynet/callsign") or "";
			var cmd="SETCALLSIGN" or "";
			var httpstring="http://www.TheJabberwocky.net/SkyNet.php?sess="~sess~"&cmd="~cmd~"&callsign="~callsign;
			var params2=props.Node.new({
				"url"		:	httpstring,
				"targetnode"	:	"/skynet/response"
			});
			fgcommand("xmlhttprequest", params2);
			track_listener=setlistener("skynet/response/complete", tracker_cb);
			setprop("skynet/login-pending", 'false');
			if (login_listener != nil) {
				removelistener(login_listener);
				login_listener=nil;
				setMenus();
			}		
		} else {
			gui.popupTip("Login failed!");
			setprop("skynet/session", "null");
			setMenus();
			login_listener=setlistener("skynet/login-pending", login);
		}
	}
}

var tracker_cb=func() {
	if (getprop("skynet/response/login")=="confirmed") {
		if (getprop("skynet/response/complete")) {
print("tracker 2 session=", getprop("skynet/session"));
			if (!streq(getprop("skynet/session"), "null")) {
				settimer(tracker, 5);
			}
			if (track_listener != nil) {
				removelistener(track_listener);
				track_listener=nil;
			}
		}
	}
}

var setMenus=func() {
	var session=getprop("skynet/session");
print("session=", session);
print(streq(session, "null"));
	if (streq(session, "null")) {
		setprop("sim/menubar/default/menu[11]/item[0]/enabled", 'true');
		setprop("sim/menubar/default/menu[11]/item[1]/enabled", 'false');
	} else {
		setprop("sim/menubar/default/menu[11]/item[0]/enabled", 'false');
		setprop("sim/menubar/default/menu[11]/item[1]/enabled", 'true');
	}
}

login_listener=setlistener("skynet/login-pending", login);

