<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - <#menu5_3_1#></title>
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
	init_itoggle('gw_arp_ping');
	init_itoggle('x_DHCPClient', change_wan_dhcp_auto);
	init_itoggle('wan_dnsenable_x', change_wan_dns_auto);
});

</script>
<script>

<% login_state_hook(); %>

var client_mac = login_mac_str();

var original_wan_type = wan_proto;
var original_wan_dhcp_auto = parseInt('<% nvram_get_x("", "x_DHCPClient"); %>');
var original_wan_dns_auto = parseInt('<% nvram_get_x("", "wan_dnsenable_x"); %>');
var original_wan_src_phy = '<% nvram_get_x("", "wan_src_phy"); %>';

function initial(){
	show_banner(1);
	show_menu(5,4,1);
	show_footer();

	if (!support_ipv4_ppe()){
		showhide_div('row_hwnat', 0);
	}

	if (support_sfe()){
		showhide_div('row_sfe', 1);
	}

	change_wan_type(document.form.wan_proto.value, 0);
	fixed_change_wan_type(document.form.wan_proto.value);
}

function applyRule(){
	if(validForm()){
		showLoading();
		
		document.form.next_page.value = "";
		document.form.action_mode.value = " Apply ";
		document.form.submit();
	}
}

function validForm(){
	var lan_addr = document.form.lan_ipaddr.value;
	var lan_mask = document.form.lan_netmask.value;
	var wan_proto = document.form.wan_proto.value;
	var addr_obj;
	var mask_obj;
	var gate_obj;

	if($("tbl_dhcp_sect").style.display != "none" && !document.form.x_DHCPClient[0].checked){
		addr_obj = document.form.wan_ipaddr;
		mask_obj = document.form.wan_netmask;
		gate_obj = document.form.wan_gateway;

		if(!validate_ipaddr_final(addr_obj, 'wan_ipaddr')
				|| !validate_ipaddr_final(mask_obj, 'wan_netmask')
				|| !validate_ipaddr_final(gate_obj, 'wan_gateway')
				)
			return false;

		if(gate_obj.value == addr_obj.value){
			alert("<#IPConnection_warning_WANIPEQUALGatewayIP#>");
			gate_obj.select();
			gate_obj.focus();
			return false;
		}

		if(matchSubnet2(lan_addr, lan_mask, addr_obj.value, mask_obj.value)){
			alert("<#JS_validsubnet#>");
			mask_obj.focus();
			mask_obj.select();
			return false;
		}

		if(!validate_range(document.form.wan_mtu, 1300, 1500))
			return false;
	}

	if(!document.form.wan_dnsenable_x[0].checked){
		if(!validate_ipaddr_final(document.form.wan_dns1_x, 'wan_dns_x'))
			return false;
		if(!validate_ipaddr_final(document.form.wan_dns2_x, 'wan_dns_x'))
			return false;
	}

	if(wan_proto == "pppoe"){
		if(!validate_string(document.form.wan_pppoe_username)
				|| !validate_string(document.form.wan_pppoe_passwd))
			return false;

		if(!validate_range(document.form.wan_pppoe_mtu, 1000, 1492)
				|| !validate_range(document.form.wan_pppoe_mru, 1000, 1492))
			return false;

		if(!validate_string(document.form.wan_pppoe_service))
			return false;
	}

	if(document.form.wan_hwaddr_x.value.length > 0)
		if(!validate_hwaddr(document.form.wan_hwaddr_x))
			return false;

	return true;
}

function done_validating(action){
	refreshpage();
}

