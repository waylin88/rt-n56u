<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - 5G <#menu5_1_1#></title>
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
<script type="text/javascript" src="/wireless.js"></script>
<script type="text/javascript" src="/help_wl.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/md5.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	init_itoggle('wl_radio_x');
	init_itoggle('wl_closed');
});

</script>
<script>

function initial(){
	show_banner(1);
	show_menu(5,2,1);
	show_footer();

	var o1 = document.form.wl_gmode;

	if (!support_5g_11ax()){
		o1.remove(0);
	}

	if (!support_5g_11ac()){
		o1.remove(0);
		o1.remove(0);
		o1.options[0].text = "a/n Mixed (*)";
		insert_vht_bw(0);
	}

	if (!support_5g_160mhz()){
		document.form.wl_HT_BW.remove(3);
	}

	document.form.wl_ssid.value = decodeURIComponent(document.form.wl_ssid2.value);
	document.form.wl_wpa_psk.value = decodeURIComponent(document.form.wl_wpa_psk_org.value);

	if(document.form.wl_wpa_psk.value.length < 1)
		document.form.wl_wpa_psk.value = "Please type Password";

	insertChannelOption();
	wl_auth_mode_change(1);

	document.form.wl_channel.value = document.form.wl_channel_orig.value;

	load_body();
}

function applyRule(){
	var auth_mode = document.form.wl_auth_mode.value;

	if(document.form.wl_wpa_psk.value == "Please type Password")
		document.form.wl_wpa_psk.value = "";

	if(validForm()){
		showLoading();

		document.form.action_mode.value = " Apply ";
		document.form.current_page.value = "/Advanced_Wireless_Content.asp";
		document.form.next_page.value = "";

		inputCtrl(document.form.wl_crypto, 1);
		inputCtrl(document.form.wl_wpa_psk, 1);

		document.form.submit();
	}
}

