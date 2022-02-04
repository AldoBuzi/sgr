--
-- (C) 2019-20 - ntop.org
--

local user_scripts = require("user_scripts")
local flow_consts = require("flow_consts")

-- ############################################

local script = {
   -- Script category
   category = user_scripts.script_categories.network,

   l4_proto = "tcp",

   -- NOTE: hooks defined below
   hooks = {},

   gui = {
      i18n_title = "tcp_retransmissions.tcp_retransmissions_alert_title",
      i18n_description = "tcp_retransmissions.tcp_retransmissions_alert_description",
   }
}

-- ############################################

local function retransmissions_check(now)
   local c2s_retransmissions_percentage = flow.getClientRetrPercentage()
   local s2c_retransmissions_percentage = flow.getServerRetrPercentage()
   
   local client_score = 0
   local server_score = 0
   local emit_retransmission_alert = false
   local threshold_percentage = 0.2 -- 20%
   local info = {}
   
   if (c2s_retransmissions_percentage >= threshold_percentage) then
      client_score = client_score + 2
      server_score = server_score + 10
      info["retransmissions_percentage.cli"] = tostring(c2s_retransmissions_percentage*100).."%"
      emit_retransmission_alert = true
   end
   
   if (s2c_retransmissions_percentage >= threshold_percentage) then
      client_score = client_score + 10
      server_score = server_score + 2
      info["retransmissions_percentage.srv"] = tostring(s2c_retransmissions_percentage*100).."%"
      emit_retransmission_alert = true
   end 

   if emit_retransmission_alert then
      flow.triggerStatus(
	 flow_consts.status_types.status_retransmissions.create(
	    flow_consts.status_types.status_retransmissions.alert_severity,
	    info
	 ),
	 10, -- flow score subject to change
	 client_score,
	 server_score
      )
   end

end

-- ############################################

script.hooks.flowEnd = retransmissions_check
script.hooks.periodicUpdate = retransmissions_check 

-- ############################################

return script