function change_wan_type(wan_type, flag){
	change_wan_dhcp_enable(wan_type);
	change_wan_dns_enable(wan_type);

	var is_static = (wan_type == "static") ? 1 : 0;
	var is_pppoe = (wan_type == "pppoe") ? 1 : 0;
	var is_pptp = (wan_type == "pptp") ? 1 : 0;
	var is_l2tp = (wan_type == "l2tp") ? 1 : 0;
	var is_dhcp = !(is_static||is_pppoe||is_pptp||is_l2tp);
	var o_mtu, o_mru;

	if(is_pppoe){
		o_mtu = document.form.wan_pppoe_mtu;
		o_mru = document.form.wan_pppoe_mru;
		if (parseInt(o_mtu.value) > 1492)
			o_mtu.value = "1492";
		if (parseInt(o_mru.value) > 1492)
			o_mru.value = "1492";
	}else if(is_pptp){
		o_mtu = document.form.wan_pptp_mtu;
		o_mru = document.form.wan_pptp_mru;
		if (parseInt(o_mtu.value) > 1476)
			o_mtu.value = "1476";
		if (parseInt(o_mru.value) > 1500)
			o_mru.value = "1500";
	}else if(is_l2tp){
		o_mtu = document.form.wan_l2tp_mtu;
		o_mru = document.form.wan_l2tp_mru;
		if (parseInt(o_mtu.value) > 1460)
			o_mtu.value = "1460";
		if (parseInt(o_mru.value) > 1500)
			o_mru.value = "1500";
	}

	showhide_div("row_wan_poller", is_dhcp);
	showhide_div("row_pppoe_dhcp", is_pppoe);
	showhide_div("row_dhcp_toggle", is_pppoe||is_pptp||is_l2tp);
	showhide_div("row_dns_toggle", !is_static);
	showhide_div("tbl_vpn_control", is_pppoe||is_pptp||is_l2tp);

	if(is_pppoe||is_pptp||is_l2tp){
		$("dhcp_sect_desc").innerHTML = "<#WAN_MAN_desc#>";
		$("dhcp_auto_desc").innerHTML = "<#WAN_MAN_DHCP#>";

		var dhcp_sect = 1;
		if (is_pppoe && document.form.wan_pppoe_man.value != "1")
			dhcp_sect = 0;
		showhide_div("tbl_dhcp_sect", dhcp_sect);

		showhide_div("row_ppp_peer", is_pptp||is_l2tp);
		showhide_div("row_ppp_mppe", is_pptp||is_l2tp);
		showhide_div("row_pppoe_svc", is_pppoe);
		showhide_div("row_pppoe_it", is_pppoe);
		showhide_div("row_pppoe_ac", is_pppoe);
		showhide_div("row_pppoe_mtu", is_pppoe);
		showhide_div("row_pppoe_mru", is_pppoe);
		showhide_div("row_pptp_mtu", is_pptp);
		showhide_div("row_pptp_mru", is_pptp);
		showhide_div("row_l2tp_mtu", is_l2tp);
		showhide_div("row_l2tp_mru", is_l2tp);
		showhide_div("row_l2tp_cli", is_l2tp&&found_app_l2tp());
	}else{
		$("dhcp_sect_desc").innerHTML = "<#IPConnection_ExternalIPAddress_sectionname#>";
		$("dhcp_auto_desc").innerHTML = "<#Layer3Forwarding_x_DHCPClient_itemname#>";

		showhide_div("tbl_dhcp_sect", is_static);
	}
}

function fixed_change_wan_type(wan_type){
	var flag = false;

	if(!document.form.x_DHCPClient[0].checked){
		if(document.form.wan_ipaddr.value.length == 0)
			document.form.wan_ipaddr.focus();
		else if(document.form.wan_netmask.value.length == 0)
			document.form.wan_netmask.focus();
		else if(document.form.wan_gateway.value.length == 0)
			document.form.wan_gateway.focus();
		else
			flag = true;
	}
	else
		flag = true;

	change_wan_dns_enable(wan_type);

	if(wan_type == "static"){
		inputRCtrl2(document.form.wan_dnsenable_x, 1);
		$j('#wan_dnsenable_x_on_of').iState(0);
		
		set_wan_dns_auto(0);
		
		if(flag == true && document.form.wan_dns1_x.value.length == 0)
			document.form.wan_dns1_x.focus();
	}
	else{
		var dns_auto = original_wan_dns_auto;
		inputRCtrl2(document.form.wan_dnsenable_x, !dns_auto);
		$j('#wan_dnsenable_x_on_of').iState(dns_auto);
		
		set_wan_dns_auto(dns_auto);
		
		if(flag == true && document.form.wan_dns1_x.value.length == 0 && !document.form.wan_dnsenable_x[0].checked)
			document.form.wan_dns1_x.focus();
	}
}

