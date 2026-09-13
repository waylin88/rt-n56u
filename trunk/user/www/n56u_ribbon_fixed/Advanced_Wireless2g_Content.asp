<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - 2.4G <#menu5_1_1#></title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/wireless_2g.js"></script>
<script type="text/javascript" src="/help_wl.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/md5.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	init_itoggle('rt_radio_x');
	init_itoggle('rt_closed');
});

</script>
<script>

function initial(){
	show_banner(1);
	show_menu(5,1,1);
	show_footer();

	if (!support_2g_11ax()){
		var o1 = document.form.rt_gmode;
		o1.remove(0);
	}

	document.form.rt_ssid.value = decodeURIComponent(document.form.rt_ssid2.value);
	document.form.rt_wpa_psk.value = decodeURIComponent(document.form.rt_wpa_psk_org.value);

	if(document.form.rt_wpa_psk.value.length < 1)
		document.form.rt_wpa_psk.value = "Please type Password";

	insertChannelOption();
	rt_auth_mode_change(1);

	document.form.rt_channel.value = document.form.rt_channel_orig.value;

	load_body();
}

function applyRule(){
	var auth_mode = document.form.rt_auth_mode.value;

	if(document.form.rt_wpa_psk.value == "Please type Password")
		document.form.rt_wpa_psk.value = "";

	if(validForm()){
		showLoading();

		document.form.action_mode.value = " Apply ";
		document.form.current_page.value = "/Advanced_Wireless2g_Content.asp";
		document.form.next_page.value = "";

		inputCtrl(document.form.rt_crypto, 1);
		inputCtrl(document.form.rt_wpa_psk, 1);

		document.form.submit();
	}
}

function validForm(){
	var auth_mode = document.form.rt_auth_mode.value;

	if(!validate_string_ssid(document.form.rt_ssid))
		return false;

	if(document.form.rt_ssid.value == "")
		document.form.rt_ssid.value = "ASUS";

	if(auth_mode == "psk"){
		if(!validate_psk(document.form.rt_wpa_psk))
			return false;
	}

	return true;
}

