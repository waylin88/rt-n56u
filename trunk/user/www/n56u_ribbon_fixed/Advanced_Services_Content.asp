<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_6_5#></title>
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
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script>
var $j = jQuery.noConflict();

$j(document).ready(function() {
	init_itoggle('crond_enable', change_crond_enabled);
	init_itoggle('watchdog_cpu');
});

</script>
<script>

<% login_state_hook(); %>

function initial(){
	show_banner(1);
	show_menu(5,7,2);
	show_footer();
	load_body();

	change_crond_enabled();
}

function applyRule(){
	if(validForm()){
		showLoading();

		document.form.action_mode.value = " Apply ";
		document.form.current_page.value = "/Advanced_Services_Content.asp";
		document.form.next_page.value = "";

		document.form.submit();
	}
}

function validForm(){
	if(!validate_range(document.form.http_lanport, 80, 65535))
		return false;

	return true;
}

function done_validating(action){
	refreshpage();
}

function textarea_crond_enabled(v){
	inputCtrl(document.form['crontab.login'], v);
}

function change_crond_enabled(){
	var v = document.form.crond_enable[0].checked;
	showhide_div('row_crontabs', v);
	if (!login_safe())
		v = 0;
	textarea_crond_enabled(v);
}
</script>
<style>
    .caption-bold {
        font-weight: bold;
    }
</style>
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
    <input type="hidden" name="current_page" value="Advanced_Services_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="LANHostConfig;General;Storage;">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">

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
                            <h2 class="box_head round_top"><#menu5_6#> - <#menu5_6_5#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;"><#Adm_Svc_desc#></div>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#Adm_System_webs#></th>
                                        </tr>
                                        <tr id="row_http_lport">
                                            <th><#Adm_System_http_lport#></th>
                                            <td>
                                                <input type="text" maxlength="5" size="15" name="http_lanport" class="input" value="<% nvram_get_x("", "http_lanport"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[80..65535]</span>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#Adm_System_http_access#></th>
                                            <td>
                                                <select name="http_access" class="input">
                                                    <option value="0" <% nvram_match_x("", "http_access", "0","selected"); %>><#checkbox_No#> (*)</option>
                                                    <option value="1" <% nvram_match_x("", "http_access", "1","selected"); %>>Wired clients only</option>
                                                    <option value="2" <% nvram_match_x("", "http_access", "2","selected"); %>>Wired and MainAP clients</option>
                                                </select>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#Adm_System_misc#></th>
                                        </tr>
                                        <tr>
                                            <th><#Adm_Svc_crond#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="crond_enable_on_of">
                                                        <input type="checkbox" id="crond_enable_fake" <% nvram_match_x("", "crond_enable", "1", "value=1 checked"); %><% nvram_match_x("", "crond_enable", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="crond_enable" id="crond_enable_1" class="input" value="1" <% nvram_match_x("", "crond_enable", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" name="crond_enable" id="crond_enable_0" class="input" value="0" <% nvram_match_x("", "crond_enable", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="row_crontabs" style="display:none">
                                            <td colspan="2">
                                                <a href="javascript:spoiler_toggle('crond_crontabs')"><span><#Adm_Svc_crontabs#></span></a>
                                                <div id="crond_crontabs" style="display:none;">
                                                    <textarea rows="8" wrap="off" spellcheck="false" maxlength="8192" class="span12" name="crontab.login" style="font-family:'Courier New'; font-size:12px;"><% nvram_dump("crontab.login",""); %></textarea>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,23,1);"><#TweaksWdg#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="watchdog_cpu_on_of">
                                                        <input type="checkbox" id="watchdog_cpu_fake" <% nvram_match_x("", "watchdog_cpu", "1", "value=1 checked"); %><% nvram_match_x("", "watchdog_cpu", "0", "value=0"); %>>
                                                    </div>
                                                </div>
                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="watchdog_cpu" id="watchdog_cpu_1" class="input" value="1" <% nvram_match_x("", "watchdog_cpu", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" name="watchdog_cpu" id="watchdog_cpu_0" class="input" value="0" <% nvram_match_x("", "watchdog_cpu", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td style="border: 0 none;">
                                                <center><input class="btn btn-primary" style="width: 219px" onclick="applyRule();" type="button" value="<#CTL_apply#>" /></center>
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