function set_wan_dns_auto(use_auto){
	inputCtrl(document.form.wan_dns1_x, !use_auto);
	inputCtrl(document.form.wan_dns2_x, !use_auto);

	showhide_div("row_wan_dns1", !use_auto);
	showhide_div("row_wan_dns2", !use_auto);
}

function set_wan_dhcp_auto(use_auto){
	inputCtrl(document.form.wan_ipaddr, !use_auto);
	inputCtrl(document.form.wan_netmask, !use_auto);
	inputCtrl(document.form.wan_gateway, !use_auto);
	inputCtrl(document.form.wan_mtu, !use_auto);

	showhide_div("row_wan_ipaddr", !use_auto);
	showhide_div("row_wan_netmask", !use_auto);
	showhide_div("row_wan_gateway", !use_auto);
	showhide_div("row_wan_mtu", !use_auto);
}

function change_pppoe_man(man_type){
	if(document.form.wan_proto.value == "pppoe"){
		showhide_div("tbl_dhcp_sect", (man_type == "1")?1:0);
		set_wan_dhcp_auto(document.form.x_DHCPClient[0].checked);
	}
}

function change_wan_dhcp_auto(){
	var v = document.form.x_DHCPClient[0].checked;
	set_wan_dhcp_auto(v);
}

function change_wan_dns_auto(use_auto){
	var v = document.form.wan_dnsenable_x[0].checked;
	set_wan_dns_auto(v);
}

function change_wan_dhcp_enable(wan_type){
	if (wan_type == "pppoe" || wan_type == "pptp" || wan_type == "l2tp"){
		var dhcp_auto = original_wan_dhcp_auto;
		inputRCtrl2(document.form.x_DHCPClient, !dhcp_auto);
		$j('#x_DHCPClient_on_of').iState(dhcp_auto);
		
		inputCtrl(document.form.x_DHCPClient[0], 1);
		inputCtrl(document.form.x_DHCPClient[1], 1);
		$j('input[name="x_DHCPClient"]').removeAttr('disabled');
		$j('#x_DHCPClient_on_of').iClickable(1);
		
		set_wan_dhcp_auto(dhcp_auto);
	}
	else if(wan_type == "static"){
		inputRCtrl2(document.form.x_DHCPClient, 1);
		$j('#x_DHCPClient_on_of').iState(0);
		
		inputCtrl(document.form.x_DHCPClient[0], 0);
		inputCtrl(document.form.x_DHCPClient[1], 0);
		$j('input[name="x_DHCPClient"]').attr('disabled','disabled');
		$j('#x_DHCPClient_on_of').iClickable(0);
		
		set_wan_dhcp_auto(0);
	}
	else{
		inputRCtrl2(document.form.x_DHCPClient, 0);
		$j('#x_DHCPClient_on_of').iState(1);
		
		inputCtrl(document.form.x_DHCPClient[0], 0);
		inputCtrl(document.form.x_DHCPClient[1], 0);
		$j('input[name="x_DHCPClient"]').attr('disabled','disabled');
		$j('#x_DHCPClient_on_of').iClickable(0);
		
		set_wan_dhcp_auto(1);
	}
}

