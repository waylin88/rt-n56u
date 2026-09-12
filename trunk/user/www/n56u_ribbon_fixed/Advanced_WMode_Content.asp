<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_1_3#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/wireless.js"></script>
<script type="text/javascript" src="/help_wl.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script>
var $j = jQuery.noConflict();

var wds_aplist = [["", "", ""]];

function initial(){
	show_banner(1);
	show_menu(5,2,3);
	show_footer();
	load_body();

	if (typeof(support_5g_wid) === 'function'){
		wid = support_5g_wid();
		if (wid==7915){
			document.form.wl_mode_x.remove(1);
			document.form.wl_mode_x.remove(1);
		}
	}

	change_wireless_bridge();
	change_sta_auth_mode(0);

	document.form.wl_channel.value = document.form.wl_channel_org.value;
	document.form.wl_sta_ssid.value = decodeURIComponent(document.form.wl_sta_ssid_org.value);
	document.form.wl_sta_wpa_psk.value = decodeURIComponent(document.form.wl_sta_wpa_psk_org.value);

	wds_scan();
}

function applyRule(){
	var m = document.form.wl_mode_x.value;
	if (validForm()){
		showLoading();
		if (m == "3" || m == "4")
			document.form.action_mode.value = " Restart ";
		else
			document.form.action_mode.value = " Apply ";
		document.form.current_page.value = "/Advanced_WMode_Content.asp";
		document.form.next_page.value = "";
		document.form.submit();
	}
}

function validForm(){
	var m = document.form.wl_mode_x.value;
	if (m == "3" || m == "4") {
		if(!validate_string_ssid(document.form.wl_sta_ssid))
			return false;
		if(document.form.wl_sta_ssid.value == "") {
			document.form.wl_sta_ssid.focus();
			return false;
		}
		if(document.form.wl_sta_auth_mode.value == "psk"){
			if(!validate_psk(document.form.wl_sta_wpa_psk))
				return false;
		}
	}
	return true;
}

function done_validating(action){
	refreshpage();
}

function wds_scan(){
	$j.ajax({
		url: '/wds_aplist.asp',
		dataType: 'script',
		error: function(xhr){
			setTimeout("wds_scan();", 1000);
		},
		success: function(response){
			showLANIPList();
		}
	});
}

function change_wireless_bridge(){
	var m = document.form.wl_mode_x.value;
	var is_apc = (m == "3" || m == "4") ? 1 : 0;
	var is_apc_wisp = 0;

	if (is_apc){
		is_apc_auto = 1;
		if (!get_ap_mode())
			is_apc_wisp = 1;
	}

	showhide_div("inf_wisp", is_apc_wisp);
	showhide_div("inf_apc", is_apc);

	showhide_div("row_apc_wisp", is_apc_wisp);
	showhide_div("row_apc_ssid", is_apc);
	showhide_div("row_apc_1", is_apc);
	showhide_div("row_apc_2", is_apc && document.form.wl_sta_auth_mode.value == "psk");
	showhide_div("row_apc_3", is_apc && document.form.wl_sta_auth_mode.value == "psk");
}

function change_sta_auth_mode(mflag){
	var mode = document.form.wl_sta_auth_mode.value;
	var opts = document.form.wl_sta_auth_mode.options;
	if(mode == "psk"){
		inputCtrl(document.form.wl_sta_crypto, 1);
		inputCtrl(document.form.wl_sta_wpa_psk, 1);
		showhide_div("row_apc_2", 1);
		showhide_div("row_apc_3", 1);
		if(opts[opts.selectedIndex].text == "WPA2-Personal"){
			if (mflag == 1){
				document.form.wl_sta_crypto.options[0].selected = 0;
				document.form.wl_sta_crypto.options[1].selected = 1;
				document.form.wl_sta_wpa_mode.value = "2";
			}
		}else{
			if (mflag == 1){
				document.form.wl_sta_crypto.options[1].selected = 0;
				document.form.wl_sta_crypto.options[0].selected = 1;
				document.form.wl_sta_wpa_mode.value = "1";
			}
		}
	}else{
		inputCtrl(document.form.wl_sta_crypto, 0);
		inputCtrl(document.form.wl_sta_wpa_psk, 0);
		showhide_div("row_apc_2", 0);
		showhide_div("row_apc_3", 0);
	}
}