function done_validating(action){
	refreshpage();
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

    <iframe name="hidden_frame" id="hidden_frame" width="0" height="0" frameborder="0"></iframe>
    <form method="post" name="form" action="/start_apply.htm" target="hidden_frame">

    <input type="hidden" name="current_page" value="Advanced_Wireless2g_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="WLANConfig11b;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <input type="hidden" name="rt_radio_date_x" value="<% nvram_get_x("","rt_radio_date_x"); %>">
    <input type="hidden" name="rt_radio_time_x" value="<% nvram_get_x("","rt_radio_time_x"); %>">
    <input type="hidden" name="rt_radio_time2_x" value="<% nvram_get_x("","rt_radio_time2_x"); %>">
    <input type="hidden" name="rt_ssid2" value="<% nvram_char_to_ascii("",  "rt_ssid"); %>">
    <input type="hidden" name="rt_wpa_mode" value="<% nvram_get_x("","rt_wpa_mode"); %>">
    <input type="hidden" name="rt_wpa_psk_org" value="<% nvram_char_to_ascii("", "rt_wpa_psk"); %>">
    <input type="hidden" name="rt_wpa_gtk_rekey" value="<% nvram_get_x("", "rt_wpa_gtk_rekey"); %>">
    <input type="hidden" name="rt_wep_x" value="0">
    <input type="hidden" name="rt_key" value="2">
    <input type="hidden" name="rt_key_type" value='<% nvram_get_x("","rt_key_type"); %>'>
    <input type="hidden" name="rt_mode_x" value="<% nvram_get_x("","rt_mode_x"); %>">
    <input type="hidden" name="rt_nmode" value="<% nvram_get_x("","rt_nmode"); %>">
    <input type="hidden" name="rt_country_code" value="<% nvram_get_x("","rt_country_code"); %>">
    <input type="hidden" name="rt_channel_orig" value='<% nvram_get_x("","rt_channel"); %>'>
    <input type="hidden" name="rt_HT_EXTCHA_old" value="<% nvram_get_x("","rt_HT_EXTCHA"); %>">
    <input type="hidden" name="rt_gmode_protection" value="<% nvram_get_x("", "rt_gmode_protection"); %>">

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
                            <h2 class="box_head round_top"><#menu5_1#> - <#menu5_1_1#> (2.4GHz)</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th width="50%" style="border-top: 0 none;"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 22);"><#WLANConfig11b_x_RadioEnable_itemname#></a></th>
                                            <td style="border-top: 0 none;">
                                                <div class="main_itoggle">
                                                    <div id="rt_radio_x_on_of">
                                                        <input type="checkbox" id="rt_radio_x_fake" <% nvram_match_x("","rt_radio_x", "1", "value=1 checked"); %><% nvram_match_x("","rt_radio_x", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" id="rt_radio_x_1" name="rt_radio_x" class="input" <% nvram_match_x("","rt_radio_x", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" value="0" id="rt_radio_x_0" name="rt_radio_x" class="input" <% nvram_match_x("","rt_radio_x", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><a class="help_tooltip" href="javascript: void(0)" onmouseover="openTooltip(this, 0, 1);"><#WLANConfig11b_SSID_itemname#></a></th>
                                            <td><input type="text" maxlength="32" class="input" size="32" name="rt_ssid" value="" onkeypress="return is_string(this,event);"></td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 2);"><#WLANConfig11b_x_BlockBCSSID_itemname#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="rt_closed_on_of">
                                                        <input type="checkbox" id="rt_closed_fake" <% nvram_match_x("", "rt_closed", "1", "value=1 checked"); %><% nvram_match_x("", "rt_closed", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" id="rt_closed_1" name="rt_closed" <% nvram_match_x("", "rt_closed", "1", "checked"); %>><#checkbox_Yes#>
                                                    <input type="radio" value="0" id="rt_closed_0" name="rt_closed" <% nvram_match_x("", "rt_closed", "0", "checked"); %>><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 4);"><#WLANConfig11b_x_Mode11g_itemname#></a></th>
                                            <td>
                                                <select name="rt_gmode" class="input" onChange="return change_common_rt(this, 'WLANConfig11b', 'rt_gmode')">
                                                    <option value="6" <% nvram_match_x("","rt_gmode", "6","selected"); %>>b/g/n/ax Mixed</option>
                                                    <option value="2" <% nvram_match_x("","rt_gmode", "2","selected"); %>>b/g/n Mixed</option>
                                                    <option value="1" <% nvram_match_x("","rt_gmode", "1","selected"); %>>b/g Mixed</option>
                                                    <option value="5" <% nvram_match_x("","rt_gmode", "5","selected"); %>>g/n Mixed (*)</option>
                                                    <option value="3" <% nvram_match_x("","rt_gmode", "3","selected"); %>>n Only</option>
                                                    <option value="4" <% nvram_match_x("","rt_gmode", "4","selected"); %>>g Only</option>
                                                    <option value="0" <% nvram_match_x("","rt_gmode", "0","selected"); %>>b Only</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_HT_BW">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 14);"><#WLANConfig11b_ChannelBW_itemname#></a></th>
                                            <td>
                                                <select name="rt_HT_BW" class="input" onChange="return change_common_rt(this, 'WLANConfig11b', 'rt_HT_BW')">
                                                    <option value="0" <% nvram_match_x("","rt_HT_BW", "0","selected"); %>>20 MHz</option>
                                                    <option value="1" <% nvram_match_x("","rt_HT_BW", "1","selected"); %>>20/40 MHz</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 3);"><#WLANConfig11b_Channel_itemname#></a></th>
                                            <td>
                                                <select name="rt_channel" class="input" onChange="return change_common_rt(this, 'WLANConfig11b', 'rt_channel')">
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 5);"><#WLANConfig11b_AuthenticationMethod_itemname#></a></th>
                                            <td>
                                                <select name="rt_auth_mode" class="input" onChange="return change_common_rt(this, 'WLANConfig11b', 'rt_auth_mode');">
                                                    <option value="open" <% nvram_match_x("", "rt_auth_mode", "open", "selected"); %>>Open System</option>
                                                    <option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "1", "selected"); %>>WPA-Personal</option>
                                                    <option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "2", "selected"); %>>WPA2-Personal</option>
                                                    <option value="psk" <% nvram_double_match_x("", "rt_auth_mode", "psk", "", "rt_wpa_mode", "0", "selected"); %>>WPA-Auto-Personal</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_wpa1">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 6);"><#WLANConfig11b_WPAType_itemname#></a></th>
                                            <td>
                                                <select name="rt_crypto" class="input" onChange="return change_common_rt(this, 'WLANConfig11b', 'rt_crypto')">
                                                    <option value="aes" <% nvram_match_x("", "rt_crypto", "aes", "selected"); %>>AES</option>
                                                    <option value="tkip+aes" <% nvram_match_x("", "rt_crypto", "tkip+aes", "selected"); %>>TKIP+AES</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_wpa2">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 7);"><#WLANConfig11b_x_PSKKey_itemname#></a></th>
                                            <td>
                                                <div class="input-append">
                                                    <input type="password" name="rt_wpa_psk" id="rt_wpa_psk" maxlength="64" size="32" value="" style="width: 175px;">
                                                    <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('rt_wpa_psk')"><i class="icon-eye-close"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td style="border-top: 0 none; text-align: center;">
                                                <input type="button" id="applyButton" class="btn btn-primary" style="width: 219px" value="<#CTL_apply#>" onclick="applyRule();">
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