function change_wan_dns_enable(wan_type){
	if(wan_type == "static"){
		inputCtrl(document.form.wan_dnsenable_x[0], 0);
		inputCtrl(document.form.wan_dnsenable_x[1], 0);
		$j('input[name="wan_dnsenable_x"]').attr('disabled','disabled');
		$j('#wan_dnsenable_x_on_of').iClickable(0);
	}
	else{
		inputCtrl(document.form.wan_dnsenable_x[0], 1);
		inputCtrl(document.form.wan_dnsenable_x[1], 1);
		$j('input[name="wan_dnsenable_x"]').removeAttr('disabled');
		$j('#wan_dnsenable_x_on_of').iClickable(1);
	}
}

function showMAC(){
	document.form.wan_hwaddr_x.value = simplyMAC(this.client_mac);
}

function simplyMAC(fullMAC){
	var ptr;
	var tempMAC;
	var pos1, pos2;

	ptr = fullMAC;
	tempMAC = "";
	pos1 = pos2 = 0;

	for(var i = 0; i < 5; ++i){
		pos2 = pos1+ptr.indexOf(":");

		tempMAC += fullMAC.substring(pos1, pos2);

		pos1 = pos2+1;
		ptr = fullMAC.substring(pos1);
	}

	tempMAC += fullMAC.substring(pos1);

	return tempMAC;
}


</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">
<script>
	if(get_ap_mode()){
		alert("<#page_not_support_mode_hint#>");
		location.href = "/as.asp";
	}
</script>