function validForm(){
	var auth_mode = document.form.wl_auth_mode.value;

	if(!validate_string_ssid(document.form.wl_ssid))
		return false;

	if(document.form.wl_ssid.value == "")
		document.form.wl_ssid.value = "ASUS_5G";

	if(auth_mode == "psk"){
		if(!validate_psk(document.form.wl_wpa_psk))
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

    <input type="hidden" name="current_page" value="Advanced_Wireless_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="WLANConfig11a;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

    <input type="hidden" name="wl_radio_date_x" value="<% nvram_get_x("","wl_radio_date_x"); %>">
    <input type="hidden" name="wl_radio_time_x" value="<% nvram_get_x("","wl_radio_time_x"); %>">
    <input type="hidden" name="wl_radio_time2_x" value="<% nvram_get_x("","wl_radio_time2_x"); %>">
    <input type="hidden" name="wl_ssid2" value="<% nvram_char_to_ascii("",  "wl_ssid"); %>">
    <input type="hidden" name="wl_wpa_mode" value="<% nvram_get_x("","wl_wpa_mode"); %>">
    <input type="hidden" name="wl_wpa_psk_org" value="<% nvram_char_to_ascii("", "wl_wpa_psk"); %>">
    <input type="hidden" name="wl_wpa_gtk_rekey" value="<% nvram_get_x("", "wl_wpa_gtk_rekey"); %>">
    <input type="hidden" name="wl_wep_x" value="0">
    <input type="hidden" name="wl_key" value="2">
    <input type="hidden" name="wl_key_type" value='<% nvram_get_x("","wl_key_type"); %>'>
    <input type="hidden" name="wl_mode_x" value="<% nvram_get_x("","wl_mode_x"); %>">
    <input type="hidden" name="wl_nmode" value="<% nvram_get_x("","wl_nmode"); %>">
    <input type="hidden" name="wl_country_code" value="<% nvram_get_x("", "wl_country_code"); %>">
    <input type="hidden" name="wl_channel_orig" value='<% nvram_get_x("","wl_channel"); %>'>
    <input type="hidden" name="wl_HT_EXTCHA_old" value="<% nvram_get_x("","wl_HT_EXTCHA"); %>">
    <input type="hidden" name="wl_gmode_protection" value="<% nvram_get_x("", "wl_gmode_protection"); %>">

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
                            <h2 class="box_head round_top"><#menu5_1#> - <#menu5_1_1#> (5GHz)</h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th width="50%" style="border-top: 0 none;"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 22);"><#WLANConfig11b_x_RadioEnable_itemname#></a></th>
                                            <td style="border-top: 0 none;">
                                                <div class="main_itoggle">
                                                    <div id="wl_radio_x_on_of">
                                                        <input type="checkbox" id="wl_radio_x_fake" <% nvram_match_x("","wl_radio_x", "1", "value=1 checked"); %><% nvram_match_x("","wl_radio_x", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="wl_radio_x" id="wl_radio_x_1" value="1" <% nvram_match_x("","wl_radio_x", "1", "checked"); %> /><#checkbox_Yes#>
                                                    <input type="radio" name="wl_radio_x" id="wl_radio_x_0" value="0" <% nvram_match_x("","wl_radio_x", "0", "checked"); %> /><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><a class="help_tooltip" href="javascript: void(0)" onmouseover="openTooltip(this, 0, 1);"><#WLANConfig11b_SSID_itemname#></a></th>
                                            <td><input type="text" maxlength="32" class="input" size="32" name="wl_ssid" value="" onkeypress="return is_string(this,event);"></td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 2);"><#WLANConfig11b_x_BlockBCSSID_itemname#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="wl_closed_on_of">
                                                        <input type="checkbox" id="wl_closed_fake" <% nvram_match_x("", "wl_closed", "1", "value=1 checked"); %><% nvram_match_x("", "wl_closed", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" value="1" id="wl_closed_1" name="wl_closed" <% nvram_match_x("", "wl_closed", "1", "checked"); %> /><#checkbox_Yes#>
                                                    <input type="radio" value="0" id="wl_closed_0" name="wl_closed" <% nvram_match_x("", "wl_closed", "0", "checked"); %> /><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 4);"><#WLANConfig11b_x_Mode11g_itemname#></a></th>
                                            <td>
                                                <select name="wl_gmode" class="input" onChange="return change_common_wl(this, 'WLANConfig11a', 'wl_gmode')">
                                                    <option value="5" <% nvram_match_x("","wl_gmode", "5","selected"); %>>a/n/ac/ax Mixed</option>
                                                    <option value="4" <% nvram_match_x("","wl_gmode", "4","selected"); %>>a/n/ac Mixed (*)</option>
                                                    <option value="3" <% nvram_match_x("","wl_gmode", "3","selected"); %>>n/ac Mixed</option>
                                                    <option value="2" <% nvram_match_x("","wl_gmode", "2","selected"); %>>a/n Mixed</option>
                                                    <option value="1" <% nvram_match_x("","wl_gmode", "1","selected"); %>>n Only</option>
                                                    <option value="0" <% nvram_match_x("","wl_gmode", "0","selected"); %>>a Only</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_HT_BW">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 14);"><#WLANConfig11b_ChannelBW_itemname#></a></th>
                                            <td>
                                                <select name="wl_HT_BW" class="input" onChange="return change_common_wl(this, 'WLANConfig11a', 'wl_HT_BW')">
                                                    <option value="0" <% nvram_match_x("","wl_HT_BW", "0","selected"); %>>20 MHz</option>
                                                    <option value="1" <% nvram_match_x("","wl_HT_BW", "1","selected"); %>>20/40 MHz</option>
                                                    <option value="2" <% nvram_match_x("","wl_HT_BW", "2","selected"); %>>20/40/80 MHz</option>
                                                    <option value="3" <% nvram_match_x("","wl_HT_BW", "3","selected"); %>>20/40/80/160 MHz</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 3);"><#WLANConfig11b_Channel_itemname#></a></th>
                                            <td>
                                                <select name="wl_channel" class="input" onChange="return change_common_wl(this, 'WLANConfig11a', 'wl_channel')">
                                                </select>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 5);"><#WLANConfig11b_AuthenticationMethod_itemname#></a></th>
                                            <td>
                                                <select name="wl_auth_mode" class="input" onChange="return change_common_wl(this, 'WLANConfig11a', 'wl_auth_mode');">
                                                    <option value="open" <% nvram_match_x("", "wl_auth_mode", "open", "selected"); %>>Open System</option>
                                                    <option value="psk" <% nvram_double_match_x("", "wl_auth_mode", "psk", "", "wl_wpa_mode", "1", "selected"); %>>WPA-Personal</option>
                                                    <option value="psk" <% nvram_double_match_x("", "wl_auth_mode", "psk", "", "wl_wpa_mode", "2", "selected"); %>>WPA2-Personal</option>
                                                    <option value="psk" <% nvram_double_match_x("", "wl_auth_mode", "psk", "", "wl_wpa_mode", "0", "selected"); %>>WPA-Auto-Personal</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_wpa1">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 6);"><#WLANConfig11b_WPAType_itemname#></a></th>
                                            <td>
                                                <select name="wl_crypto" class="input" onChange="return change_common_wl(this, 'WLANConfig11a', 'wl_crypto')">
                                                    <option value="aes" <% nvram_match_x("", "wl_crypto", "aes", "selected"); %>>AES</option>
                                                    <option value="tkip+aes" <% nvram_match_x("", "wl_crypto", "tkip+aes", "selected"); %>>TKIP+AES</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_wpa2">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this, 0, 7);"><#WLANConfig11b_x_PSKKey_itemname#></a></th>
                                            <td>
                                                <div class="input-append">
                                                    <input type="password" name="wl_wpa_psk" id="wl_wpa_psk" maxlength="64" size="32" value="" style="width: 175px;">
                                                    <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('wl_wpa_psk')"><i class="icon-eye-close"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td width="50%" style="margin-top: 10px; border-top: 0 none;">
                                                <input type="button" class="btn btn-info" value="<#GO_2G#>" onclick="location.href='Advanced_Wireless2g_Content.asp';">
                                            </td>
                                            <td style="border-top: 0 none;">
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