function setClientIP(num){
	var mode = document.form.wl_mode_x.value;
	if (mode == "3" || mode == "4")
		document.form.wl_sta_ssid.value = wds_aplist[num][0];
	hideClients_Block();
}

function rescan(){
	wds_aplist = "";
	showLANIPList();
	wds_scan();
}

function showLANIPList(){
	var code = "";
	var show_name = "";

	if(wds_aplist != ""){
		for(var i = 0; i < wds_aplist.length ; i++){
			try {
				wds_aplist[i][0] = decodeURIComponent(wds_aplist[i][0]);
			} catch (e) {
				console.log("malformed utf-8 ssid:"+wds_aplist[i][0]);
			}
			if(wds_aplist[i][0] && wds_aplist[i][0].length > 16)
				show_name = wds_aplist[i][0].substring(0, 14) + "..";
			else
				show_name = wds_aplist[i][0];

			if(wds_aplist[i][1] && wds_aplist[i][1].length > 0){
				code += '<a href="javascript:void(0)"><div onclick="setClientIP('+i+');"><strong>'+show_name+'</strong>';
				code += ' ['+wds_aplist[i][1]+']';
				code += ', '+wds_aplist[i][3]+'%';
				code += ' </div></a>';
			}
		}
		code += '<div style="font-weight:bold;cursor:pointer;" onclick="rescan();"><#AP_survey#>&nbsp;</div>';
	}
	else{
		code += '<div style="width: 207px"><center><img style="padding-top: 4px; display: block;" src="/bootstrap/img/ajax-loader.gif"></center></div>';
	}

	code +='<!--[if lte IE 6.5]><iframe class="hackiframe_wdssurvey"></iframe><![endif]-->';
	document.getElementById("WDSAPList").innerHTML = code;
}

var isMenuopen = 0;

function pullLANIPList(obj){
	if(isMenuopen == 0){
		$j(obj).children('i').removeClass('icon-chevron-down').addClass('icon-chevron-up');
		document.getElementById("WDSAPList").style.display = 'block';
		document.form.wl_sta_ssid.focus();
		isMenuopen = 1;
	}
	else
		hideClients_Block();
}