<div class="wrapper">
    <div class="container-fluid" style="padding-right: 0px">
        <div class="row-fluid">
            <div class="span3"><center><div id="logo"></div></center></div>
            <div class="span9">
                <div id="TopBanner"></div>
            </div>
        </div>
    </div>

    <div id="Loading" class="popup_bg"></div>

    <iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

    <form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
    <input type="hidden" name="current_page" value="Advanced_WAN_Content.asp">
    <input type="hidden" name="next_page" value="">
    <input type="hidden" name="next_host" value="">
    <input type="hidden" name="sid_list" value="Layer3Forwarding;LANHostConfig;IPConnection;PPPConnection;WLANConfig11b">
    <input type="hidden" name="group_id" value="">
    <input type="hidden" name="action_mode" value="">
    <input type="hidden" name="action_script" value="">
    <input type="hidden" name="lan_ipaddr" value="<% nvram_get_x("", "lan_ipaddr"); %>" readonly="1" />
    <input type="hidden" name="lan_netmask" value="<% nvram_get_x("", "lan_netmask"); %>" readonly="1" />

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
                            <h2 class="box_head round_top"><#menu5_3#> - <#menu5_3_1#></h2>
                            <div class="round_bottom">
                                <div class="row-fluid">
                                    <div id="tabMenu" class="submenuBlock"></div>
                                    <div class="alert alert-info" style="margin: 10px;"><#Layer3Forwarding_x_ConnectionType_sectiondesc#></div>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th width="50%"><#Layer3Forwarding_x_ConnectionType_itemname#></th>
                                            <td align="left">
                                                <select class="input" name="wan_proto" onchange="change_wan_type(this.value);fixed_change_wan_type(this.value);">
                                                    <option value="static" <% nvram_match_x("", "wan_proto", "static", "selected"); %>>IPoE: <#BOP_ctype_title5#></option>
                                                    <option value="dhcp" <% nvram_match_x("", "wan_proto", "dhcp", "selected"); %>>IPoE: <#BOP_ctype_title1#></option>
                                                    <option value="pppoe" <% nvram_match_x("", "wan_proto", "pppoe", "selected"); %>>PPPoE</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_pppoe_dhcp" style="display:none;">
                                            <th><#MAN_PPPoE#></th>
                                            <td>
                                                <select name="wan_pppoe_man" class="input" onchange="change_pppoe_man(this.value);">
                                                    <option value="0" <% nvram_match_x("", "wan_pppoe_man", "0", "selected"); %>><#checkbox_No#></option>
                                                    <option value="1" <% nvram_match_x("", "wan_pppoe_man", "1", "selected"); %>>DHCP or Static</option>
                                                    <option value="2" <% nvram_match_x("", "wan_pppoe_man", "2", "selected"); %>>ZeroConf (169.254.*.*)</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_hwnat">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,23);"><#HardwareNAT#></a></th>
                                            <td>
                                                <select name="hw_nat_mode" class="input">
                                                    <option value="0" <% nvram_match_x("", "hw_nat_mode", "0", "selected"); %>>Offload TCP for LAN</option>
                                                    <option value="1" <% nvram_match_x("", "hw_nat_mode", "1", "selected"); %>>Offload TCP for LAN/WLAN</option>
                                                    <option value="3" <% nvram_match_x("", "hw_nat_mode", "3", "selected"); %>>Offload TCP/UDP for LAN</option>
                                                    <option value="4" <% nvram_match_x("", "hw_nat_mode", "4", "selected"); %>>Offload TCP/UDP for LAN/WLAN</option>
                                                    <option value="2" <% nvram_match_x("", "hw_nat_mode", "2", "selected"); %>>Disable (Slow)</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_sfe" style="display:none;">
                                            <th><#WAN_SFE#></a></th>
                                            <td>
                                                <select name="sfe_enable" class="input">
                                                    <option value="0" <% nvram_match_x("", "sfe_enable", "0", "selected"); %>>Disable</option>
                                                    <option value="1" <% nvram_match_x("", "sfe_enable", "1", "selected"); %>>Enable for IPv4/IPv6</option>
                                                    <option value="2" <% nvram_match_x("", "sfe_enable", "2", "selected"); %>>Enable for IPv4/IPv6 and WiFi</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_wan_poller">
                                            <th><#WAN_Poller#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="gw_arp_ping_on_of">
                                                        <input type="checkbox" id="gw_arp_ping_fake" <% nvram_match_x("", "gw_arp_ping", "1", "value=1 checked"); %><% nvram_match_x("", "gw_arp_ping", "0", "value=0"); %>>
                                                    </div>
                                                </div>

                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="gw_arp_ping" id="gw_arp_ping_1" value="1" <% nvram_match_x("", "gw_arp_ping", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" name="gw_arp_ping" id="gw_arp_ping_0" value="0" <% nvram_match_x("", "gw_arp_ping", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table" id="tbl_dhcp_sect">
                                        <tr>
                                            <th id="dhcp_sect_desc" colspan="2" style="background-color: #E3E3E3;"><#IPConnection_ExternalIPAddress_sectionname#></th>
                                        </tr>
                                        <tr id="row_dhcp_toggle">
                                            <th id="dhcp_auto_desc" width="50%"><#Layer3Forwarding_x_DHCPClient_itemname#></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="x_DHCPClient_on_of">
                                                        <input type="checkbox" id="x_DHCPClient_fake" <% nvram_match_x("", "x_DHCPClient", "1", "value=1 checked"); %><% nvram_match_x("", "x_DHCPClient", "0", "value=0"); %>>
                                                    </div>
                                                </div>

                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="x_DHCPClient" id="x_DHCPClient_1" class="input" value="1" onclick="set_wan_dhcp_auto(1);" <% nvram_match_x("", "x_DHCPClient", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" name="x_DHCPClient" id="x_DHCPClient_0" class="input" value="0" onclick="set_wan_dhcp_auto(0);" <% nvram_match_x("", "x_DHCPClient", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="row_wan_ipaddr">
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,1);"><#IPConnection_ExternalIPAddress_itemname#></a></th>
                                            <td><input type="text" name="wan_ipaddr" maxlength="15" class="input" size="15" value="<% nvram_get_x("","wan_ipaddr"); %>" onKeyPress="return is_ipaddr(this,event);"/></td>
                                        </tr>
                                        <tr id="row_wan_netmask">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,2);"><#IPConnection_x_ExternalSubnetMask_itemname#></a></th>
                                            <td><input type="text" name="wan_netmask" maxlength="15" class="input" size="15" value="<% nvram_get_x("","wan_netmask"); %>" onKeyPress="return is_ipaddr(this,event);"/></td>
                                        </tr>
                                        <tr id="row_wan_gateway">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,3);"><#IPConnection_x_ExternalGateway_itemname#></a></th>
                                            <td><input type="text" name="wan_gateway" maxlength="15" class="input" size="15" value="<% nvram_get_x("","wan_gateway"); %>" onKeyPress="return is_ipaddr(this,event);"/></td>
                                        </tr>
                                        <tr id="row_wan_mtu">
                                            <th>MTU:</th>
                                            <td>
                                                <input type="text" name="wan_mtu" maxlength="4" class="input" size="5" value="<% nvram_get_x("","wan_mtu"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[1300..1500]</span>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#IPConnection_x_DNSServerEnable_sectionname#></th>
                                        </tr>
                                        <tr id="row_dns_toggle">
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,12);"><#IPConnection_x_DNSServerEnable_itemname#></a></th>
                                            <td>
                                                <div class="main_itoggle">
                                                    <div id="wan_dnsenable_x_on_of">
                                                        <input type="checkbox" id="wan_dnsenable_x_fake" <% nvram_match_x("", "wan_dnsenable_x", "1", "value=1 checked"); %><% nvram_match_x("", "wan_dnsenable_x", "0", "value=0"); %>>
                                                    </div>
                                                </div>

                                                <div style="position: absolute; margin-left: -10000px;">
                                                    <input type="radio" name="wan_dnsenable_x" id="wan_dnsenable_x_1" value="1" onclick="set_wan_dns_auto(1);" <% nvram_match_x("", "wan_dnsenable_x", "1", "checked"); %>/><#checkbox_Yes#>
                                                    <input type="radio" name="wan_dnsenable_x" id="wan_dnsenable_x_0" value="0" onclick="set_wan_dns_auto(0);" <% nvram_match_x("", "wan_dnsenable_x", "0", "checked"); %>/><#checkbox_No#>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr id="row_wan_dns1">
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,13);"><#IPConnection_x_DNSServer1_itemname#> 1:</a></th>
                                            <td>
                                              <input type="text" maxlength="15" class="input" size="15" name="wan_dns1_x" value="<% nvram_get_x("","wan_dns1_x"); %>" onkeypress="return is_ipaddr(this,event);"/>
                                            </td>
                                        </tr>
                                        <tr id="row_wan_dns2">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,14);"><#IPConnection_x_DNSServer1_itemname#> 2:</a></th>
                                            <td>
                                               <input type="text" maxlength="15" class="input" size="15" name="wan_dns2_x" value="<% nvram_get_x("","wan_dns2_x"); %>" onkeypress="return is_ipaddr(this,event);"/>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" align="center" cellpadding="4" cellspacing="0" class="table" id="tbl_vpn_control">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#PPPConnection_UserName_sectionname#></th>
                                        </tr>
                                        <tr>
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,4);"><#PPPConnection_UserName_itemname#></a></th>
                                            <td>
                                               <input type="text" maxlength="64" class="input" size="32" name="wan_pppoe_username" value="<% nvram_get_x("","wan_pppoe_username"); %>" onkeypress="return is_string(this,event);"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,5);"><#PPPConnection_Password_itemname#></a></th>
                                            <td>
                                                <div class="input-append">
                                                    <input type="password" maxlength="64" class="input" size="32" name="wan_pppoe_passwd" id="wan_pppoe_passwd" style="width: 175px;" value="<% nvram_get_x("","wan_pppoe_passwd"); %>"/>
                                                    <button style="margin-left: -5px;" class="btn" type="button" onclick="passwordShowHide('wan_pppoe_passwd')"><i class="icon-eye-close"></i></button>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><#VPNS_Auth#></th>
                                            <td>
                                                <select name="wan_ppp_auth" class="input">
                                                    <option value="0" <% nvram_match_x("", "wan_ppp_auth", "0","selected"); %>>Auto</option>
                                                    <option value="1" <% nvram_match_x("", "wan_ppp_auth", "1","selected"); %>>PAP</option>
                                                    <option value="2" <% nvram_match_x("", "wan_ppp_auth", "2","selected"); %>>CHAP</option>
                                                    <option value="3" <% nvram_match_x("", "wan_ppp_auth", "3","selected"); %>>MS-CHAPv2</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_ppp_mppe">
                                            <th><#VPNS_Ciph#></th>
                                            <td>
                                                <select name="wan_ppp_mppe" class="input">
                                                    <option value="0" <% nvram_match_x("", "wan_ppp_mppe", "0","selected"); %>>No Encryption</option>
                                                    <option value="1" <% nvram_match_x("", "wan_ppp_mppe", "1","selected"); %>>Auto</option>
                                                    <option value="2" <% nvram_match_x("", "wan_ppp_mppe", "2","selected"); %>>MPPE-40</option>
                                                    <option value="3" <% nvram_match_x("", "wan_ppp_mppe", "3","selected"); %>>MPPE-128</option>
                                                </select>
                                            </td>
                                        </tr>
                                        <tr id="row_pppoe_mtu">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,7);"><#PPPConnection_x_PPPoEMTU_itemname#></a></th>
                                            <td>
                                                <input type="text" maxlength="4" size="5" name="wan_pppoe_mtu" class="input" value="<% nvram_get_x("", "wan_pppoe_mtu"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[1000..1492]</span>
                                            </td>
                                        </tr>
                                        <tr id="row_pppoe_mru">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,8);"><#PPPConnection_x_PPPoEMRU_itemname#></a></th>
                                            <td>
                                                <input type="text" maxlength="4" size="5" name="wan_pppoe_mru" class="input" value="<% nvram_get_x("", "wan_pppoe_mru"); %>" onkeypress="return is_number(this,event);"/>
                                                &nbsp;<span style="color:#888;">[1000..1492]</span>
                                            </td>
                                        </tr>
                                        <tr id="row_pppoe_svc">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,9);"><#PPPConnection_x_ServiceName_itemname#></a></th>
                                            <td>
                                                <input type="text" maxlength="32" class="input" size="32" name="wan_pppoe_service" value="<% nvram_get_x("","wan_pppoe_service"); %>" onkeypress="return is_string(this,event);"/>
                                            </td>
                                        </tr>
                                    </table>

                                    <table width="100%" cellpadding="4" cellspacing="0" class="table">
                                        <tr>
                                            <th colspan="2" style="background-color: #E3E3E3;"><#PPPConnection_x_HostNameForISP_sectionname#></th>
                                        </tr>
                                        <tr id="row_hostname">
                                            <th><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,16);"><#PPPConnection_x_HostNameForISP_itemname#></a></th>
                                            <td>
                                                <input type="text" name="wan_hostname" class="input" maxlength="32" size="32" value="<% nvram_get_x("","wan_hostname"); %>" onkeypress="return is_string(this,event);"/>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th width="50%"><a class="help_tooltip" href="javascript:void(0);" onmouseover="openTooltip(this,7,17);"><#PPPConnection_x_MacAddressForISP_itemname#></a></th>
                                            <td>
                                                <input type="text" name="wan_hwaddr_x" class="input" style="float: left; margin-right: 5px;" maxlength="12" size="15" value="<% nvram_get_x("","wan_hwaddr_x"); %>" onKeyPress="return is_hwaddr(event);"/>
                                                <button type="button" class="btn" onclick="showMAC();"><i class="icon icon-plus"></i></button>
                                            </td>
                                        </tr>
                                    </table>

                                    <table class="table">
                                        <tr>
                                            <td style="border: 0 none;"><center><input name="button" type="button" class="btn btn-primary" style="width: 219px" onclick="applyRule();" value="<#CTL_apply#>"/></center></td>
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