function hideClients_Block(){
	$j("#ctl_wds_2").children('i').removeClass('icon-chevron-up').addClass('icon-chevron-down');
	document.getElementById('WDSAPList').style.display='none';
	isMenuopen = 0;
}
</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9" >
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>
    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
    <input type="hidden" name="current_page" value="Advanced_WMode_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="WLANConfig11a;">
    <input type="hidden" name="group_id" value="RBRList">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <input type="hidden" name="wl_country_code" value="<% nvram_get_x("", "wl_country_code"); %>">
    <input type="hidden" name="wl_channel_org" value="<% nvram_get_x("","wl_channel"); %>">
    <input type="hidden" name="wl_channel" value="<% nvram_get_x("","wl_channel"); %>">
    <input type="hidden" name="wl_sta_auto" value="<% nvram_get_x("", "wl_sta_auto"); %>" />
    <input type="hidden" name="wl_sta_ssid_org" value="<% nvram_char_to_ascii("", "wl_sta_ssid"); %>">
    <input type="hidden" name="wl_sta_wpa_mode" value="<% nvram_get_x("","wl_sta_wpa_mode"); %>">
    <input type="hidden" name="wl_sta_wpa_psk_org" value="<% nvram_char_to_ascii("", "wl_sta_wpa_psk"); %>">

    <div class="container-fluid">
        <div class="row-fluid">
            <div class="span3">
                <!--Sidebar content-->
                <!--=====Beginning of Main Menu=====-->
                <div class="well sidebar-nav side_nav" style="padding: 0px;">
                    <ul id="mainMenu" class="clearfix"></ul>
                    <ul class="clearfix">
                        <li>
                            <div id="subMenu" class="accordion"></div>
                        </li>
                    </ul>
                </div>
            </div>

            <div class="span9">
                <!--Body content-->
                <div class="row-fluid">
                    <div class="span12">
                        <div class="box well grad_colour_dark_blue">
                            <h2 class="box_head round_top"><#menu5_1#> - <#menu5_1_3#> (5GHz)</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;">
                                        <#WdsDesc0#>
                                        <ul id="inf_apc" style="display:none;">
                                            <li><#WdsDesc4#></li>
                                            <li><#WdsDesc5#></li>
                                            <li id="inf_wisp"><#WdsDesc6#></li>
                                        </ul>
                                    </div>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table" style="margin-bottom: 0px;">
                                        <tr>
                                            <th width="50%" style="border-top: 0 none;"><a class="help_tooltip" href="javascript:void(0);"  onmouseover="openTooltip(this, 1, 1);"><#WLANConfig11b_x_APMode_itemname#></a></th>
                                            <td style="border-top: 0 none;">
                                                <select name="wl_mode_x" class="input" onChange="change_wireless_bridge();">
                                                    <option value="0" <% nvram_match_x("","wl_mode_x", "0","selected"); %>><#WdsMode0#></option>
                                                    <option value="3" <% nvram_match_x("","wl_mode_x", "3","selected"); %>><#WdsMode3#></option>
                                                    <option value="4" <% nvram_match_x("","wl_mode_x", "4","selected"); %>><#WdsMode4#></option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_apc_wisp" style="display:none;">
                                            <th><#APCliRole#></th>
                                            <td>
                                                <select name="wl_sta_wisp" class="input">
                                                    <option value="0" <% nvram_match_x("","wl_sta_wisp", "0","selected"); %>>LAN bridge</option>
                                                    <option value="1" <% nvram_match_x("","wl_sta_wisp", "1","selected"); %>>WAN (Wireless ISP)</option>
                                                </select>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr id="row_apc_ssid" style="display:none;">
                                            <th width="50%"><a id="ctl_apc_1" class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 1);"><#APSTA_SSID#></a></th>
                                            <td>
                                                <div id="WDSAPList" class="alert alert-info ddown-list"></div>
                                                <div class="input-append" style="float: left;">
                                                    <input type="text" id="ctl_apc_2" name="wl_sta_ssid" value="" maxlength="32" class="input" size="20" onKeyPress="return is_string(this,event);" style="float:left; width: 175px;"/>
                                                    <button class="btn btn-chevron" id="ctl_wds_2" type="button" onclick="pullLANIPList(this);" title="Select the Access Point"><i class="icon icon-chevron-down"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="row_apc_1" style="display:none;">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 5);"><#WLANConfig11b_AuthenticationMethod_itemname#></a></th>
                                            <td>
                                                <select name="wl_sta_auth_mode" class="input" onChange="change_sta_auth_mode(1);">
                                                    <option value="open" <% nvram_match_x("", "wl_sta_auth_mode", "open", "selected"); %>>Open System</option>
                                                    <option value="psk" <% nvram_double_match_x("", "wl_sta_auth_mode", "psk", "", "wl_sta_wpa_mode", "1", "selected"); %>>WPA-Personal</option>
                                                    <option value="psk" <% nvram_double_match_x("", "wl_sta_auth_mode", "psk", "", "wl_sta_wpa_mode", "2", "selected"); %>>WPA2-Personal</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_apc_2" style="display:none;">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 6);"><#WLANConfig11b_WPAType_itemname#></a></th>
                                            <td>
                                                <select name="wl_sta_crypto" class="input">
                                                    <option value="tkip" <% nvram_match_x("", "wl_sta_crypto", "tkip", "selected"); %>>TKIP</option>
                                                    <option value="aes" <% nvram_match_x("", "wl_sta_crypto", "aes", "selected"); %>>AES</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_apc_3" style="display:none;">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 7);"><#WLANConfig11b_x_PSKKey_itemname#></a></th>
                                            <td>
                                                <div class="input-append">
                                                    <input type="password" name="wl_sta_wpa_psk" id="wl_sta_wpa_psk" maxlength="64" size="32" value="" style="width: 175px;">
                                                    <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('wl_sta_wpa_psk')"><i class="icon-eye-close"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td width="50%" style="margin-top: 10px; border-top: 0 none;">
                                                <input class="btn btn-info" type="button"  value="<#GO_2G#>" onclick="location.href='Advanced_WMode2g_Content.asp';">
                                            </td>
                                            <td style="border-top: 0 none;">
                                                <input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" />
                                            </td>
                                        </tr>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    </form>

    <div id="footer"></div>
</div>
</body>
</html>
